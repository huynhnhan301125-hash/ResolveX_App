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
// UPDATE PASSWORD SCREEN — Màn hình đổi mật khẩu
//
// Màn hình chịu trách nhiệm nhận mật khẩu cũ (nếu đổi từ cài đặt) và mật khẩu mới,
// thực hiện cập nhật lại mật khẩu thông qua AuthProvider.
// =============================================================================

/// Giao diện chính của màn hình đổi mật khẩu.
class UpdatePasswordScreen extends StatefulWidget {
  final bool isFromOTP;
  const UpdatePasswordScreen({super.key, required this.isFromOTP});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  // GlobalKey<FormState> — khóa định danh duy nhất cho widget Form.
  // Dùng để gọi _formKey.currentState!.validate() kích hoạt validator của tất cả TextField bên trong.
  final _formKey = GlobalKey<FormState>();

  // TextEditingController — bộ điều khiển cho phép đọc và thay đổi nội dung TextField từ code.
  // Phải gọi .dispose() khi widget bị hủy để tránh rò rỉ bộ nhớ (Memory Leak).
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ValueNotifier<T> — hộp chứa giá trị kiểu T, tự động thông báo cho các widget đang lắng nghe
  // khi giá trị thay đổi qua thuộc tính .value. Dùng thay cho setState() để tránh rebuild toàn màn hình.
  // Mỗi ô mật khẩu có một ValueNotifier riêng để toggle độc lập nhau.
  final ValueNotifier<bool> _isObscureOld = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isObscureNew = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isObscureConfirm = ValueNotifier<bool>(true);

  /// Tạo trường nhập liệu mật khẩu với trạng thái ẩn/hiện tương ứng.
  /// Tách thành helper method để tránh lặp cấu trúc ValueListenableBuilder 3 lần (Nguyên lý DRY).
  //
  // GIẢI THÍCH CHI TIẾT HELPER METHOD NÀY:
  // - Tại sao kiểu trả về là Widget? 
  //   Hàm này sinh ra một giao diện (là TextField nhập mật khẩu). Flutter xây dựng giao diện dựa trên
  //   các "Widget" lồng vào nhau. Do đó, hàm này phải trả về kiểu dữ liệu "Widget" để có thể nhét trực tiếp
  //   vào cây Widget chính (trong danh sách con `children` của `Column`).
  // - Cơ chế hoạt động:
  //   Nó nhận vào 4 tham số:
  //     1. controller: Giúp quản lý việc đọc/ghi chữ người dùng nhập vào.
  //     2. labelText: Chuỗi text hiển thị làm nhãn (ví dụ: "Mật khẩu mới").
  //     3. notifier: Hộp chứa trạng thái true/false (ẩn/hiện mật khẩu) tương ứng của ô đó.
  //     4. validator: Hàm kiểm tra xem dữ liệu nhập vào có hợp lệ hay không.
  //   Bằng cách viết này, ta chỉ cần gọi `_buildPasswordField(...)` cho cả 3 ô (mật khẩu cũ, mật khẩu mới,
  //   xác nhận mật khẩu) mà không cần phải copy-paste code dài dòng 3 lần.
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required ValueNotifier<bool> notifier,
    required String? Function(String?) validator,
  }) {
    // ValueListenableBuilder<T> — Widget tự rebuild khi giá trị của ValueNotifier<T> thay đổi.
    // Chỉ rebuild đúng phần widget bên trong builder(), không ảnh hưởng gì đến phần còn lại.
    // Cấu trúc:
    //   valueListenable : ValueNotifier<T>        — nguồn dữ liệu cần lắng nghe
    //   builder         : (context, value, child) — callback được gọi lại mỗi khi value thay đổi
    //     ├── context : BuildContext — context của widget con này
    //     ├── value   : T            — giá trị hiện tại của ValueNotifier (ở đây là bool)
    //     └── child   : Widget?      — widget tĩnh không cần rebuild, dùng _ nếu không cần
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, isObscure, _) {
        return RXTextField(
          controller: controller,
          labelText: labelText,
          obscure: isObscure,
          isPassword: true,
          suffixIcon: IconButton(
            // Đổi .value của ValueNotifier thay vì setState() để chỉ rebuild widget này
            onPressed: () => notifier.value = !notifier.value,
            icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
          ),
          validator: validator,
        );
      },
    );
  }

  /// Xử lý cập nhật mật khẩu thông qua AuthProvider.
  Future<void> _handleUpdatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    // context.read<T>() — lấy instance của T từ Provider MÀ KHÔNG đăng ký lắng nghe.
    // Dùng trong event handler để gọi hàm, tránh gây rebuild widget không cần thiết.
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.updatePassword(
      newPassword: _newPasswordController.text,
    );

    // Bắt buộc kiểm tra mounted sau mỗi lệnh await.
    // Trong thời gian chờ phản hồi từ server, người dùng có thể đã thoát màn hình.
    // Nếu widget đã bị hủy mà vẫn gọi context → crash app.
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.updatePasswordSuccess),
          backgroundColor: Colors.green,
        ),
      );
      // goNamed() — điều hướng và XÓA TOÀN BỘ history navigation.
      // Khác với pushNamed() chỉ thêm vào stack, goNamed() thay thế hoàn toàn,
      // người dùng không thể bấm nút Back quay lại màn hình đổi mật khẩu.
      context.goNamed(RouteNames.login);
    } else {
      final errorMsg = authProvider.errorMessage ?? AppStrings.updatePasswordError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: AppColors.danger),
      );
    }
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
                      AppStrings.updatePasswordTitle,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                    const SizedBox(height: AppStyles.spaceXXXL),

                    // widget.isFromOTP — truy cập thuộc tính isFromOTP từ StatefulWidget cha (UpdatePasswordScreen).
                    // isFromOTP = true  → đến từ luồng OTP, Supabase đã xác thực → không cần nhập mật khẩu cũ
                    // isFromOTP = false → đến từ Settings, cần xác minh mật khẩu cũ trước khi đổi
                    //
                    // GIẢI THÍCH SPREAD OPERATOR (...):
                    // Cú pháp `if (điều_kiện) ...[ phan_tu_1, phan_tu_2 ]` là cách viết đặc biệt của Dart.
                    // Dấu ba chấm (...) giúp mở ngoặc và "trải" các phần tử bên trong danh sách [...] ra ngoài.
                    // Ở đây, nếu `!widget.isFromOTP` là true, nó sẽ chèn trực tiếp `_buildPasswordField` và `SizedBox`
                    // vào danh sách con của `Column` thay vì chèn nguyên một mảng `List<Widget>`, giúp tránh lỗi biên dịch.
                    if (!widget.isFromOTP) ...[
                      _buildPasswordField(
                        controller: _oldPasswordController,
                        labelText: AppStrings.updatePasswordOldLabel,
                        notifier: _isObscureOld,
                        validator: (v) => AppValidate.checkEmpty(v, AppStrings.updatePasswordOldLabel),
                      ),
                      const SizedBox(height: AppStyles.spaceXL),
                    ],
                    _buildPasswordField(
                      controller: _newPasswordController,
                      labelText: AppStrings.updatePasswordNewLabel,
                      notifier: _isObscureNew,
                      validator: (v) => AppValidate.checkPassword(v, AppStrings.updatePasswordNewLabel),
                    ),
                    const SizedBox(height: AppStyles.spaceXL),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      labelText: AppStrings.updatePasswordConfirmLabel,
                      notifier: _isObscureConfirm,
                      validator: (v) => AppValidate.checkConfirmPassword(
                        _newPasswordController.text, v, AppStrings.updatePasswordConfirmLabel,
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
                        // Dùng innerContext thay vì context của màn hình để giới hạn phạm vi rebuild.
                        final isLoading = innerContext.watch<AuthProvider>().isLoading;
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            // isLoading = true → disable nút (null) để tránh bấm nhiều lần trong khi đang xử lý
                            onPressed: isLoading ? null : _handleUpdatePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandDark,
                              foregroundColor: Colors.black,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.black)
                                : const Text(
                                    AppStrings.updatePasswordButton,
                                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _isObscureOld.dispose();    // Giải phóng ValueNotifier để tránh Memory Leak
    _isObscureNew.dispose();
    _isObscureConfirm.dispose();
    super.dispose();
  }
}
