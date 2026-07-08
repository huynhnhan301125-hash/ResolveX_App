import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/utils/app_styles.dart';
import 'package:resolvex_mobile_app/utils/app_validate.dart';
import 'package:resolvex_mobile_app/widgets/rx_textfield.dart';

class UpdatePasswordScreen extends StatefulWidget {
  final bool isFromOTP;
  const UpdatePasswordScreen({super.key, this.isFromOTP = true});

  @override
  State<StatefulWidget> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _isObscuringOld = true;
  bool _isObscuringNew = true;
  bool _isObscuringConfirm = true;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  /// Helper method: Tạo nút toggle ẩn/hiện mật khẩu.
  /// Tách ra để tránh lặp 3 lần cùng một cấu trúc IconButton (nguyên tắc DRY).
  Widget _buildToggleIcon({required bool isObscure, required VoidCallback onTap}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.spaceM),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Đổi mật khẩu',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: AppStyles.spaceXXXL),

                    // Chỉ hiện field mật khẩu cũ nếu KHÔNG đến từ luồng OTP
                    if (!widget.isFromOTP) ...[
                      RXTextField(
                        controller: _oldPassword,
                        labelText: 'Mật khẩu hiện tại',
                        obscure: _isObscuringOld,
                        isPassword: true,
                        suffixIcon: _buildToggleIcon(
                          isObscure: _isObscuringOld,
                          onTap: () => setState(() => _isObscuringOld = !_isObscuringOld),
                        ),
                        validator: (value) => AppValidate.checkEmpty(value, 'Mật khẩu'),
                      ),
                      const SizedBox(height: AppStyles.spaceXL),
                    ],

                    RXTextField(
                      controller: _newPassword,
                      labelText: 'Mật khẩu mới',
                      obscure: _isObscuringNew,
                      isPassword: true,
                      suffixIcon: _buildToggleIcon(
                        isObscure: _isObscuringNew,
                        onTap: () => setState(() => _isObscuringNew = !_isObscuringNew),
                      ),
                      validator: (value) => AppValidate.checkPassword(value, 'Mật khẩu'),
                    ),
                    const SizedBox(height: AppStyles.spaceXL),

                    RXTextField(
                      controller: _confirmPassword,
                      labelText: 'Xác nhận mật khẩu',
                      obscure: _isObscuringConfirm,
                      isPassword: true,
                      suffixIcon: _buildToggleIcon(
                        isObscure: _isObscuringConfirm,
                        onTap: () => setState(() => _isObscuringConfirm = !_isObscuringConfirm),
                      ),
                      validator: (value) => AppValidate.checkConfirmPassword(
                        _newPassword.text, value, 'Mật khẩu xác nhận',
                      ),
                    ),
                    const SizedBox(height: AppStyles.spaceXXXL),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cập nhật mật khẩu thành công!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Dùng RouteNames.login (chữ thường) — tránh bug case-sensitive
                            context.goNamed(RouteNames.login);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandDark,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
