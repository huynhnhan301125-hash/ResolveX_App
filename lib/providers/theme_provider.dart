import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/core/storage/theme_storage.dart';

// =============================================================================
// THEME PROVIDER — Quản lý trạng thái sáng/tối của toàn bộ ứng dụng
//
// Lớp này chịu trách nhiệm DUY NHẤT là quản lý trạng thái hiển thị của UI
// (ThemeMode) và thông báo cho UI vẽ lại khi theme thay đổi (SRP).
//
// Nhận ThemeStorage (interface trong core/storage/) qua Constructor
// → Dependency Injection: Provider không biết bên dưới dùng SharedPreferences,
//   Hive hay gì khác — chỉ biết giao tiếp qua interface ThemeStorage.
//
// Ưu điểm:
//   - Tách biệt hoàn toàn phần UI và phần lưu trữ cục bộ.
//   - Dễ viết Unit Test bằng cách truyền vào MockThemeStorage giả lập.
//   - Dễ đổi thư viện lưu trữ (SharedPreferences → Hive) mà không sửa file này.
// =============================================================================
class ThemeProvider extends ChangeNotifier {
  // Nhận vào dạng interface (ThemeStorage) để lỏng liên kết — Decoupling
  final ThemeStorage _storage;

  // Trạng thái mặc định ban đầu trước khi load dữ liệu lên
  ThemeMode _themeMode = ThemeMode.light;

  // Constructor nhận vào instance lưu trữ để sử dụng
  ThemeProvider(this._storage);

  // Getter: cho phép Widget đọc themeMode hiện tại
  ThemeMode get themeMode => _themeMode;

  // Getter tiện lợi: trả về true nếu đang ở chế độ tối
  bool get isDark => _themeMode == ThemeMode.dark;

  // ---------------------------------------------------------------------------
  // 1. TẢI THEME ĐÃ LƯU KHI KHỞI ĐỘNG APP
  // ---------------------------------------------------------------------------

  /// Đọc lựa chọn theme đã lưu từ bộ nhớ thông qua `_storage`.
  Future<void> loadTheme() async {
    // Gọi phương thức từ interface, không cần biết bên dưới chạy thư viện gì
    final bool isDarkSaved = await _storage.loadTheme();

    // Chuyển đổi dữ liệu bool thành ThemeMode enum tương ứng
    _themeMode = isDarkSaved ? ThemeMode.dark : ThemeMode.light;

    // Thông báo cho các widget đang lắng nghe (ví dụ MaterialApp) rebuild giao diện
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 2. ĐỔI THEME (TOGGLE)
  // ---------------------------------------------------------------------------

  /// Đổi qua lại giữa Light và Dark Mode, sau đó lưu trạng thái mới.
  Future<void> toggleTheme() async {
    // Đổi ngược lại trạng thái hiện tại
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;

    // Cập nhật UI ngay lập tức để tạo cảm giác mượt mà (Optimistic Update)
    notifyListeners();

    // Lưu lựa chọn mới chạy ngầm bất đồng bộ xuống bộ nhớ cục bộ
    await _storage.saveTheme(isDark);
  }

  // ---------------------------------------------------------------------------
  // 3. ĐẶT THEME CỤ THỂ
  // ---------------------------------------------------------------------------

  /// Đặt theme về một giá trị cụ thể (light hoặc dark).
  Future<void> setTheme(ThemeMode mode) async {
    if (_themeMode == mode) return; // Không thay đổi thì không làm gì cả

    _themeMode = mode;
    notifyListeners();

    // Lưu trạng thái theme cụ thể xuống bộ nhớ cục bộ
    await _storage.saveTheme(mode == ThemeMode.dark);
  }
}
