import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

// Import theme.dart đã được xoá vì RXTextField không còn hardcode màu nào
// từ AppColors nữa. Mọi màu sắc (label, text, border) đều được kế thừa
// từ inputDecorationTheme và textTheme đã cấu hình sẵn trong AppThemes.
// Xem: lib/core/theme/app_themes.dart — inputDecorationTheme.

class RXTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool obscure;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;

  // Dự kiến mở rộng trong tương lai:
  // final TextInputAction? textInputAction;
  // final ValueChanged<String>? onFieldSubmitted;
  // final ValueChanged<String>? onChanged;
  // final FocusNode? focusNode;
  // final Iterable<String>? autofillHints;

  const RXTextField({
    super.key,
    required this.controller,
    this.labelText = '',
    this.suffixIcon,
    this.prefixIcon,
    this.obscure = false,
    this.isPassword = false,
    this.validator,
    this.keyboardType,
    this.maxLines,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: isPassword ? 1 : maxLines,
      minLines: minLines,
      // Chữ luôn màu đen (textPrimary) vì nền của TextField luôn được ép màu trắng (surfaceWhite) ở cả 2 mode.
      style: const TextStyle(color: AppColors.textPrimary), 
      decoration: InputDecoration(
        labelText: labelText,
        // [FIX] Xoá hardcode labelStyle: TextStyle(color: AppColors.textSecondary).
        // AppColors.textSecondary = black54 — chỉ đúng với light mode.
        // Nay bỏ trống → Flutter kế thừa labelStyle và floatingLabelStyle
        // từ inputDecorationTheme trong AppThemes (đã có [FIX #3]).
        // → Tự động đúng màu cho cả light lẫn dark mode.
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
