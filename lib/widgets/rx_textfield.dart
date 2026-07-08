import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/utils/app_styles.dart';

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
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppStyles.spaceL,
          vertical: AppStyles.spaceL,
        ),
        // Dùng AppStyles.radiusL thay vì magic number 15 — lặp lại 4 lần
        enabledBorder: OutlineInputBorder(
          borderRadius: AppStyles.brL,
          borderSide: BorderSide(width: 1.5, color: AppColors.brandDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppStyles.brL,
          borderSide: const BorderSide(width: 2, color: Colors.black),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppStyles.brL,
          borderSide: const BorderSide(width: 1, color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppStyles.brL,
          borderSide: const BorderSide(width: 2, color: Colors.red),
        ),
      ),
    );
  }
}
