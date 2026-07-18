import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:resolvex_mobile_app/providers/theme_provider.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/core/storage/shared_prefs_theme_storage.dart';
import 'package:resolvex_mobile_app/core/theme/theme.dart';

// =============================================================================
// ENTRY POINT — Điểm khởi đầu của ứng dụng ResolveX
//
// Thứ tự khởi tạo rất quan trọng:
//   1. WidgetsFlutterBinding → cho phép dùng plugin trước runApp
//   2. dotenv.load          → đọc SUPABASE_URL và SUPABASE_ANON_KEY từ .env
//   3. Supabase.initialize  → kết nối database
//   4. ThemeProvider.load   → đọc lựa chọn theme đã lưu (tránh flash UI)
//   5. runApp               → chạy app với Provider đã sẵn sàng
// =============================================================================
void main() async {
  // Bắt buộc để khởi tạo các plugin platform (như Supabase) trước khi chạy app
  WidgetsFlutterBinding.ensureInitialized();

  // Đọc file .env để lấy API Key và URL một cách an toàn
  await dotenv.load(fileName: '.env');

  // Khởi tạo kết nối đến Supabase
  //
  // GIẢI THÍCH VỀ ANONKEY Ở ĐÂY:
  // - url: Địa chỉ Endpoint kết nối tới máy chủ dự án Supabase của bạn.
  // - anonKey (Anonymous / Public Key): Là khóa công khai dùng cho client (App di động). 
  //   Nó an toàn để đưa vào code vì mọi truy vấn gửi từ App lên Supabase bằng key này
  //   đều phải đi qua hệ thống kiểm soát quyền RLS (Row Level Security) ở Database.
  //   Nó chỉ cho phép người dùng xem/sửa những gì họ được phép.
  //   *Lưu ý bảo mật: Không được thay thế bằng service_role key ở đây.*
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Khởi tạo dịch vụ lưu trữ Theme (ở đây dùng SharedPreferences)
  // Sau này có thể đổi thành HiveThemeStorage() mà không cần động đến ThemeProvider
  final themeStorage = SharedPrefsThemeStorage();

  // Tạo ThemeProvider bằng cách "tiêm" (inject) dịch vụ lưu trữ vào
  // Lý do loadTheme trước runApp: nếu load sau khi app chạy, sẽ có hiện tượng "flash" —
  // app hiện màu sáng 1 frame rồi mới đổi sang tối, gây khó chịu
  final themeProvider = ThemeProvider(themeStorage);
  await themeProvider.loadTheme();

  runApp(
    // ChangeNotifierProvider: "bọc" ThemeProvider vào gốc Widget tree.
    // ThemeProvider được đặt ở đây vì nó điều khiển giao diện cho TOÀN BỘ app
    // (cả màn hình đăng nhập, quên mật khẩu, v.v.) nên cần ở gốc.
    //
    // Các Provider chỉ cần cho một số màn hình cụ thể (như AuthProvider, ReportProvider)
    // được đặt cục bộ ngay tại từng Route trong app_router.dart
    // — giải phóng bộ nhớ khi người dùng rời khỏi màn hình đó.
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => themeProvider, // Dùng instance đã load sẵn
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch<T>() = lắng nghe thay đổi, rebuild Widget khi T thay đổi
    // Khác với context.read<T>() = chỉ đọc 1 lần, không rebuild
    // Ở đây cần watch để MaterialApp rebuild khi user đổi theme
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      // LIGHT THEME: định nghĩa trong AppThemes (core/theme/app_themes.dart)
      theme: AppThemes.light,

      // DARK THEME: Flutter tự động áp dụng khi themeMode == ThemeMode.dark
      darkTheme: AppThemes.dark,

      // themeMode: được điều khiển bởi ThemeProvider
      // ThemeMode.light  → luôn dùng theme (light)
      // ThemeMode.dark   → luôn dùng darkTheme (dark)
      // ThemeMode.system → theo cài đặt hệ thống của thiết bị
      themeMode: themeProvider.themeMode,

      routerConfig: goRouter,
    );
  }
}
