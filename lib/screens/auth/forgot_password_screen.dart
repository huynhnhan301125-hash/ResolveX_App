import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:resolvex_mobile_app/providers/auth_provider.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/utils/app_strings.dart';
import 'package:resolvex_mobile_app/core/theme/theme.dart';
import 'package:resolvex_mobile_app/utils/app_validate.dart';
import 'package:resolvex_mobile_app/widgets/rx_textfield.dart';

// =============================================================================
// FORGOT PASSWORD SCREEN — Màn hình quên mật khẩu
//
// Màn hình chịu trách nhiệm nhận thông tin email người dùng, yêu cầu gửi mã OTP,
// hiển thị Dialog nhập mã OTP và điều hướng sang trang đổi mật khẩu mới.
// =============================================================================

/// Giao diện chính của màn hình quên mật khẩu.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // GlobalKey<FormState> — khóa định danh duy nhất cho widget Form.
  // Dùng để gọi _formKey.currentState!.validate() kích hoạt validator của tất cả TextField bên trong.
  final _formKey = GlobalKey<FormState>();

  // TextEditingController — bộ điều khiển cho phép đọc và thay đổi nội dung TextField từ code.
  // Phải gọi .dispose() khi widget bị hủy để tránh rò rỉ bộ nhớ (Memory Leak).
  final _emailController = TextEditingController();

  /// Xử lý gửi email quên mật khẩu thông qua AuthProvider.
  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    // context.read<T>() — lấy instance của T từ Provider MÀ KHÔNG đăng ký lắng nghe.
    // Dùng trong event handler để gọi hàm, tránh gây rebuild widget không cần thiết.
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(
      email: _emailController.text.trim(),
    );

    // Bắt buộc kiểm tra mounted sau mỗi lệnh await.
    // Trong thời gian chờ phản hồi từ server, người dùng có thể đã thoát màn hình.
    // Nếu widget đã bị hủy mà vẫn gọi context → crash app.
    if (!mounted) return;

    if (success) {
      // showDialog — mở một hộp thoại phủ lên trên màn hình hiện tại.
      // barrierDismissible: false — ngăn đóng dialog khi bấm ra bên ngoài,
      // buộc người dùng phải tương tác với nút bên trong.
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => OTPDialog(email: _emailController.text.trim()),
      );
    } else {
      final errorMsg = authProvider.errorMessage ?? AppStrings.forgotPasswordError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.forgotPasswordTitle),
        backgroundColor: Colors.transparent,
      ),
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
                      AppStrings.forgotPasswordTitle,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppStyles.spaceXXXL),
                    RXTextField(
                      controller: _emailController,
                      labelText: AppStrings.authEmailLabel,
                      suffixIcon: IconButton(
                        // .clear() là phương thức của TextEditingController — xóa nội dung và tự notify TextField rebuild.
                        // Không cần setState() vì controller đã có cơ chế thông báo riêng.
                        onPressed: _emailController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                      validator: (value) =>
                          AppValidate.checkEmail(value, AppStrings.authEmailLabel),
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
                        // Dùng innerContext thay vì context của màn hình để giới hạn phạm vi rebuild.
                        final isLoading = innerContext.watch<AuthProvider>().isLoading;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            // isLoading = true → disable nút (null) để tránh bấm nhiều lần trong khi đang xử lý
                            onPressed: isLoading ? null : _handleForgotPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandDark,
                              foregroundColor: Colors.black,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.black)
                                : const Text(
                                    AppStrings.forgotPasswordButton,
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    super.dispose();
  }
}

// =============================================================================
// OTP DIALOG — Hộp thoại nhập mã OTP đặt lại mật khẩu
// =============================================================================

/// Hộp thoại cho phép người dùng nhập mã OTP nhận được từ email.
/// Dùng setState() cho bộ đếm thời gian vì đây là trạng thái UI thuần túy,
/// không liên quan đến business logic hay dữ liệu từ server.
class OTPDialog extends StatefulWidget {
  final String email;
  const OTPDialog({super.key, required this.email});

  @override
  State<OTPDialog> createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> {
  int _seconds = 60;   // Số giây đếm ngược còn lại
  bool _canResend = false; // Khi về 0 → true → hiện nút gửi lại

  // Timer? — đối tượng hẹn giờ định kỳ.
  // Khai báo nullable (?) vì chưa khởi tạo ngay mà chỉ tạo trong initState().
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // initState() — chạy MỘT LẦN DUY NHẤT khi widget được gắn vào cây lần đầu.
    // Đây là nơi phù hợp để khởi động các tác vụ ban đầu như timer, fetch API...
    _startTimer();
  }

  @override
  void dispose() {
    // ?. — toán tử null-safe: nếu _timer là null thì bỏ qua, không crash.
    // Bắt buộc hủy timer khi đóng dialog, nếu không timer tiếp tục chạy
    // và gọi setState() trên widget đã bị hủy → crash app.
    _timer?.cancel();
    super.dispose();
  }

  /// Bắt đầu đếm ngược thời gian gửi lại OTP.
  void _startTimer() {
    // Timer.periodic — chạy callback lặp đi lặp lại sau mỗi khoảng thời gian `duration`.
    // Cấu trúc:
    //   duration : Duration   — khoảng thời gian giữa mỗi lần chạy
    //   callback : (timer)    — hàm được gọi mỗi lần, nhận Timer chính nó để có thể tự cancel
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return; // Kiểm tra widget còn tồn tại trước khi gọi setState()
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _canResend = true;
          timer.cancel(); // Dừng timer khi đếm về 0
        }
      });
    });
  }

  /// Xử lý gửi lại mã OTP khi đếm ngược kết thúc.
  void _handleResend() {
    setState(() {
      _seconds = 60;
      _canResend = false;
    });
    _startTimer();
    // TODO: Gọi API thông qua AuthProvider để gửi lại mã OTP thật
  }

  @override
  Widget build(BuildContext context) {
    // PinTheme — đối tượng cấu hình kiểu dáng (appearance) cho mỗi ô nhập OTP trong Pinput.
    final pinTheme = PinTheme(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        boxShadow: AppStyles.shadowElevated,
        borderRadius: AppStyles.brXXL,
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppStyles.brM),
      child: Padding(
        padding: const EdgeInsets.all(AppStyles.spaceM),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisSize: min — Dialog chỉ cao vừa đủ nội dung bên trong, không kéo dài toàn màn hình
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.otpDialogTitle,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: AppStyles.spaceS),
              const Text(AppStrings.otpDialogSubtitle),
              const SizedBox(height: AppStyles.spaceXXXL),
              // Pinput — widget nhập mã PIN/OTP với từng ô riêng biệt.
              // Cấu trúc:
              //   length           : int       — số lượng ô nhập (ở đây là 4 chữ số)
              //   defaultPinTheme  : PinTheme  — kiểu dáng mặc định của ô khi không focus
              //   focusedPinTheme  : PinTheme  — kiểu dáng khi ô đang được focus (viền xanh)
              //   separatorBuilder : (index)   — widget hiển thị giữa các ô (khoảng trắng 15px)
              Pinput(
                length: 4,
                defaultPinTheme: pinTheme,
                focusedPinTheme: pinTheme.copyWith(
                  decoration: pinTheme.decoration?.copyWith(
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                ),
                separatorBuilder: (index) => const SizedBox(width: 15),
              ),
              const SizedBox(height: AppStyles.spaceS),
              TextButton(
                // _canResend = false → onPressed: null → nút bị disabled tự động
                onPressed: _canResend ? _handleResend : null,
                child: Text(
                  _canResend
                      ? AppStrings.otpResend
                      : '${AppStrings.otpResendCountdown} ${_seconds}s',
                ),
              ),
              const SizedBox(height: AppStyles.spaceXXXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng Dialog, xóa khỏi màn hình hiện tại
                    // extra: true — truyền dữ liệu phụ qua Router để UpdatePasswordScreen biết
                    // đây là luồng đến từ OTP (ẩn trường mật khẩu cũ)
                    context.pushNamed(RouteNames.updatePassword, extra: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandDark,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    AppStrings.otpDialogButton,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
