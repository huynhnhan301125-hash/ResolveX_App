// =============================================================================
// THEME STORAGE (INTERFACE / CONTRACT)
//
// Tại sao nằm ở core/storage/ thay vì services/?
//   services/ chỉ dành cho code gọi API/Database từ xa (Supabase).
//   SharedPreferences là bộ nhớ CỤC BỘ trên thiết bị — không phải remote API.
//   → Thuộc tầng hạ tầng (infrastructure), hợp lý hơn khi nằm trong core/.
//
// Tại sao dùng abstract class (interface)?
//   - Đóng vai trò "hợp đồng": quy định các chức năng lưu trữ theme cần có.
//   - ThemeProvider chỉ giao tiếp với interface này, không biết bên dưới dùng gì.
//   - Dễ thay đổi công nghệ lưu trữ (SharedPreferences → Hive/Isar) mà không
//     cần sửa ThemeProvider.
//   - Dễ viết Unit Test bằng cách tạo MockThemeStorage giả lập.
// =============================================================================
abstract class ThemeStorage {
  /// Đọc lựa chọn theme đã lưu từ bộ nhớ cục bộ.
  /// Trả về `true` nếu người dùng chọn dark mode, `false` nếu chọn light mode.
  Future<bool> loadTheme();

  /// Lưu lựa chọn theme của người dùng xuống bộ nhớ cục bộ.
  /// Truyền `isDark = true` để lưu dark mode, `false` để lưu light mode.
  Future<void> saveTheme(bool isDark);
}
