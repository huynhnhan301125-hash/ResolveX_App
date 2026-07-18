// =============================================================================
// THEME BARREL FILE — Điểm xuất duy nhất của Design System
//
// [MỤC ĐÍCH]
// Thay vì phải viết 3 dòng import ở mỗi file:
//   import '.../core/theme/app_colors.dart';
//   import '.../core/theme/app_styles.dart';
//   import '.../core/theme/app_themes.dart';
//
// Chỉ cần 1 dòng duy nhất:
//   import 'package:resolvex_mobile_app/core/theme/theme.dart';
//
// [CẤU TRÚC DESIGN SYSTEM]
//   app_colors.dart  → AppColors, AppColorsDark (bảng màu)
//   app_styles.dart  → AppStyles (radius, spacing, shadow)
//   app_themes.dart  → AppThemes (ThemeData light & dark)
// =============================================================================

export 'app_colors.dart';
export 'app_styles.dart';
export 'app_themes.dart';
