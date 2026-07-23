import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/providers/report_provider.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/core/theme/theme.dart';
import 'package:resolvex_mobile_app/utils/report_filter_logic.dart';
import 'package:resolvex_mobile_app/widgets/empty_state_view.dart';
import 'package:resolvex_mobile_app/widgets/rx_container.dart';
import 'package:resolvex_mobile_app/widgets/rx_customscrollview.dart';
import 'package:resolvex_mobile_app/widgets/report_filter_bar.dart';

// =============================================================================
// BASE REPORT TAB — Widget nền dùng chung cho ReportListTab & ReportHistoryTab
//
// Vì sao cần file này?
//   ReportListTab và ReportHistoryTab có cấu trúc UI và logic lọc giống nhau
//   đến 95%. Chỉ khác nhau ở: điều kiện lọc status, tiêu đề, thông báo rỗng,
//   và icon rỗng. Thay vì viết lặp code ở 2 file, ta gom toàn bộ vào đây
//   và để các Tab con chỉ cần truyền 4-5 tham số cấu hình.
//
// [FIX #5 — context.select() thay thế didChangeDependencies + cache thủ công]
//
// VẤN ĐỀ CŨ (didChangeDependencies + cache thủ công):
//   - Gọi context.watch() trong didChangeDependencies() là SAI QUY ĐỊNH của
//     thư viện Provider — context.watch() được thiết kế chỉ dùng trong build().
//   - Gọi thêm setState(() {}) trong didChangeDependencies() là ANTI-PATTERN:
//     Flutter đã tự động lên lịch gọi build() sau didChangeDependencies(),
//     gọi thêm setState() là "bấm F5 hai lần liên tiếp", tốn CPU và tiềm ẩn
//     nguy cơ Infinite Rebuild Loop (vòng lặp vô tận) nếu không cẩn thận.
//   - Cần 2 biến cache (_cachedBaseList, _cachedFilteredList) và 2 hàm
//     tính toán thủ công (_recompute, _recomputeFiltered) rất cồng kềnh.
//
// GIẢI PHÁP MỚI (context.select):
//   context.select<T, R>((provider) => giaTri) hoạt động như sau:
//   1. Đăng ký lắng nghe Provider T.
//   2. Mỗi khi Provider gọi notifyListeners(), Flutter lấy giá trị mới
//      bằng hàm selector và SO SÁNH với giá trị cũ (dùng ==).
//   3. Nếu giá trị KHÔNG đổi → bỏ qua, KHÔNG rebuild widget.
//   4. Nếu giá trị CÓ ĐỔI → cho phép rebuild.
//
//   → CHỈ trigger rebuild khi đúng giá trị đang chọn (listReport / isLoadingMore)
//     thay đổi, bỏ qua mọi thay đổi khác của Provider (ví dụ: isLoading không
//     làm danh sách vẽ lại). Hoàn toàn tương đương hiệu năng với didChangeDependencies.
//
//   → Việc tính toán baseList và filteredList trong build() là chấp nhận được:
//     .where().toList() trên vài chục đến vài trăm phần tử chỉ mất vài microsecond,
//     không phải "tính toán nặng" như AI hay mã hóa. Build() cũng không chạy
//     60 lần/giây một cách tự do — Flutter chỉ gọi lại khi có thay đổi thực sự.
//
//   → Xoá hoàn toàn 2 biến cache và 2 hàm thủ công — code gọn hơn 40 dòng.
// =============================================================================

/// Widget nền dùng chung. Được khởi tạo bởi [ReportListTab] và [ReportHistoryTab].
class BaseReportTab extends StatefulWidget {
  /// true  = tab Lịch sử  → lấy báo cáo ĐÃ giải quyết (status == resolved)
  /// false = tab Danh sách → lấy báo cáo CHƯA giải quyết (status != resolved)
  final bool isResolvedTab;

  /// Tiêu đề hiển thị trong AppBar (VD: 'Danh sách sự cố')
  final String title;

  /// Thông báo khi danh sách gốc (chưa lọc) hoàn toàn rỗng
  final String emptyMessage;

  /// Icon hiển thị kèm thông báo rỗng
  final IconData emptyIcon;

  /// Màu của icon rỗng (tùy chọn — mặc định dùng màu theme)
  final Color? emptyIconColor;

  const BaseReportTab({
    super.key,
    required this.isResolvedTab,
    required this.title,
    required this.emptyMessage,
    required this.emptyIcon,
    this.emptyIconColor,
  });

  @override
  State<BaseReportTab> createState() => _BaseReportTabState();
}

class _BaseReportTabState extends State<BaseReportTab> {
  // ---------------------------------------------------------------------------
  // UI STATE — Bộ lọc do người dùng chọn
  //
  // Đây là trạng thái giao diện thuần tuý (không phải dữ liệu nghiệp vụ),
  // nên lưu trong local State thay vì Provider.
  // Khi người dùng đổi bộ lọc → setState() → build() chạy lại → tự tính lại
  // danh sách đã lọc từ sourceList đã có sẵn (không cần query API lại).
  // ---------------------------------------------------------------------------
  ProblemType? _selectedType;
  Level? _selectedLevel;
  bool _isNewestFirst = true;

  // [FIX #5] Đã XÓA toàn bộ:
  //   - _cachedBaseList    : List<ReportModel>
  //   - _cachedFilteredList: List<ReportModel>
  //   - didChangeDependencies(): không cần nữa
  //   - _recompute()          : không cần nữa
  //   - _recomputeFiltered()  : không cần nữa
  // Lý do: context.select() trong build() xử lý tất cả, sạch hơn và đúng chuẩn hơn.

  // ---------------------------------------------------------------------------
  // BUILD — Tính toán và dựng UI tại đây, an toàn và chuẩn Provider
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------------------
    // [FIX #5] context.select() — lấy listReport từ Provider một cách chọn lọc.
    //
    // So sánh với context.watch():
    //   context.watch<ReportProvider>()      → rebuild khi BẤT KỲ thuộc tính
    //                                          nào trong Provider thay đổi
    //                                          (kể cả isLoading, isLoadingMore...)
    //
    //   context.select<ReportProvider, ...>  → rebuild CHỈ KHI listReport
    //                                          thực sự thay đổi (provider gọi
    //                                          notifyListeners() sau khi thêm/xóa
    //                                          báo cáo). Bỏ qua mọi thay đổi khác.
    //
    // Đây là cách dùng ĐÚNG QUY ĐỊNH của thư viện Provider — không cần
    // "hack" qua didChangeDependencies() nữa.
    // -------------------------------------------------------------------------
    final sourceList = context.select<ReportProvider, List<ReportModel>>(
      (provider) => provider.listReport,
    );

    // select riêng isLoadingMore để chỉ vẽ lại spinner cuối list
    // khi trạng thái tải trang tiếp thay đổi, không kéo theo rebuild cả list.
    final isLoadingMore = context.select<ReportProvider, bool>(
      (provider) => provider.isLoadingMore,
    );

    // -------------------------------------------------------------------------
    // Tính toán danh sách lọc ngay trong build() — KHÔNG cần biến cache.
    //
    // Tại sao an toàn để tính ở đây?
    //   1. context.select() đảm bảo build() chỉ chạy khi listReport thực sự đổi.
    //   2. Khi người dùng đổi bộ lọc (setState), build() cũng chạy lại → tự
    //      tính lại filteredList từ sourceList đang có → UI cập nhật đúng ngay.
    //   3. .where().toList() trên vài chục - vài trăm phần tử ≈ vài microsecond.
    //      Không phải tính toán nặng, không gây drop frame.
    // -------------------------------------------------------------------------

    // Bước 1: Lọc theo loại Tab
    //   Tab Danh sách (isResolvedTab=false): chỉ lấy báo cáo CHƯA giải quyết
    //   Tab Lịch sử   (isResolvedTab=true) : chỉ lấy báo cáo ĐÃ giải quyết
    final baseList = sourceList
        .where((r) => widget.isResolvedTab
            ? r.status == Status.resolved
            : r.status != Status.resolved)
        .toList();

    // Bước 2: Áp dụng thêm bộ lọc type/level/sort mà người dùng đang chọn
    final filteredList = applyReportFilters(
      baseList: baseList,
      selectedType: _selectedType,
      selectedLevel: _selectedLevel,
      isNewestFirst: _isNewestFirst,
    );

    final isFilterActive = _selectedType != null || _selectedLevel != null;

    return NotificationListener<ScrollNotification>(
      // Detect khi người dùng cuộn gần đến cuối (còn 200px) → tải trang tiếp
      onNotification: (scroll) {
        if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
          // context.read: chỉ gọi action, không đăng ký lắng nghe rebuild
          context.read<ReportProvider>().loadReports(reset: false);
        }
        // false = cho phép scroll event tiếp tục lan lên các widget cha
        return false;
      },
      child: RXCustomScrollView(
        expandedHeight: 120,
        showBackButton: false,
        flexibleSpace: FlexibleSpaceBar(
          background: Padding(
            padding: const EdgeInsets.only(top: 40, left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColorsDark.textPrimary
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        sliver: [
          SliverToBoxAdapter(
            child: ReportFilterBar(
              selectedType: _selectedType,
              selectedLevel: _selectedLevel,
              isNewestFirst: _isNewestFirst,
              // [FIX #5] Khi bộ lọc thay đổi: chỉ cần setState để cập nhật
              // biến state. build() sẽ tự chạy lại và tính filteredList mới.
              // Không cần gọi _recomputeFiltered() thủ công nữa.
              onTypeChanged: (type) => setState(() => _selectedType = type),
              onLevelChanged: (lvl) => setState(() => _selectedLevel = lvl),
              onSortChanged: (newest) => setState(() => _isNewestFirst = newest),
            ),
          ),
          if (baseList.isEmpty)
            EmptyStateView(
              icon: widget.emptyIcon,
              iconColor: widget.emptyIconColor,
              message: widget.emptyMessage,
            )
          else if (filteredList.isEmpty && isFilterActive)
            const EmptyStateView(
              icon: Icons.filter_list_off,
              message: 'Không tìm thấy báo cáo nào phù hợp với bộ lọc',
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(top: 10, bottom: 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => RXContainer(
                    reportModel: filteredList[index],
                    onTap: () async {
                      // Chỉ mở màn hình Chi tiết. Việc update/xóa local sẽ do
                      // DetailReportScreen tự gọi Provider. Không cần gọi loadReports nữa!
                      await context.pushNamed(
                        RouteNames.detailReport,
                        extra: filteredList[index],
                      );
                    },
                  ),
                  childCount: filteredList.length,
                ),
              ),
            ),
          // Spinner ở cuối list — chỉ hiện khi đang tải trang tiếp
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
