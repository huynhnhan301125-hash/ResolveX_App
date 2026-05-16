import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/widgets/rx_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Xác nhận email"),
        backgroundColor: Colors.transparent,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Xác nhận email",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  RXTextField(
                    controller: _emailController,
                    labelText: "Email",
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _emailController.clear();
                        });
                      },
                      icon: Icon(Icons.clear),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return OTPDialog();
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        "Xác nhận",
                        style: TextStyle(
                          color: Colors.white,
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
    _emailController.dispose();
    super.dispose();
  }
}

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
    timer!.cancel();
    super.dispose();
  }

  void startTimer()
  {
    timer = Timer.periodic(const Duration(seconds: 1), (
        timer,
        ) {
      setState(() {
        if (seconds > 0) {
          seconds--;
        } else {
          sendAgain = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final pinTheme = PinTheme(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.2),
            blurRadius: 7,
            spreadRadius: 1,
            offset: Offset(0, 0),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
    );
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Nhập mã OTP",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 10),
              Text("Vui lòng nhập mã OTP đã được gửi về email"),
              SizedBox(height: 30),
              Pinput(
                length: 4,
                defaultPinTheme: pinTheme,
                focusedPinTheme: pinTheme.copyWith(
                  decoration: pinTheme.decoration?.copyWith(
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                ),
                separatorBuilder: (index) {
                  return SizedBox(width: 15);
                },
              ),
              SizedBox(height: 10),
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
                    ? Text("Gửi lại mã")
                    : Text("Gửi lại mã sau ${seconds}s"),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Đóng Dialog trước để trả context về màn hình chính, tránh xung đột điều hướng
                    Navigator.pop(context);
                    // Chuyển sang màn hình cập nhật pass, kèm theo "thẻ bài" extra = true (đi từ luồng OTP)
                    context.push('/update_password_screen',extra: true);},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text(
                    "Gửi",
                    style: TextStyle(
                      color: Colors.white,
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
    );
  }
}
