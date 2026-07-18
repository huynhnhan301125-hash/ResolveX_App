import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/screens/report/tabs/base_report_tab.dart';

// =============================================================================
// REPORT HISTORY TAB — Lịch sử sự cố ĐÃ giải quyết
//
// File này chỉ là lớp mỏng (thin wrapper) cấu hình BaseReportTab.
// Toàn bộ UI, logic lọc, và cơ chế Cache nằm trong BaseReportTab.
//
// Thay đổi so với trước:
//   - Đổi từ StatefulWidget → StatelessWidget (không còn State nào ở đây)
//   - Xoá toàn bộ code lọc, tính toán, didChangeDependencies, setState
//   - Chỉ còn việc cấu hình BaseReportTab với đúng tham số
// =============================================================================
class ReportHistoryTab extends StatelessWidget {
  const ReportHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseReportTab(
      isResolvedTab: true,
      title: 'Lịch sử giải quyết',
      emptyMessage: 'Lịch sử trống. Chưa có sự cố nào được xử lý',
      emptyIcon: Icons.history_toggle_off,
    );
  }
}
