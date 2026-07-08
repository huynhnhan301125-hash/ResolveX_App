import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/utils/report_filter_logic.dart';
import 'package:resolvex_mobile_app/widgets/empty_state_view.dart';
import 'package:resolvex_mobile_app/widgets/rx_container.dart';
import 'package:resolvex_mobile_app/widgets/rx_customscrollview.dart';
import 'package:resolvex_mobile_app/widgets/report_filter_bar.dart';

class ReportListTab extends StatefulWidget {
  final List<ReportModel> listReport;
  const ReportListTab({super.key, required this.listReport});

  @override
  State<ReportListTab> createState() => _ReportListTabState();
}

class _ReportListTabState extends State<ReportListTab> {
  ProblemType? selectedType;
  Level? selectedLevel;
  bool isNewestFirst = true;

  @override
  Widget build(BuildContext context) {
    // 1. Lấy danh sách cơ sở: chỉ lấy báo cáo CHƯȠ giải quyết
    final baseList = widget.listReport.where((r) => r.status != Status.resolved).toList();

    // 2. Áp dụng bộ lọc và sắp xếp qua hàm dùng chung (tránh lặp 15 dòng tại report_history_tab)
    final filteredList = applyReportFilters(baseList: baseList, selectedType: selectedType, selectedLevel: selectedLevel, isNewestFirst: isNewestFirst);

    // 3. Kiểm tra xem có đang kích hoạt bộ lọc nào không để phân biệt 2 trường hợp rỗng
    final isFilterActive = selectedType != null || selectedLevel != null;

    return RXCustomScrollView(
      expandedHeight: 120,
      showBackButton: false,
      flexibleSpace: const FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.only(top: 40, left: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Danh sách sự cố', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
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
        // TH 1: Không có báo cáo nào trong hệ thống (danh sách gốc rỗng)
        if (baseList.isEmpty)
          const EmptyStateView(icon: Icons.assignment_turned_in_outlined, iconColor: Colors.green, message: 'Tuyệt vời! Không có sự cố nào cần xử lý')
        // TH 2: Có dữ liệu nhưng bộ lọc đang được áp dụng và không khớp kết quả nào
        else if (filteredList.isEmpty && isFilterActive)
          const EmptyStateView(icon: Icons.filter_list_off, message: 'Không tìm thấy báo cáo nào phù hợp với bộ lọc')
        // TH 3: Hiển thị danh sách bình thường
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
