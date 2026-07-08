import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/utils/app_styles.dart';
import 'package:resolvex_mobile_app/utils/app_validate.dart';
import 'package:resolvex_mobile_app/widgets/rx_textfield.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // _formKey là mã định danh duy nhất (GlobalKey) để quản lý trạng thái của Form.
  // Nhờ key này ta có thể kích hoạt các hàm validator của toàn bộ các ô nhập liệu bên trong Form.
  final _formKey = GlobalKey<FormState>();

  // Bộ điều khiển (TextEditingController) giúp lắng nghe và lấy nội dung chữ
  // mà người dùng gõ vào ô email và mật khẩu. Cần dispose() khi hủy màn hình để tránh rò rỉ bộ nhớ.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Biến trạng thái ẩn/hiện mật khẩu (true = hiển thị dạng ***, false = hiện rõ chữ)
  bool isObscure = true;

  void _handleLogin() {
    // currentState!.validate(): Kích hoạt toàn bộ hàm validator của các TextFormField con.
    // Nếu tất cả hợp lệ (trả về null) -> hàm validate() sẽ trả về true.
    if (_formKey.currentState!.validate()) {
      // Dùng RouteNames thay vì hardcode String 'main-employee'
      context.pushNamed(RouteNames.mainEmployee);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Khi bấm vào bất kỳ vùng trống nào trên màn hình -> tự động đóng bàn phím ảo (unfocus)
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.spaceXL),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    const Text(
                      'ResolveX',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Hệ thống báo cáo sự cố',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    RXTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.person),
                      validator: (value) => AppValidate.checkEmail(value, 'Email đăng nhập'),
                    ),
                    const SizedBox(height: AppStyles.spaceXL),
                    RXTextField(
                      controller: _passwordController,
                      labelText: 'Mật khẩu',
                      obscure: isObscure,
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => isObscure = !isObscure),
                        icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
                      ),
                      validator: (value) => AppValidate.checkEmpty(value, 'Mật khẩu'),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.pushNamed(RouteNames.forgotPassword),
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ),
                    const SizedBox(height: AppStyles.spaceXXXL),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandDark,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'ĐĂNG NHẬP',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
