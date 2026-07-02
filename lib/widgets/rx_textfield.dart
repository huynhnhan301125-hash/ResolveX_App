import 'package:flutter/material.dart';

class RXTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool obscure;
  final bool isPassword;
  final String? Function(String?)? validator; // Thêm validator
  final TextInputType? keyboardType;

  // Update sau
  // final TextInputAction? textInputAction; // Nút hành động trên bàn phím
  // final ValueChanged<String>? onFieldSubmitted; // Sự kiện khi nhấn Enter
  // final ValueChanged<String>? onChanged; // Sự kiện khi chữ thay đổi
  // final FocusNode? focusNode; // Quản lý tiêu điểm (focus)
  // final Iterable<String>? autofillHints; // Gợi ý tự động điền

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
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon,
        // Hiển thị suffixIcon (như icon xóa hoặc hiện pass) 
        // Chúng ta để controller tự quản lý việc hiển thị icon thông qua logic ở màn hình gọi
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(width: 1.5, color: Colors.yellow.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(width: 2, color: Colors.black),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(width: 1, color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(width: 2, color: Colors.red),
        ),
      ),
    );
  }
}
