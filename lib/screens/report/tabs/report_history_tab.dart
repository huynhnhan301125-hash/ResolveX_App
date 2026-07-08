import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/utils/report_filter_logic.dart';
import 'package:resolvex_mobile_app/widgets/empty_state_view.dart';
import 'package:resolvex_mobile_app/widgets/rx_container.dart';
import 'package:resolvex_mobile_app/widgets/rx_customscrollview.dart';
import 'package:resolvex_mobile_app/widgets/report_filter_bar.dart';

class ReportHistoryTab extends StatefulWidget {
  final List<ReportModel> listReport;
  const ReportHistoryTab({super.key, required this.listReport});

  @override
  State<ReportHistoryTab> createState() => _ReportHistoryTabState();
}

class _ReportHistoryTabState extends State<ReportHistoryTab> {
  ProblemType? selectedType;
  Level? selectedLevel;
  bool isNewestFirst = true;

  @override
  Widget build(BuildContext context) {
    // 1. Lấy danh sách cơ sở: chỉ lấy báo cáo ĐÃ giải quyết (ngược với ReportListTab)
    final baseList = widget.listReport.where((r) => r.status == Status.resolved).toList();

    // 2. Tái sử dụng hàm lọc chung — tránh viết lại 15 dòng logic đã có ở report_list_tab
    final filteredList = applyReportFilters(baseList: baseList, selectedType: selectedType, selectedLevel: selectedLevel, isNewestFirst: isNewestFirst);

    // 3. Kiểm tra trạng thái bộ lọc để xác định ngên nhân khi danh sách lọc rỗng
    final isFilterActive = selectedType != null || selectedLevel != null;

    return RXCustomScrollView(
      expandedHeight: 120,
      showBackButton: false,
      flexibleSpace: const FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.only(top: 40, left: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Lịch sử giải quyết', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
        ),
      ),
      sliver: [
        SliverToBoxAdapter(
          child: ReportFilterBar(
            selectedType: selectedType,
            selectedLevel: selectedLevel,
            isNewestFirst: isNewestFirst,
            onTypeChanged: (type) => setState(() => selectedType = type),
            onLevelChanged: (lvl) => setState(() => selectedLevel = lvl),
            onSortChanged: (newest) => setState(() => isNewestFirst = newest),
          ),
        ),
        // TH 1: Lịch sử trống — chưa có báo cáo nào được giải quyết
        if (baseList.isEmpty)
          const EmptyStateView(icon: Icons.history_toggle_off, message: 'Lịch sử trống. Chưa có sự cố nào được xử lý')
        // TH 2: Có lịch sử nhưng bộ lọc hiện tại không khớp kết quả nào
        else if (filteredList.isEmpty && isFilterActive)
          const EmptyStateView(icon: Icons.filter_list_off, message: 'Không tìm thấy báo cáo nào phù hợp với bộ lọc')
        // TH 3: Hiển thị lịch sử bình thường
        else
          SliverPadding(
            padding: const EdgeInsets.only(top: 10, bottom: 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => RXContainer(
                  reportModel: filteredList[index],
                  onTap: () => context.pushNamed(RouteNames.detailReport, extra: filteredList[index]),
                ),
                childCount: filteredList.length,
              ),
            ),
          ),
      ],
    );
  }
}
