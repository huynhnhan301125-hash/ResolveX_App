import 'package:flutter/material.dart';

/// Widget tái sử dụng để hiển thị trạng thái danh sách rỗng (Empty State).
///
/// Được tách ra để tuân thủ nguyên tắc DRY — thay thế các khối
/// [SliverFillRemaining] lặp đi lặp lại ở [ReportListTab] và [ReportHistoryTab].
///
/// Cách dùng:
/// ```dart
/// EmptyStateView(
///   icon: Icons.history_toggle_off,
///   message: 'Lịch sử trống. Chưa có sự cố nào được xử lý',
/// )
/// ```
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String message;

  const EmptyStateView({
    super.key,
    required this.icon,
    this.iconColor,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: iconColor ?? Theme.of(context).iconTheme.color),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
