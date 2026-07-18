import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:resolvex_mobile_app/models/employee_model.dart';
import 'package:resolvex_mobile_app/core/supabase_client.dart';

// =============================================================================
// AUTH SERVICE — Quản lý toàn bộ việc xác thực người dùng
//
// Tại sao cần class riêng?
//   Thay vì mỗi màn hình tự gọi Supabase.auth, ta gom tất cả logic vào đây.
//   Lợi ích:
//     - Màn hình chỉ cần gọi AuthService().signIn(...) — không cần biết bên trong làm gì
//     - Nếu sau này đổi từ Supabase sang Firebase, chỉ sửa file này, không đụng tới UI
//     - Dễ test hơn vì logic tập trung 1 chỗ
// =============================================================================
class AuthService {
  // ---------------------------------------------------------------------------
  // 1. ĐĂNG NHẬP
  // ---------------------------------------------------------------------------

  /// Đăng nhập bằng email + mật khẩu.
  ///
  /// Trả về [EmployeeModel] chứa đầy đủ thông tin nếu thành công.
  /// Ném ra [AuthException] nếu sai email/mật khẩu, hoặc [Exception] nếu lỗi khác.
  Future<EmployeeModel> signIn({
    required String email,
    required String password,
  }) async {
    // Bước 1: Gọi Supabase Auth để xác thực tài khoản.
    // Supabase sẽ kiểm tra email/password trong hệ thống auth riêng của nó
    // (bảng auth.users — bảng này do Supabase quản lý, ta không thể truy cập trực tiếp).
    final authResponse = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Bước 2: Lấy UUID của người vừa đăng nhập thành công.
    // auth.currentUser sẽ có dữ liệu ngay sau khi signIn thành công.
    // Nếu id == null nghĩa là đăng nhập thất bại theo một cách không rõ ràng → ném lỗi.
    final userId = authResponse.user?.id;
    if (userId == null) {
      throw Exception('Đăng nhập thất bại: Không nhận được thông tin người dùng.');
    }

    // Bước 3: Dùng UUID đó để tra cứu trong bảng 'employees' của ta.
    // Tại sao phải làm bước này?
    //   Vì auth.users chỉ lưu email + id. Các thông tin như fullName, empCode,
    //   department... đều nằm trong bảng employees mà ta tự tạo.
    //   Bảng employees.id là Foreign Key → auth.users.id, nên ta dùng UUID này để JOIN.
    final employeeData = await supabase
        .from('employees')        // Truy vấn bảng employees
        .select()                 // Lấy tất cả các cột
        .eq('id', userId)         // WHERE id = userId (UUID vừa lấy ở Bước 2)
        .single();                // Chỉ lấy 1 hàng. Nếu không có hàng nào → throw Exception

    // Bước 4: Chuyển dữ liệu thô (Map) sang EmployeeModel có kiểu dữ liệu chặt chẽ
    return EmployeeModel.fromMap(employeeData);
  }

  // ---------------------------------------------------------------------------
  // 2. ĐĂNG XUẤT
  // ---------------------------------------------------------------------------

  /// Xóa session hiện tại, người dùng sẽ cần đăng nhập lại.
  ///
  /// Sau khi gọi hàm này, [currentUser] sẽ trả về null.
  Future<void> signOut() async {
    // signOut() xóa JWT token khỏi bộ nhớ của thiết bị.
    // Từ thời điểm này, mọi request gửi lên Supabase sẽ không còn được xác thực.
    await supabase.auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // 3. KIỂM TRA TRẠNG THÁI ĐĂNG NHẬP (dùng cho Splash Screen / Router)
  // ---------------------------------------------------------------------------

  /// Trả về thông tin User hiện tại.
  /// null = chưa đăng nhập hoặc phiên đã hết hạn.
  User? get currentUser => supabase.auth.currentUser;

  /// Kiểm tra nhanh xem có đang đăng nhập không.
  /// Dùng trong Router để quyết định chuyển đến trang Login hay Dashboard.
  bool get isLoggedIn => currentUser != null;

  /// Lấy thông tin Employee của người đang đăng nhập từ database.
  /// Dùng khi cần load lại profile sau khi update.
  Future<EmployeeModel?> getCurrentEmployee() async {
    // Nếu không có session thì trả về null ngay — không cần query
    final userId = currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('employees')
        .select()
        .eq('id', userId)
        .maybeSingle(); // Dùng maybeSingle() thay vì single() để tránh crash nếu không tìm thấy

    // Nếu data == null (không có trong bảng employees) thì trả về null
    if (data == null) return null;
    return EmployeeModel.fromMap(data);
  }

  // ---------------------------------------------------------------------------
  // 4. QUÊN MẬT KHẨU — Gửi email chứa OTP / Reset Link
  // ---------------------------------------------------------------------------

  /// Gửi email đặt lại mật khẩu đến địa chỉ [email].
  ///
  /// Supabase sẽ gửi một email chứa link hoặc OTP tùy theo cấu hình Dashboard.
  /// Ta không cần làm gì thêm sau lệnh này — chỉ cần thông báo user kiểm tra email.
  Future<void> sendPasswordResetEmail(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      // redirectTo là deep link để mở app sau khi user bấm link trong email.
      // Tạm thời để trống, sẽ cấu hình khi setup deep link.
      // redirectTo: 'io.resolvex://reset-password',
    );
  }

  // ---------------------------------------------------------------------------
  // 5. CẬP NHẬT MẬT KHẨU MỚI
  // ---------------------------------------------------------------------------

  /// Đặt mật khẩu mới cho người dùng đang đăng nhập.
  ///
  /// Dùng trong 2 luồng:
  ///   1. Sau khi nhập OTP quên mật khẩu thành công (Supabase tự tạo session tạm)
  ///   2. Đổi mật khẩu từ màn hình Cài đặt (user đang đăng nhập bình thường)
  Future<void> updatePassword(String newPassword) async {
    // updateUser() cập nhật thông tin của user hiện tại trong session.
    // Phải có session hợp lệ thì mới gọi được hàm này.
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. LẮNG NGHE THAY ĐỔI TRẠNG THÁI AUTH (Real-time)
  // ---------------------------------------------------------------------------

  /// Trả về Stream phát ra sự kiện mỗi khi trạng thái đăng nhập thay đổi.
  ///
  /// Ví dụ các sự kiện: signedIn, signedOut, tokenRefreshed, passwordRecovery.
  /// Dùng để tự động điều hướng người dùng mà không cần check thủ công.
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
}
