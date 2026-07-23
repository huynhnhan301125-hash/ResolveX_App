import 'dart:async'; // Cần thiết cho runZonedGuarded
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
//   1. runZonedGuarded     → Bật bộ bắt lỗi Dart tổng (Zone), bọc TOÀN BỘ app
//   2. WidgetsFlutterBinding → cho phép dùng plugin trước runApp
//   3. FlutterError.onError  → Bật bộ bắt lỗi Flutter framework tổng
//   4. dotenv.load           → đọc SUPABASE_URL và SUPABASE_ANON_KEY từ .env
//   5. Supabase.initialize   → kết nối database
//   6. ThemeProvider.load    → đọc lựa chọn theme đã lưu (tránh flash UI)
//   7. runApp                → chạy app với Provider đã sẵn sàng
//
// TẠI SAO CẦN GLOBAL ERROR HANDLING?
//   Nếu một Future nào đó trong app bị lỗi mà không có try/catch bao quanh,
//   lỗi sẽ "bay" ra ngoài mọi Widget → màn hình xám/đỏ hoặc App Force Close.
//   Bộ bắt lỗi tổng ở đây là "lưới an toàn cuối cùng" — nó không thay thế
//   try/catch cục bộ, nhưng đảm bảo KHÔNG CÓ LỖI NÀO ÂM THẦM BIẾN MẤT.
// =============================================================================

void main() {
  // ---------------------------------------------------------------------------
  // TẦNG BẢO VỆ 1: runZonedGuarded — Bắt lỗi Dart không đồng bộ (Async)
  //
  // Dart chia code thành các "Zone" (vùng thực thi). Mặc định, toàn bộ app
  // chạy trong 1 Zone. runZonedGuarded tạo ra một Zone MỚI với hàm onError
  // riêng của nó — giống như bọc toàn bộ App trong một try/catch khổng lồ.
  //
  // Bắt được: lỗi Future không có try/catch, lỗi async/await bị bỏ sót.
  // KHÔNG bắt được: lỗi đồng bộ trong Flutter framework (Flutter có cơ chế
  // riêng là FlutterError.onError bên dưới để xử lý trường hợp đó).
  // ---------------------------------------------------------------------------
  runZonedGuarded(
    () async {
      // Bắt buộc gọi trước khi dùng bất kỳ plugin nào (Supabase, SharedPrefs...)
      // Lý do: các plugin cần giao tiếp với nền tảng (Android/iOS), và lệnh này
      // khởi động "cầu nối" giữa Dart và nền tảng đó.
      WidgetsFlutterBinding.ensureInitialized();

      // -----------------------------------------------------------------------
      // TẦNG BẢO VỆ 2: FlutterError.onError — Bắt lỗi Flutter framework
      //
      // Đây là hook riêng của Flutter để bắt các lỗi xảy ra BÊN TRONG framework:
      //   - Lỗi layout (ví dụ: widget tràn ra ngoài màn hình nghiêm trọng)
      //   - Lỗi trong hàm build() của Widget
      //   - Lỗi trong callback của Flutter (onTap, onChanged...)
      //
      // Mặc định Flutter chỉ in lỗi ra console (chỉ thấy khi debug).
      // Ở đây ta GHI ĐÈ hành vi mặc định để:
      //   1. Vẫn in lỗi ra console như bình thường (dòng presentError)
      //   2. Đồng thời gửi lỗi sang Zone để runZonedGuarded cũng bắt được
      //      → Tất cả lỗi đều tập trung về 1 nơi xử lý duy nhất bên dưới.
      // -----------------------------------------------------------------------
      FlutterError.onError = (FlutterErrorDetails details) {
        // presentError: in lỗi ra console theo định dạng chuẩn của Flutter
        // (giữ nguyên hành vi mặc định, không bỏ mất thông tin debug)
        FlutterError.presentError(details);

        // Ném lỗi vào Zone hiện tại → kích hoạt hàm onError của runZonedGuarded
        // Nhờ vậy, lỗi Flutter framework và lỗi Dart đều được xử lý tập trung
        Zone.current.handleUncaughtError(details.exception, details.stack!);
      };

      // -----------------------------------------------------------------------
      // [FIX #2 — dotenv.load() an toàn]
      //
      // VẤN ĐỀ CŨ: Không có try-catch. Nếu thiếu file .env (ví dụ: quên thêm
      // vào pubspec.yaml assets, hoặc deploy lên CI/CD không đính kèm file),
      // app sẽ crash ngay lập tức với lỗi khó hiểu, không có thông báo gì rõ ràng.
      //
      // FIX: Bọc try-catch riêng cho bước đọc file .env. Khi lỗi xảy ra,
      // ném Exception với hướng dẫn chi tiết để developer biết cách khắc phục.
      // -----------------------------------------------------------------------
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        throw Exception(
          'KHÔNG TÌM THẤY FILE .env!\n'
          'Hãy kiểm tra các bước sau:\n'
          '  1. Tạo file .env ở thư mục GỐC của dự án (cùng cấp pubspec.yaml)\n'
          '  2. Thêm vào pubspec.yaml > flutter > assets: - .env\n'
          '  3. Nội dung file .env phải có:\n'
          '       SUPABASE_URL=https://xxx.supabase.co\n'
          '       SUPABASE_ANON_KEY=eyJ...\n'
          'Chi tiết lỗi kỹ thuật: $e',
        );
      }

      // -----------------------------------------------------------------------
      // [FIX #2 — Kiểm tra null trước khi dùng (thay vì dùng ! force-unwrap)]
      //
      // VẤN ĐỀ CŨ: Dùng dotenv.env['SUPABASE_URL']! với toán tử ! (force-unwrap).
      // Nếu key tồn tại trong .env nhưng bị bỏ trống (ví dụ: SUPABASE_URL=),
      // dotenv trả về null → toán tử ! gây crash với lỗi 'Null check operator'
      // — loại lỗi CỰC KHÓ DEBUG vì thông báo lỗi không nói rõ nguyên nhân.
      //
      // FIX: Đọc giá trị ra biến, kiểm tra null có thông báo rõ ràng trước,
      // rồi mới truyền vào Supabase.initialize().
      // -----------------------------------------------------------------------
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseKey == null) {
        throw Exception(
          'File .env thiếu giá trị bắt buộc!\n'
          'Đảm bảo file .env có ĐỦ và ĐÚNG 2 dòng sau (không được bỏ trống):\n'
          '  SUPABASE_URL=https://xxx.supabase.co\n'
          '  SUPABASE_ANON_KEY=eyJ...\n'
          'Biến bị thiếu: '
          '${supabaseUrl == null ? 'SUPABASE_URL ' : ''}'
          '${supabaseKey == null ? 'SUPABASE_ANON_KEY' : ''}',
        );
      }

      // Khởi tạo kết nối đến Supabase bằng các giá trị đã được kiểm tra an toàn.
      //
      // GIẢI THÍCH VỀ PUBLISHABLE KEY:
      // - url: Địa chỉ Endpoint kết nối tới máy chủ dự án Supabase của bạn.
      // - publishableKey (trước gọi là anonKey): Khóa công khai dùng cho client.
      //   An toàn để đưa vào app vì mọi truy vấn đều phải qua RLS (Row Level Security)
      //   ở Database — RLS quyết định người dùng chỉ xem/sửa được dữ liệu của họ.
      //   KHÔNG được thay bằng service_role key (key đó bỏ qua mọi RLS → rất nguy hiểm).
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseKey,
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
        // ChangeNotifierProvider: bọc ThemeProvider vào gốc Widget tree.
        //
        // ThemeProvider kiểm soát dark/light mode cho TOÀN BỘ app (kể cả màn hình
        // Đăng nhập, Quên mật khẩu...) nên buộc phải ở gốc — không thể cục bộ.
        //
        // ReportProvider KHÔNG còn ở đây nữa. Nó được đặt đúng chỗ trong
        // app_router.dart bằng ShellRoute — chỉ tồn tại khi người dùng đang
        // ở các màn hình báo cáo, tự hủy khi đăng xuất → tiết kiệm RAM.
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider, // Dùng instance đã load sẵn ở trên
          child: const MyApp(),
        ),
      );
    },

    // -------------------------------------------------------------------------
    // HÀM XỬ LÝ LỖI TRUNG TÂM — Chạy khi có lỗi lọt vào Zone
    //
    // Tham số:
    //   error : Object lỗi (có thể là Exception, Error, hoặc bất kỳ object nào)
    //   stack : StackTrace — "dấu vết ngăn xếp" cho biết lỗi xảy ra ở dòng nào
    //
    // Trong dự án thực tế lớn, đây là nơi bạn gọi:
    //   - Firebase Crashlytics: FirebaseCrashlytics.instance.recordError(error, stack)
    //   - Sentry: Sentry.captureException(error, stackTrace: stack)
    //   - v.v.
    //
    // Hiện tại ResolveX chưa tích hợp crash reporting, nên chỉ in ra console.
    // Khi cần thêm Crashlytics sau này, chỉ cần sửa đúng hàm này — 1 chỗ duy nhất.
    // -------------------------------------------------------------------------
    (Object error, StackTrace stack) {
      debugPrint('====================================================');
      debugPrint('[RESOLV EX — LỖI NGHIÊM TRỌNG KHÔNG BẮT ĐƯỢC]');
      debugPrint('Loại lỗi : ${error.runtimeType}');
      debugPrint('Chi tiết  : $error');
      debugPrint('Vị trí    :\n$stack');
      debugPrint('====================================================');

      // TODO: Tích hợp Firebase Crashlytics hoặc Sentry ở đây khi cần
      // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
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
