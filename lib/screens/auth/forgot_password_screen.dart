import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/utils/app_styles.dart';
import 'package:resolvex_mobile_app/utils/app_validate.dart';
import 'package:resolvex_mobile_app/widgets/rx_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận email'),
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
                      'Xác nhận email',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppStyles.spaceXXXL),
                    RXTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _emailController.clear()),
                        icon: const Icon(Icons.clear),
                      ),
                      validator: (value) => AppValidate.checkEmail(value, 'Email'),
                    ),
                    const SizedBox(height: AppStyles.spaceXXXL),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            showDialog(
                              context: context,
                              builder: (context) => const OTPDialog(),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandDark,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'Xác nhận',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
    super.dispose();
  }
}

// =============================================================================
// OTP Dialog — Đặt cùng file vì chỉ được dùng bởi ForgotPasswordScreen
// Đây là ví dụ của "widget private trong cùng file" mà không cần tách file riêng.
// =============================================================================
class OTPDialog extends StatefulWidget {
  const OTPDialog({super.key});

  @override
  State<StatefulWidget> createState() => OTPDialogState();
}

class OTPDialogState extends State<OTPDialog> {
  int seconds = 60;
  bool sendAgain = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel(); // Dùng ?. thay ! để tránh null crash
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (seconds > 0) {
            seconds--;
          } else {
            sendAgain = true;
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Nhập mã OTP',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: AppStyles.spaceS),
              const Text('Vui lòng nhập mã OTP đã được gửi về email'),
              const SizedBox(height: AppStyles.spaceXXXL),
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
                onPressed: sendAgain
                    ? () {
                        setState(() {
                          seconds = 60;
                          sendAgain = false;
                        });
                        startTimer();
                      }
                    : null,
                child: sendAgain
                    ? const Text('Gửi lại mã')
                    : Text('Gửi lại mã sau ${seconds}s'),
              ),
              const SizedBox(height: AppStyles.spaceXXXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng Dialog
                    context.pushNamed(RouteNames.updatePassword, extra: true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandDark,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Gửi',
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
