// =============================================================================
// APP STYLES — Design Tokens về bố cục (Layout Tokens)
//
// [LÝ DO TÁCH FILE]
// File này tách ra từ app_styles.dart cũ, chỉ chứa các hằng số bố cục:
//   - BorderRadius (bo góc)
//   - BoxShadow (bóng đổ)
//   - Spacing (khoảng cách)
//
// Màu sắc KHÔNG nằm ở đây → xem app_colors.dart
// Cấu hình ThemeData KHÔNG nằm ở đây → xem app_themes.dart
//
// [LÝ DO DÙNG abstract class]
// abstract class ngăn hoàn toàn việc tạo đối tượng AppStyles(),
// vì tất cả giá trị bên trong đều là static const, không cần instance.
// =============================================================================

import 'package:flutter/material.dart';

abstract class AppStyles {
  // ── Border Radius ───────────────────────────────────────────────────────────
  /// Bo góc nhỏ nhất — dùng cho badge trạng thái, chip mức độ
  static const double radiusXS = 4.0;

  /// Bo góc nhỏ — dùng cho dropdown container trong filter bar
  static const double radiusS = 8.0;

  /// Bo góc chuẩn — dùng cho Card, Button, Setting item, TextField
  static const double radiusM = 12.0;

  /// Bo góc lớn — dùng cho card thông tin profile, select chip mức độ
  static const double radiusL = 15.0;

  /// Bo góc rất lớn — dùng cho card profile settings, picker thời gian
  static const double radiusXL = 16.0;

  /// Bo góc tròn — dùng cho OTP Pin box
  static const double radiusXXL = 20.0;

  // Tiện lợi dùng trực tiếp cho tham số borderRadius (không cần gọi circular())
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
  // Dùng thống nhất cho padding, margin, SizedBox gap trên toàn app.
  static const double spaceXS  = 4.0;
  static const double spaceS   = 8.0;
  static const double spaceM   = 12.0;
  static const double spaceL   = 16.0;
  static const double spaceXL  = 20.0;
  static const double spaceXXL = 24.0;
  static const double spaceXXXL = 30.0;
}
