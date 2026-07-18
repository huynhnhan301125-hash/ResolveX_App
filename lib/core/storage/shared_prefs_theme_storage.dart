import 'package:shared_preferences/shared_preferences.dart';
import 'theme_storage.dart';

// =============================================================================
// SHARED PREFERENCES THEME STORAGE (IMPLEMENTATION)
//
// Lớp này là triển khai cụ thể (Concrete Class) của ThemeStorage.
// Thực hiện đọc/ghi theme thực tế xuống bộ nhớ thiết bị qua SharedPreferences.
//
// Nằm trong core/storage/ cùng với interface để dễ tìm và quản lý.
// Sau này nếu đổi sang Hive, chỉ cần tạo thêm `hive_theme_storage.dart`
// cũng implements ThemeStorage — không cần sửa ThemeProvider hay file này.
// =============================================================================
class SharedPrefsThemeStorage implements ThemeStorage {
  // Key dùng để lưu/đọc giá trị theme từ SharedPreferences
  static const String _themePrefKey = 'app_theme_is_dark';

  /// Đọc giá trị bool đã lưu từ SharedPreferences.
  /// Nếu chưa từng lưu (lần đầu mở app), mặc định trả về `false` (light mode).
  @override
  Future<bool> loadTheme() async {
    /*
       [CƠ CHẾ SINGLETON]:
       - Lần đầu gọi: Code Native (Java/Kotlin/Swift) nạp file cấu hình
         (.xml/.plist) từ ổ cứng lên RAM.
       - Các lần sau: Lấy trực tiếp instance đã có trên RAM, không đọc lại ổ cứng.
    */
    final prefs = await SharedPreferences.getInstance();

    /*
       [ĐỌC VÀ TRẢ VỀ GIÁ TRỊ]:
       - Lật đúng trang có nhãn '_themePrefKey' để đọc giá trị true/false.
       - '?? false': Nếu là app mới cài, chưa có dữ liệu (null) → mặc định light mode.
    */
    return prefs.getBool(_themePrefKey) ?? false;
  }

  /// Ghi đè giá trị bool mới của theme vào SharedPreferences.
  @override
  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();

    // Lưu giá trị vào ổ cứng — tồn tại kể cả khi tắt nguồn điện thoại
    await prefs.setBool(_themePrefKey, isDark);
  }
}
