
import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/widgets/rx_textfield.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isObscure = true;
  bool isPassword = true;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      // GestureDetector: Widget dùng để nhận diện các thao tác từ người dùng.
      // Ở đây dùng để bắt sự kiện chạm vào vùng trống trên màn hình nhằm ẩn bàn phím (unfocus).

      body: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Text(
                    "ResolveX",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "by HLTN",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  RXTextField(
                    controller: _userNameController,
                    labelText: "Tài khoản",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _userNameController.clear();
                        });
                      },
                      icon: Icon(Icons.clear),
                    ),
                  ),
                  SizedBox(height: 20),
                  RXTextField(
                    controller: _passwordController,
                    labelText: "Mật khẩu",
                    obscure: isObscure,
                    isPassword: isPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isObscure = !isObscure;
                        });
                      },
                      icon: Icon(
                        isObscure ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        context.push('/forgot_password_screen');
                      },
                      child: Text(
                        "Quên mật khẩu?",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/main_emp_screen');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.shade600,
                      ),
                      child: Text(
                        "Đăng nhập",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
