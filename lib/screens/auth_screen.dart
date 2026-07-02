import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/utils/app_validate.dart';
import 'package:resolvex_mobile_app/widgets/rx_textfield.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isObscure = true;

  void _handleLogin() {
    // Kiểm tra tính hợp lệ của Form
    if (_formKey.currentState!.validate()) {
      // Logic giả định: Nếu hợp lệ thì chuyển trang
      context.pushNamed('main-employee');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Form( // Bọc Form ở đây để dùng _formKey
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      "ResolveX",
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Hệ thống báo cáo sự cố",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    RXTextField(
                      controller: _emailController,
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.person),
                      // Thêm validator cho RXTextField (cần cập nhật RXTextField để nhận callback này)
                      validator: (value)=>AppValidate.checkEmail(value, "Email đăng nhập"),
                    ),
                    const SizedBox(height: 20),
                    RXTextField(
                      controller: _passwordController,
                      labelText: "Mật khẩu",
                      obscure: isObscure,
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => isObscure = !isObscure),
                        icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                      ),
                      validator: (value)=>AppValidate.checkEmpty(value, "Mật khẩu"),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.pushNamed('forgot-password',extra: true),
                        child: const Text("Quên mật khẩu?"),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade700,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("ĐĂNG NHẬP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
