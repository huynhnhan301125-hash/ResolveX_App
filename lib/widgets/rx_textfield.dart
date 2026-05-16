
import 'package:flutter/material.dart';

class RXTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final Widget? suffixIcon;
  final bool obscure;
  final String obscuringCharacter;
  final bool isPassword;

  const RXTextField({super.key,
    required this.controller,
    this.labelText = '',
    this.suffixIcon,
    this.obscure = false,
    this.obscuringCharacter = '*',
    this.isPassword=false,
  });

  @override
  State<RXTextField> createState() => RXTextFieldState();
}

class RXTextFieldState extends State<RXTextField> {
  final _focusNode = FocusNode();
  bool _showSuffixIcon = false;

  void _updateSuffixIcon() {
    if(widget.isPassword) {
      if (widget.controller.text.isNotEmpty ) {
        setState(() {
          _showSuffixIcon = true;
        });
      } else {
        setState(() {
          _showSuffixIcon = false;
        });
      }
    }
    else
      {
        if (widget.controller.text.isNotEmpty && _focusNode.hasFocus) {
          setState(() {
            _showSuffixIcon = true;
          });
        } else {
          setState(() {
            _showSuffixIcon = false;
          });
        }
      }
  }

  @override
  void initState() {
    // Gọi hàm khởi tạo của lớp cha để đảm bảo Framework thiết lập đầy đủ các
    // thành phần hệ thống trước khi chạy logic riêng.
    super.initState();
    widget.controller.addListener(() {
      _updateSuffixIcon();
    });
    _focusNode.addListener(() {
      _updateSuffixIcon();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    // Báo cho lớp cha thực hiện dọn dẹp các tài nguyên hệ thống cuối cùng sau khi
    // đã giải phóng các tài nguyên cá nhân.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscure,
      obscuringCharacter: widget.obscuringCharacter,
      focusNode: _focusNode,

      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: _showSuffixIcon ? widget.suffixIcon : null,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide(width: 2.5,color: Colors.yellow.shade500)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide(width: 2.5)),
        floatingLabelBehavior: FloatingLabelBehavior.auto
      ),
    );
  }
}
