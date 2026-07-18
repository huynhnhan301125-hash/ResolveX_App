// =============================================================================
// APP COLORS — Bảng màu thương hiệu tập trung của ResolveX
//
// [LÝ DO TÁCH FILE]
// Trước đây AppColors, AppColorsDark, AppThemes, AppStyles đều nằm chung trong
// file app_styles.dart. Điều đó vi phạm nguyên tắc SRP (Single Responsibility
// Principle): mỗi file chỉ nên có một nhiệm vụ duy nhất.
//
// File này chỉ làm đúng một việc: định nghĩa bảng màu thô.
// AppThemes (app_themes.dart) sẽ import và sử dụng các màu này.
//
// [LÝ DO DÙNG abstract class]
// abstract class ngăn hoàn toàn việc gọi AppColors() để tạo đối tượng,
// vì các class này chỉ chứa hằng số tĩnh (static const), không có trạng thái.
// Nó tương đương với cách dùng class MyClass { MyClass._(); } nhưng ngắn hơn.
// =============================================================================

import 'package:flutter/material.dart';

// =============================================================================
// LIGHT MODE — Bảng màu giao diện sáng
// Khi cần thay đổi màu thương hiệu, chỉ sửa tại đây.
// =============================================================================
abstract class AppColors {
  /// Màu vàng chủ đạo — dùng cho nút chính, AppBar, FAB (yellow.shade600)
  static const Color brandPrimary = Color(0xFFFDD835);

  /// Màu vàng đậm hơn — dùng cho border TextField, icon active (yellow.shade700)
  static const Color brandDark = Color(0xFFFBC02D);

  /// Màu nền vàng nhạt — dùng cho Scaffold background (yellow.shade200)
  static const Color brandBackground = Color(0xFFFFF9C4);

  /// Màu nền trắng — dùng cho Card, TextField, Container
  static const Color surfaceWhite = Colors.white;

  /// Màu chữ chính trên nền sáng
  static const Color textPrimary = Color(0xDD000000); // Colors.black87

  /// Màu chữ phụ / nhãn trên nền sáng
  static const Color textSecondary = Color(0x8A000000); // Colors.black54

  /// Màu xám nhạt cho viền
  static const Color borderLight = Color(0xFFEEEEEE); // Colors.grey.shade200

  /// Màu xám nền nhẹ
  static const Color surfaceGrey = Color(0xFFFAFAFA); // Colors.grey.shade50

  /// Màu đỏ — dùng cho nút đăng xuất, thông báo lỗi
  static const Color danger = Color(0xFFE53935); // Colors.red.shade600
}

// =============================================================================
// DARK MODE — Bảng màu giao diện tối
// Thiết kế phản chiếu AppColors nhưng phù hợp với nền tối.
// Màu vàng thương hiệu vẫn giữ nguyên để nhận diện thương hiệu nhất quán.
// =============================================================================
abstract class AppColorsDark {
  /// Màu vàng chủ đạo — giữ nguyên để thương hiệu nhất quán
  static const Color brandPrimary = Color(0xFFFDD835);

  /// Màu vàng đậm — dùng cho icon active, border nổi bật
  static const Color brandDark = Color(0xFFFBC02D);

  /// Màu nền tối chính — Scaffold background (không quá đen, tránh mỏi mắt)
  static const Color brandBackground = Color(0xFF121212);

  /// Màu nền Card, Container — tối hơn brandBackground để tạo chiều sâu
  static const Color surfaceWhite = Color(0xFF1E1E1E);

  /// Màu chữ chính trong dark mode
  static const Color textPrimary = Colors.white;

  /// Màu chữ phụ / nhãn trong dark mode
  static const Color textSecondary = Colors.white70;

  /// Màu viền trong dark mode
  static const Color borderLight = Color(0xFF2C2C2C);

  /// Màu nền nhẹ trong dark mode
  static const Color surfaceGrey = Color(0xFF252525);

  /// Màu đỏ — giữ nguyên, đủ nổi bật trên nền tối
  static const Color danger = Color(0xFFE53935);
}
