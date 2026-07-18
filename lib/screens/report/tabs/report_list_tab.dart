import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/screens/report/tabs/base_report_tab.dart';

// =============================================================================
// REPORT LIST TAB — Danh sách sự cố CHƯA giải quyết
//
// File này chỉ là lớp mỏng (thin wrapper) cấu hình BaseReportTab.
// Toàn bộ UI, logic lọc, và cơ chế Cache nằm trong BaseReportTab.
//
// Thay đổi so với trước:
//   - Đổi từ StatefulWidget → StatelessWidget (không còn State nào ở đây)
//   - Xoá toàn bộ code lọc, tính toán, didChangeDependencies, setState
//   - Chỉ còn việc cấu hình BaseReportTab với đúng tham số
// =============================================================================
class ReportListTab extends StatelessWidget {
  const ReportListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseReportTab(
      isResolvedTab: false,
      title: 'Danh sách sự cố',
      emptyMessage: 'Tuyệt vời! Không có sự cố nào cần xử lý',
      emptyIcon: Icons.assignment_turned_in_outlined,
      emptyIconColor: Colors.green,
    );
  }
}
