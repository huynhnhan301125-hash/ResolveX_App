import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/services/auth_service.dart';

// =============================================================================
// AUTH PROVIDER — Quản lý trạng thái và logic của các chức năng xác thực
//
// Lớp này kế thừa từ [ChangeNotifier] đóng vai trò trung gian để nhận yêu cầu từ UI,
// xử lý dữ liệu và gọi xuống tầng dịch vụ [AuthService].
// Giúp tách biệt hoàn toàn Business Logic ra khỏi giao diện để dễ bảo trì và kiểm thử.
// =============================================================================
class AuthProvider extends ChangeNotifier {
  // AuthService — lớp dịch vụ thực tế để giao tiếp với Supabase.
  // Được truyền vào qua constructor (Dependency Injection) thay vì tự tạo bên trong,
  // giúp dễ dàng thay bằng MockAuthService khi viết test mà không cần sửa Provider.
  final AuthService _authService;

  // Mọi thay đổi bắt buộc phải đi qua các phương thức của lớp này.
  bool _isLoading = false;   // true = đang xử lý yêu cầu, false = rảnh rỗi
  String? _errorMessage;     // Lưu thông báo lỗi gần nhất, null = không có lỗi

  // Constructor nhận AuthService từ bên ngoài truyền vào.
  // Cú pháp `: _authService = authService` là initializer list của Dart —
  // gán giá trị cho biến final TRƯỚC KHI thân constructor chạy.
  AuthProvider({required AuthService authService}) : _authService = authService;

  // Getter — cho phép UI đọc giá trị của biến private nhưng không thể gán lại.
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // 1. ĐĂNG NHẬP
  // ---------------------------------------------------------------------------

  /// Đăng nhập bằng email + mật khẩu.
  ///
  /// Hàm trả về tên [String] route cần điều hướng nếu đăng nhập thành công.
  /// Trả về [null] nếu thất bại (UI sẽ đọc [errorMessage] để xử lý lỗi).
  Future<String?> login({
    required String email,
    required String password,
    required String employeeRoute,
    required String adminRoute,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final employee = await _authService.signIn(email: email, password: password);
      // Provider chỉ trả về tên route để UI tự thực hiện điều hướng.
      // Provider không giữ BuildContext nên không navigate trực tiếp được.
      return employee.userRole.isAdmin ? adminRoute : employeeRoute;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners(); // Thông báo cho UI cập nhật lại errorMessage
      return null;
    } finally {
      // finally luôn chạy dù thành công hay thất bại — đảm bảo loading luôn được tắt
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // 2. QUÊN MẬT KHẨU
  // ---------------------------------------------------------------------------

  /// Gửi email đặt lại mật khẩu cho người dùng.
  ///
  /// Trả về [true] nếu Supabase gửi email thành công, ngược lại trả về [false].
  Future<bool> forgotPassword({required String email}) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // 3. ĐẶT MẬT KHẨU MỚI
  // ---------------------------------------------------------------------------

  /// Đặt mật khẩu mới khi người dùng đã được xác thực (sau khi nhập OTP thành công).
  ///
  /// Trả về [true] nếu cập nhật mật khẩu mới thành công, ngược lại trả về [false].
  Future<bool> updatePassword({required String newPassword}) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.updatePassword(newPassword);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // notifyListeners() — phương thức của ChangeNotifier.
  // Gửi tín hiệu đến toàn bộ widget đang context.watch<AuthProvider>() để chúng rebuild UI.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
