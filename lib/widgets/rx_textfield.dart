import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/core/theme/theme.dart';

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
      style: const TextStyle(color: AppColors.textPrimary), // Chữ đen trên nền trắng
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        errorBorder: OutlineInputBorder(
          borderRadius: AppStyles.brL,
          borderSide: const BorderSide(width: 1.5, color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppStyles.brL,
          borderSide: const BorderSide(width: 2, color: AppColors.danger),
        ),
      ),
    );
  }
}
