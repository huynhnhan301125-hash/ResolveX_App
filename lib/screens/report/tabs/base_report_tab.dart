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
// Giải quyết lỗi hiệu năng (Tính toán nặng trong build()):
//   Trước: baseList và filteredList được tính lại trong build() — chạy 60 lần/giây
//          khi người dùng cuộn, gây drop FPS và GC pressure cao.
//
//   Sau:   Sử dụng didChangeDependencies() để tính toán khi Provider thay đổi,
//          và _recomputeFiltered() khi bộ lọc thay đổi.
//          build() chỉ đọc cache — O(1), không tạo List mới.
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
  // UI STATE — Bộ lọc do người dùng chọn (không lưu trong Provider vì đây là
  // trạng thái giao diện thuần tuý, không phải dữ liệu nghiệp vụ)
  // ---------------------------------------------------------------------------
  ProblemType? _selectedType;
  Level? _selectedLevel;
  bool _isNewestFirst = true;

  // ---------------------------------------------------------------------------
  // CACHE — Kết quả tính toán được lưu tại đây để build() chỉ cần đọc, không tính
  //
  // _cachedBaseList:     Danh sách đã lọc theo status (resolved hoặc chưa resolved).
  //                      Chỉ cập nhật khi Provider đẩy dữ liệu mới (didChangeDependencies).
  // _cachedFilteredList: Danh sách sau khi áp dụng thêm bộ lọc type/level/sort.
  //                      Cập nhật khi Provider đẩy data mới HOẶC người dùng đổi bộ lọc.
  // ---------------------------------------------------------------------------
  List<ReportModel> _cachedBaseList = [];
  List<ReportModel> _cachedFilteredList = [];

  // ---------------------------------------------------------------------------
  // LIFECYCLE — Tính toán nặng chỉ xảy ra ở đây, KHÔNG bao giờ trong build()
  // ---------------------------------------------------------------------------

  /// Được Flutter gọi tự động khi:
  ///   1. Widget được gắn vào cây lần đầu (sau initState).
  ///   2. Một InheritedWidget mà widget này phụ thuộc vào thay đổi — cụ thể ở
  ///      đây là ReportProvider (vì ta gọi context.watch bên trong).
  ///
  /// Đây là nơi chính xác để thay thế context.watch trong build() khi ta cần
  /// phản ứng với dữ liệu mới nhưng không muốn tính toán nằm trong build().
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // context.watch ở đây đăng ký widget lắng nghe Provider.
    // Khi listReport thay đổi, didChangeDependencies được gọi lại → tính cache mới.
    final sourceList = context.watch<ReportProvider>().listReport;
    _recompute(sourceList);
  }

  /// Tính lại TOÀN BỘ cache từ đầu (baseList + filteredList).
  /// Gọi khi dữ liệu nguồn từ Provider thay đổi.
  void _recompute(List<ReportModel> sourceList) {
    // Lọc theo status dựa vào loại Tab
    _cachedBaseList = sourceList
        .where((r) => widget.isResolvedTab
            ? r.status == Status.resolved    // Tab Lịch sử: chỉ lấy đã xong
            : r.status != Status.resolved)   // Tab Danh sách: chỉ lấy chưa xong
        .toList();

    // Áp dụng thêm bộ lọc type/level/sort
    _cachedFilteredList = applyReportFilters(
      baseList: _cachedBaseList,
      selectedType: _selectedType,
      selectedLevel: _selectedLevel,
      isNewestFirst: _isNewestFirst,
    );
    // Không cần setState() vì didChangeDependencies tự trigger rebuild sau đó
  }

  /// Tính lại CHỈ filteredList từ _cachedBaseList đã có sẵn.
  /// Gọi khi người dùng thay đổi bộ lọc — tiết kiệm hơn _recompute() vì
  /// không chạy lại .where(status) trên toàn bộ sourceList.
  void _recomputeFiltered() {
    setState(() {
      _cachedFilteredList = applyReportFilters(
        baseList: _cachedBaseList, // dùng lại cache — không chạy .where() lại
        selectedType: _selectedType,
        selectedLevel: _selectedLevel,
        isNewestFirst: _isNewestFirst,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // BUILD — Chỉ đọc cache và dựng UI, tuyệt đối không tính toán ở đây
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Đọc thêm isLoadingMore từ Provider — chỉ để hiện spinner cuối list.
    // context.watch ở đây không trigger tính toán nặng (đã được xử lý trong
    // didChangeDependencies ở trên).
    final isLoadingMore = context.watch<ReportProvider>().isLoadingMore;

    // Đọc cache — O(1), không tạo List mới, không tính gì cả
    final baseList = _cachedBaseList;
    final filteredList = _cachedFilteredList;
    final isFilterActive = _selectedType != null || _selectedLevel != null;

    return NotificationListener<ScrollNotification>(
      // Detect khi người dùng cuộn gần đến cuối (còn 200px) → tải trang tiếp
      onNotification: (scroll) {
        if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
          // context.read: chỉ gọi action, không đăng ký lắng nghe rebuild
          context.read<ReportProvider>().loadReports(reset: false);
        }
        /*
         Vì hàm onNotification của Flutter quy định bắt buộc phải trả về một giá trị bool (true hoặc false)
         Trả về true: Ngăn không cho thông báo cuộn chạy tiếp.
          Trả về false: Cứ để thông báo cuộn chạy bình thường.
         */
        return false; // false = cho phép event tiếp tục lan rộng lên
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
              // Cập nhật state và tính lại filteredList ngay — không cần setState riêng
              onTypeChanged: (type) {
                _selectedType = type;
                _recomputeFiltered();
              },
              onLevelChanged: (lvl) {
                _selectedLevel = lvl;
                _recomputeFiltered();
              },
              onSortChanged: (newest) {
                _isNewestFirst = newest;
                _recomputeFiltered();
              },
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
                      // Lưu provider trước khi await — tránh use_build_context_synchronously
                      final provider = context.read<ReportProvider>();
                      await context.pushNamed(
                        RouteNames.detailReport,
                        extra: filteredList[index],
                      );
                      if (mounted) {
                        provider.loadReports(reset: true);
                      }
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
