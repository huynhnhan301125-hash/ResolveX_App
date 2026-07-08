import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/utils/app_styles.dart';

class DetailReportScreen extends StatelessWidget {
  final ReportModel report;

  const DetailReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết báo cáo #${report.reportId}'),
        backgroundColor: AppColors.brandPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trạng thái báo cáo
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: report.status.color,
                  borderRadius: AppStyles.brXXL,
                ),
                child: Text(
                  report.status.label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: AppStyles.spaceXL),

            // Thông tin chính — dùng _ReportInfoRow (private class cuối file này)
            // Thay vì import widget từ file riêng vì nó CHỈ dùng ở đây
            _ReportInfoRow(icon: Icons.room, label: 'Phòng:', value: report.problemRoom),
            _ReportInfoRow(icon: report.problemType.icon, label: 'Loại lỗi:', value: report.problemType.label),
            _ReportInfoRow(icon: Icons.priority_high, label: 'Mức độ:', value: report.level.label, color: report.level.color),
            _ReportInfoRow(
              icon: Icons.calendar_today,
              label: 'Ngày báo cáo:',
              value: DateFormat('HH:mm - dd/MM/yyyy').format(report.reportDate),
            ),

            const Divider(height: 40),

            const Text('Mô tả chi tiết:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 7),
            Text(
              report.problemDescription ?? 'Không có mô tả chi tiết.',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: AppStyles.spaceXXXL),
            const Text('Hình ảnh đính kèm:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 7),
            if (report.imageUrl != null) ...[
              const SizedBox(height: AppStyles.spaceS),
              ClipRRect(
                borderRadius: AppStyles.brM,
                child: Image.network(
                  report.imageUrl!,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
            ] else
              const Text('Không có hình ảnh.', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _ReportInfoRow — Widget private, chỉ dùng trong file này.
//
// Đặt tên bắt đầu bằng _ (gạch dưới) = private trong Dart.
// IDE sẽ hiểu widget này không thể dùng ở file khác.
//
// Tại sao không tách ra file riêng?
//   - Widget này chỉ có 1 người dùng duy nhất là DetailReportScreen
//   - Tách ra file riêng (rx_detail_report_info.dart) gây thừa
//   - Đặt ở cuối cùng của cùng file = sạch, đủ tái sử dụng trong màn hình này
// =============================================================================
class _ReportInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color; // Màu cho value — ví dụ: màu mức độ ưu tiên

  const _ReportInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
