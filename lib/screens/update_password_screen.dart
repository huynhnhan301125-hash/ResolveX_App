
import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/utils/app_validate.dart';
import 'package:resolvex_mobile_app/widgets/rx_textfield.dart';

class UpdatePassword extends StatefulWidget {
  final bool isFromOTP;
  const UpdatePassword({super.key, this.isFromOTP = true});

  @override
  State<StatefulWidget> createState() => UpdatePasswordScreen();
}

class UpdatePasswordScreen extends State<UpdatePassword> {
  final _formKey=GlobalKey<FormState>();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _isObscuring = true;

  @override
  void dispose()
  {

    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: GestureDetector(
        /*Nó biến toàn bộ vùng diện tích của Widget
        (kể cả những chỗ trống/trong suốt) trở nên "đặc" đối với các cú chạm */
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Đổi mật khẩu",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    SizedBox(height: 30),
                    if (!widget.isFromOTP)
                      RXTextField(
                        controller: _oldPassword,
                        labelText: "Mật khẩu hiện tại",
                        obscure: _isObscuring,
                        isPassword: true,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isObscuring = !_isObscuring;
                            });
                          },
                          icon: _isObscuring
                              ? Icon(Icons.visibility_off)
                              : Icon(Icons.visibility),
                        ),
                        validator: (value)=>AppValidate.checkEmpty(value, "Mật khẩu"),
                      ),
                    SizedBox(height: 20),
                    RXTextField(
                      controller: _newPassword,
                      labelText: "Mật khẩu mới",
                      obscure: _isObscuring,
                      isPassword: true,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isObscuring = !_isObscuring;
                          });
                        },
                        icon: _isObscuring
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.visibility),
                      ),
                      validator: (value)=>AppValidate.checkPassword(value, "Mật khẩu"),
                    ),
                    SizedBox(height: 20),
                    RXTextField(
                      controller: _confirmPassword,
                      labelText: "Xác nhận mật khẩu",
                      obscure: _isObscuring,
                      isPassword: true,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isObscuring = !_isObscuring;
                          });
                        },
                        icon: _isObscuring
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.visibility),
                      ),
                      validator: (value)=>AppValidate.checkConfirmPassword(_newPassword.text, value, "Mật khẩu xác nhận"),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: Text(
                        "Xác nhận",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
