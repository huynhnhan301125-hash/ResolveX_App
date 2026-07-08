import 'package:flutter/material.dart';

// =============================================================================
// APP COLORS — Bảng màu thương hiệu của ứng dụng
// Tất cả màu sắc dùng trong app phải lấy từ đây.
// Khi cần đổi màu thương hiệu, chỉ cần sửa tại file này.
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

  /// Màu chữ chính
  static const Color textPrimary = Color(0xDD000000); // Colors.black87

  /// Màu chữ phụ / nhãn
  static const Color textSecondary = Color(0x8A000000); // Colors.black54

  /// Màu xám nhạt cho viền
  static const Color borderLight = Color(0xFFEEEEEE); // Colors.grey.shade200

  /// Màu xám nền nhẹ
  static const Color surfaceGrey = Color(0xFFFAFAFA); // Colors.grey.shade50

  /// Màu đỏ — dùng cho nút đăng xuất, lỗi
  static const Color danger = Color(0xFFE53935); // Colors.red.shade600
}

// =============================================================================
// APP STYLES — Hằng số thiết kế (Design Tokens)
// Tập trung: BorderRadius, BoxShadow, Padding chuẩn.
// =============================================================================
abstract class AppStyles {
  // ── Border Radius ───────────────────────────────────────────────────────────
  /// Bo góc nhỏ — dùng cho badge trạng thái, chip mức độ trong rx_container
  static const double radiusXS = 4.0;

  /// Bo góc vừa nhỏ — dùng cho dropdown container trong filter bar
  static const double radiusS = 8.0;

  /// Bo góc chuẩn — dùng cho Card, Button, Setting item, TextField
  static const double radiusM = 12.0;

  /// Bo góc lớn — dùng cho card thông tin profile, select chip mức độ
  static const double radiusL = 15.0;

  /// Bo góc rất lớn — dùng cho card profile settings, picker thời gian
  static const double radiusXL = 16.0;

  /// Bo góc tròn — dùng cho OTP Pin box
  static const double radiusXXL = 20.0;

  // Tiện lợi dùng trực tiếp cho BorderRadius.circular
  static const BorderRadius brXS  = BorderRadius.all(Radius.circular(radiusXS));
  static const BorderRadius brS   = BorderRadius.all(Radius.circular(radiusS));
  static const BorderRadius brM   = BorderRadius.all(Radius.circular(radiusM));
  static const BorderRadius brL   = BorderRadius.all(Radius.circular(radiusL));
  static const BorderRadius brXL  = BorderRadius.all(Radius.circular(radiusXL));
  static const BorderRadius brXXL = BorderRadius.all(Radius.circular(radiusXXL));

  // ── Box Shadow ──────────────────────────────────────────────────────────────
  /// Shadow nhẹ — dùng cho stat card nhỏ (home_tab)
  static const List<BoxShadow> shadowLight = [
    BoxShadow(
      color: Color(0x0D000000), // black 5%
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Shadow vừa — dùng cho card thông tin, profile box (settings_tab)
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x0D000000), // black 5%
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  /// Shadow nổi — dùng cho FAB, OTP pin box
  static const List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: Color(0x33000000), // black 20%
      blurRadius: 7,
      spreadRadius: 1,
    ),
  ];

  // ── Spacing chuẩn ───────────────────────────────────────────────────────────
  static const double spaceXS = 4.0;
  static const double spaceS  = 8.0;
  static const double spaceM  = 12.0;
  static const double spaceL  = 16.0;
  static const double spaceXL = 20.0;
  static const double spaceXXL = 24.0;
  static const double spaceXXXL = 30.0;
}
