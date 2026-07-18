// =============================================================================
// APP STRINGS — Kho tập trung toàn bộ chuỗi văn bản trong ứng dụng
//
// Tại sao cần file này?
//   Vấn đề: Các chuỗi như 'ĐĂNG NHẬP', 'Mật khẩu'... bị rải rác khắp nơi trong UI.
//   Hệ quả:
//     - Muốn đổi ngôn ngữ (Localization) → phải mò từng file, từng dòng.
//     - Muốn đổi tên app → tìm kiếm thủ công, dễ bỏ sót.
//     - Không nhất quán: nơi ghi 'Email', nơi ghi 'email', nơi ghi 'E-mail'.
//
//   Giải pháp: Tất cả chuỗi đặt vào đây, UI chỉ dùng AppStrings.xxx.
//   Sau này nâng cấp lên Flutter Intl (đa ngôn ngữ), chỉ cần sửa file này,
//   không đụng đến bất kỳ Widget nào.
//
// Quy tắc đặt tên:
//   - Dùng camelCase (lowerCamelCase)
//   - Nhóm theo màn hình: auth_*, report_*, settings_*...
//   - Tên phải mô tả nội dung, KHÔNG mô tả vị trí (appName thay vì loginTitle)
// =============================================================================
abstract class AppStrings {
  // ---------------------------------------------------------------------------
  // APP — Thông tin chung của ứng dụng
  // ---------------------------------------------------------------------------

  /// Tên thương hiệu — hiển thị ở màn hình đăng nhập, splash, about
  static const String appName = 'ResolveX';

  /// Slogan / mô tả ngắn của app
  static const String appTagline = 'Hệ thống báo cáo sự cố';

  // ---------------------------------------------------------------------------
  // AUTH SCREEN — Màn hình đăng nhập (auth_screen.dart)
  // ---------------------------------------------------------------------------

  /// Label cho ô nhập Email
  static const String authEmailLabel = 'Email';

  /// Label cho ô nhập Mật khẩu
  static const String authPasswordLabel = 'Mật khẩu';

  /// Chữ trên nút đăng nhập
  static const String authLoginButton = 'ĐĂNG NHẬP';

  /// Link "Quên mật khẩu?" bên dưới form
  static const String authForgotPassword = 'Quên mật khẩu?';

  /// Thông báo lỗi khi đăng nhập sai email hoặc mật khẩu
  static const String authLoginError = 'Sai email hoặc mật khẩu. Vui lòng thử lại!';

  // ---------------------------------------------------------------------------
  // FORGOT PASSWORD SCREEN — Màn hình quên mật khẩu
  // ---------------------------------------------------------------------------

  /// Tiêu đề AppBar và heading của màn hình
  static const String forgotPasswordTitle = 'Xác nhận email';

  /// Chữ trên nút gửi email đặt lại mật khẩu
  static const String forgotPasswordButton = 'Xác nhận';

  /// Thông báo thành công khi gửi email
  static const String forgotPasswordSuccess = 'Email đặt lại mật khẩu đã được gửi!';

  /// Thông báo lỗi khi không gửi được email
  static const String forgotPasswordError = 'Không tìm thấy email này trong hệ thống!';

  // ---------------------------------------------------------------------------
  // OTP DIALOG — Hộp thoại nhập mã OTP (nằm trong forgot_password_screen)
  // ---------------------------------------------------------------------------

  /// Tiêu đề của dialog OTP
  static const String otpDialogTitle = 'Nhập mã OTP';

  /// Hướng dẫn bên dưới tiêu đề
  static const String otpDialogSubtitle = 'Vui lòng nhập mã OTP đã được gửi về email';

  /// Chữ trên nút xác nhận OTP
  static const String otpDialogButton = 'Gửi';

  /// Link gửi lại OTP khi còn đang đếm ngược
  static const String otpResendCountdown = 'Gửi lại mã sau'; // + '${seconds}s'

  /// Link gửi lại OTP khi đã hết thời gian
  static const String otpResend = 'Gửi lại mã';

  // ---------------------------------------------------------------------------
  // UPDATE PASSWORD SCREEN — Màn hình đổi mật khẩu
  // ---------------------------------------------------------------------------

  /// Tiêu đề màn hình
  static const String updatePasswordTitle = 'Đổi mật khẩu';

  /// Label ô mật khẩu hiện tại (chỉ hiện khi đổi từ settings, không phải OTP)
  static const String updatePasswordOldLabel = 'Mật khẩu hiện tại';

  /// Label ô mật khẩu mới
  static const String updatePasswordNewLabel = 'Mật khẩu mới';

  /// Label ô xác nhận mật khẩu
  static const String updatePasswordConfirmLabel = 'Xác nhận mật khẩu';

  /// Chữ trên nút xác nhận
  static const String updatePasswordButton = 'Xác nhận';

  /// Thông báo thành công
  static const String updatePasswordSuccess = 'Đổi mật khẩu thành công!';

  /// Thông báo lỗi
  static const String updatePasswordError = 'Đổi mật khẩu thất bại. Vui lòng thử lại!';
}
