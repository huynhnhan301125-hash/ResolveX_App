// =============================================================================
// APP THEMES — Cấu hình ThemeData cho Light Mode và Dark Mode
//
// [LÝ DO TÁCH FILE]
// File này tập trung toàn bộ logic cấu hình Theme vào một chỗ duy nhất.
// main.dart chỉ cần gọi AppThemes.light và AppThemes.dark.
// Mọi thay đổi về font, màu nền, shape toàn app → chỉ sửa tại đây.
//
// [FIX #1 — ColorScheme]
// TRƯỚC: dùng ColorScheme.fromSeed(seedColor: ...) — Flutter tự động tính
//   ra toàn bộ bảng màu từ 1 màu hạt giống. Kết quả KHÔNG đảm bảo màu
//   primary luôn là màu vàng thương hiệu chính xác.
//
// SAU: dùng ColorScheme.light() / ColorScheme.dark() — ta kiểm soát 100%
//   màu primary, onPrimary, surface... theo đúng bảng màu thương hiệu.
//
// [FIX #2 — ElevatedButton]
// TRƯỚC: chỉ override shape (bo góc). Màu nền button phụ thuộc vào
//   colorScheme.primary được Flutter tính tự động → có thể bị lệch màu.
//
// SAU: thêm backgroundColor và foregroundColor ép cứng màu thương hiệu,
//   đảm bảo button luôn vàng đúng chuẩn dù colorScheme có thay đổi gì.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/core/theme/app_colors.dart';
import 'package:resolvex_mobile_app/core/theme/app_styles.dart';

abstract class AppThemes {
  // ---------------------------------------------------------------------------
  // LIGHT THEME
  // ---------------------------------------------------------------------------
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.brandBackground,

    // [FIX #1] Thay ColorScheme.fromSeed() bằng ColorScheme.light() để
    // kiểm soát hoàn toàn từng màu sắc trong bảng màu.
    // - primary: màu chủ đạo (ảnh hưởng Button, Checkbox, ProgressIndicator)
    // - onPrimary: màu chữ/icon hiển thị TRÊN nền primary (đen trên nền vàng)
    // - surface: màu nền của Card, BottomSheet, Dialog
    // - onSurface: màu chữ hiển thị TRÊN nền surface
    // - error: màu dùng cho validation lỗi, SnackBar lỗi
    colorScheme: const ColorScheme.light(
      primary: AppColors.brandPrimary,
      onPrimary: AppColors.textPrimary,
      secondary: AppColors.brandDark,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.surfaceWhite,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: Colors.white,
    ),

    // Card: luôn nền trắng, tắt surface tint để không bị pha màu Material 3
    cardTheme: const CardThemeData(
      color: AppColors.surfaceWhite,
      surfaceTintColor: Colors.transparent,
    ),

    // AppBar: nền vàng thương hiệu, chữ đen
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.brandPrimary,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
    ),

    // Dialog: nền trùng với Scaffold để đồng nhất
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.brandBackground,
    ),

    // [FIX #2] Thêm backgroundColor và foregroundColor để ép cứng màu nút.
    // Nếu không có 2 dòng này, Flutter sẽ tự tính màu từ colorScheme
    // và có thể cho ra màu không mong muốn.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,    // Nền nút: vàng thương hiệu
        foregroundColor: AppColors.textPrimary,     // Chữ/icon trên nút: đen
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),  // Bo góc pill
        ),
      ),
    ),

    // TextField: nền trắng, viền vàng chuẩn theo AppColors
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        borderSide: const BorderSide(color: AppColors.brandDark, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        borderSide: const BorderSide(color: AppColors.brandDark, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        borderSide: const BorderSide(color: AppColors.brandDark, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spaceL,
        vertical: AppStyles.spaceL,
      ),
    ),
  );

  // ---------------------------------------------------------------------------
  // DARK THEME
  // ---------------------------------------------------------------------------
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColorsDark.brandBackground,

    // [FIX #1 - Dark] Tương tự light theme nhưng dùng bảng màu AppColorsDark
    // surface dùng màu tối hơn scaffold để tạo chiều sâu (layering)
    colorScheme: const ColorScheme.dark(
      primary: AppColorsDark.brandPrimary,
      onPrimary: AppColorsDark.textPrimary,
      secondary: AppColorsDark.brandDark,
      onSecondary: AppColorsDark.textPrimary,
      surface: AppColorsDark.surfaceWhite,
      onSurface: AppColorsDark.textPrimary,
      error: AppColorsDark.danger,
      onError: Colors.white,
    ),

    // Card dark: nền tối hơn scaffold để tạo cảm giác chiều sâu
    cardTheme: const CardThemeData(
      color: AppColorsDark.surfaceWhite,
      surfaceTintColor: Colors.transparent,
    ),

    // AppBar dark: tối thay vì vàng (vàng trên nền tối trông rất chói)
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: AppColorsDark.textPrimary,
      elevation: 0,
    ),

    // Dialog dark
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColorsDark.surfaceWhite,
    ),

    // [FIX #2 - Dark] Nút ElevatedButton vẫn dùng màu vàng thương hiệu
    // để duy trì nhận diện thương hiệu nhất quán dù đang ở dark mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsDark.brandPrimary,  // Nền nút: vàng thương hiệu
        foregroundColor: AppColors.textPrimary,        // Chữ trên nút: đen (vì nền vàng)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    ),

    // TextField dark: ép nền trắng và viền vàng giống Light Mode theo yêu cầu
    // (TextField có nền trắng giúp người dùng nhận ra vùng nhập liệu rõ hơn)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        borderSide: const BorderSide(color: AppColors.brandDark, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        borderSide: const BorderSide(color: AppColors.brandDark, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusL),
        borderSide: const BorderSide(color: AppColors.brandDark, width: 2.0),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppStyles.spaceL,
        vertical: AppStyles.spaceL,
      ),
    ),

    // BottomAppBar dark
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: AppColorsDark.surfaceWhite,
    ),
  );
}
