import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:resolvex_mobile_app/providers/auth_provider.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/utils/app_strings.dart';
import 'package:resolvex_mobile_app/core/theme/theme.dart';
import 'package:resolvex_mobile_app/utils/app_validate.dart';
import 'package:resolvex_mobile_app/widgets/rx_textfield.dart';

// =============================================================================
// AUTH SCREEN — Màn hình đăng nhập
//
// Màn hình chịu trách nhiệm nhận thông tin đăng nhập của nhân viên, gửi dữ liệu
// xuống [AuthProvider] để kiểm tra, và thực hiện chuyển tiếp màn hình phù hợp.
// =============================================================================

/// Giao diện chính của màn hình đăng nhập.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // GlobalKey quản lý trạng thái và trigger hàm validator của toàn bộ các TextFormField con
  final _formKey = GlobalKey<FormState>();

  // TextEditingController giúp lắng nghe và đọc nội dung người dùng nhập vào ô TextField.
  // Phải gọi .dispose() khi hủy Widget để tránh rò rỉ bộ nhớ (Memory Leak).
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ValueNotifier quản lý trạng thái ẩn/hiện mật khẩu (true = dạng ẩn, false = hiện chữ).
  // Thay thế cho việc dùng setState(), chỉ chạy lại widget bên trong ValueListenableBuilder.
  final ValueNotifier<bool> _isObscure = ValueNotifier<bool>(true);

  /// Xử lý đăng nhập thông qua AuthProvider và điều hướng tương ứng.
  Future<void> _handleLogin() async {
    // currentState!.validate() kích hoạt hàm validator của tất cả TextField con
    if (!_formKey.currentState!.validate()) return;

    // context.read<T>() đọc instance của Provider mà không cần lắng nghe sự thay đổi.
    // Dùng trong callback/event handler để gọi hàm, tránh rebuild Widget không cần thiết.
    final authProvider = context.read<AuthProvider>();
    
    // Giao tiếp với AuthProvider để thực hiện đăng nhập bất đồng bộ
    final targetRoute = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      employeeRoute: RouteNames.mainEmployee,
      adminRoute: RouteNames.mainEmployee, // TODO: Cập nhật route admin sau
    );

    // Bắt buộc kiểm tra mounted trước khi gọi context sau một tác vụ await (bất đồng bộ).
    // Giúp tránh crash app nếu người dùng đã tắt hoặc thoát màn hình trong khi đang tải dữ liệu.
    if (!mounted) return;

    if (targetRoute != null) {
      // Đăng nhập thành công -> chuyển hướng trang
      context.pushNamed(targetRoute);
    } else {
      // Đăng nhập thất bại -> hiển thị SnackBar thông báo lỗi
      final errorMsg = authProvider.errorMessage ?? AppStrings.authLoginError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Đóng bàn phím ảo tự động khi người dùng chạm vào vùng trống ngoài TextField
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
                    // Sử dụng AppStrings thay vì hardcode chuỗi để dễ dàng hỗ trợ đa ngôn ngữ
                    const Text(
                      AppStrings.appName,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppStrings.appTagline,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 40),
                    RXTextField(
                      controller: _emailController,
                      labelText: AppStrings.authEmailLabel,
                      prefixIcon: const Icon(Icons.person),
                      validator: (value) =>
                          AppValidate.checkEmail(value, AppStrings.authEmailLabel),
                    ),
                    const SizedBox(height: AppStyles.spaceXL),
                    
                    // ValueListenableBuilder<T> — Widget tự rebuild khi giá trị của ValueNotifier<T> thay đổi.
                    // Chỉ rebuild đúng phần widget bên trong builder(), không ảnh hưởng gì đến phần còn lại.
                    // Cấu trúc:
                    //   valueListenable : ValueNotifier<T>        — nguồn dữ liệu cần lắng nghe
                    //   builder         : (context, value, child) — callback được gọi lại mỗi khi value thay đổi
                    //     ├── context : BuildContext — context của widget con này
                    //     ├── value   : T            — giá trị hiện tại của ValueNotifier (ở đây là bool)
                    //     └── child   : Widget?      — widget tĩnh không cần rebuild, dùng _ nếu không cần
                    ValueListenableBuilder<bool>(
                      valueListenable: _isObscure,
                      builder: (context, isObscure, _) {
                        return RXTextField(
                          controller: _passwordController,
                          labelText: AppStrings.authPasswordLabel,
                          obscure: isObscure,
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            // Đổi .value của ValueNotifier thay vì setState() để chỉ rebuild widget này
                            onPressed: () => _isObscure.value = !_isObscure.value,
                            icon: Icon(
                              isObscure ? Icons.visibility_off : Icons.visibility,
                            ),
                          ),
                          validator: (value) =>
                              AppValidate.checkEmpty(value, AppStrings.authPasswordLabel),
                        );
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.pushNamed(RouteNames.forgotPassword),
                        child: const Text(AppStrings.authForgotPassword),
                      ),
                    ),
                    const SizedBox(height: AppStyles.spaceXXXL),

                    // Builder — Widget tạo ra một BuildContext con (innerContext) riêng biệt.
                    // Mục đích: context.watch<T>() gọi từ innerContext chỉ ràng buộc rebuild phần widget
                    // bên trong Builder này, không làm chạy lại build() của toàn màn hình.
                    // Cấu trúc:
                    //   builder : (innerContext) — callback nhận BuildContext con, dùng để gọi watch/read
                    Builder(
                      builder: (innerContext) {
                        // context.watch<T>() — đăng ký lắng nghe T, rebuild widget này mỗi khi T thay đổi.
                        // Dùng innerContext (context con của Builder) thay vì context của màn hình
                        // để giới hạn phạm vi rebuild chỉ trong widget Builder này.
                        final isLoading = innerContext.watch<AuthProvider>().isLoading;

                        return SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            // isLoading = true → disable nút (null) để tránh bấm nhiều lần trong khi đang xử lý
                            onPressed: isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandDark,
                              foregroundColor: Colors.black,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.black)
                                : const Text(
                                    AppStrings.authLoginButton,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        );
                      },
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
    _isObscure.dispose(); // Giải phóng ValueNotifier để tránh Memory Leak
    super.dispose();
  }
}
