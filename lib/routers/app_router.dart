import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
// [FIX #3] employee_model.dart đã được xóa import vì không còn dùng trực tiếp ở đây.
// Thay vào đó, EmployeeModel được truy cập gián tiếp qua EditReportExtra.

import 'package:resolvex_mobile_app/providers/auth_provider.dart';
import 'package:resolvex_mobile_app/services/auth_service.dart';

// Import từ vị trí mới sau khi tái cấu trúc thư mục
import 'package:resolvex_mobile_app/screens/auth/auth_screen.dart';
import 'package:resolvex_mobile_app/screens/auth/forgot_password_screen.dart';
import 'package:resolvex_mobile_app/screens/auth/update_password_screen.dart';
import 'package:resolvex_mobile_app/screens/main_employee_screen.dart';
import 'package:resolvex_mobile_app/screens/report/detail_report_screen.dart';
import 'package:resolvex_mobile_app/screens/report/create_report_screen.dart';
import 'package:resolvex_mobile_app/screens/report/edit_report_screen.dart';
import 'package:resolvex_mobile_app/providers/report_provider.dart';
import 'package:resolvex_mobile_app/services/report_service.dart';
import 'package:resolvex_mobile_app/models/edit_report_extra.dart';
// [FIX #3] Import class EditReportExtra — thay thế cho Map<String, dynamic> hardcode String.
// Giải thích chi tiết trong file lib/models/edit_report_extra.dart.

// =============================================================================
// ROUTE PATHS — Đường dẫn URL (dùng cho GoRoute(path:) và go() method)
// Luôn bắt đầu bằng dấu /
// =============================================================================
class RoutePaths {
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String updatePassword = '/update-password';
  static const String mainEmployee = '/main-employee';
  static const String detailReport = '/detail-report';
  static const String createReport = '/create-report';
  static const String editReport = '/edit-report';
}

// =============================================================================
// ROUTE NAMES — Tên route (dùng cho pushNamed() và goNamed())
// =============================================================================
class RouteNames {
  static const String login = 'login';
  static const String forgotPassword = 'forgot-password';
  static const String updatePassword = 'update-password';
  static const String mainEmployee = 'main-employee';
  static const String detailReport = 'detail-report';
  static const String createReport = 'create-report';
  static const String editReport = 'edit-report';
}

final GoRouter goRouter = GoRouter(
  initialLocation: RoutePaths.login,

  routes: [
    // =========================================================================
    // NHÓM 1: AUTH ROUTES — Các màn hình xác thực (Đăng nhập, Quên mật khẩu...)
    //
    // Mỗi màn hình auth được bọc ChangeNotifierProvider(AuthProvider) CỤC BỘ.
    // Tại sao cục bộ mà không global?
    //   - Các màn hình auth KHÔNG cần chia sẻ dữ liệu với nhau.
    //   - AuthScreen, ForgotPasswordScreen, UpdatePasswordScreen hoạt động
    //     hoàn toàn độc lập — mỗi màn hình có instance AuthProvider riêng.
    //   - Khi rời khỏi màn hình auth, Provider bị hủy → giải phóng RAM.
    // =========================================================================
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => AuthProvider(authService: AuthService()),
        child: const AuthScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.forgotPassword,
      name: RouteNames.forgotPassword,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => AuthProvider(authService: AuthService()),
        child: const ForgotPasswordScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.updatePassword,
      name: RouteNames.updatePassword,
      builder: (context, state) {
        // state.extra dùng để nhận dữ liệu truyền kèm từ màn hình trước
        final isFromOTP = state.extra as bool? ?? false;
        return ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: AuthService()),
          child: UpdatePasswordScreen(isFromOTP: isFromOTP),
        );
      },
    ),

    // =========================================================================
    // NHÓM 2: REPORT SHELL — Bọc 4 màn hình báo cáo trong 1 ShellRoute
    //
    // TẠI SAO PHẢI DÙNG ShellRoute?
    // ─────────────────────────────
    // ReportProvider giữ danh sách báo cáo (_listReport) — dữ liệu này phải
    // được CHIA SẺ giữa 4 màn hình: MainEmployee, Detail, Create, Edit.
    //
    // Ví dụ luồng xóa báo cáo:
    //   DetailReportScreen gọi removeReportLocally(id)
    //   → Provider cập nhật _listReport
    //   → MainEmployeeScreen (đang watch Provider) tự động rebuild
    //   → Danh sách cập nhật ngay khi pop() về ✅
    //
    // Nếu mỗi route có Provider RIÊNG (giống AuthProvider):
    //   DetailReportScreen xóa trong instance của nó
    //   → MainEmployeeScreen có instance KHÁC → không biết → không cập nhật ❌
    //
    // CÁCH ShellRoute HOẠT ĐỘNG:
    // ─────────────────────────
    // ShellRoute là một "vỏ bọc" (shell) luôn tồn tại trong Widget tree khi
    // người dùng điều hướng giữa các route CON của nó.
    //
    // builder nhận thêm tham số `child` — đây là Widget của route con
    // hiện tại đang hiển thị. Shell chỉ cần truyền child xuống.
    //
    // Sơ đồ Widget tree khi đang ở DetailReportScreen:
    //
    //   ChangeNotifierProvider<ReportProvider>  ← Shell builder (luôn ở đây)
    //     └─ DetailReportScreen                 ← child (route con hiện tại)
    //          └─ context.read<ReportProvider>() ✅ tìm thấy Provider phía trên
    //
    // Sơ đồ Widget tree khi đang ở MainEmployeeScreen:
    //
    //   ChangeNotifierProvider<ReportProvider>  ← Shell builder (vẫn ở đây)
    //     └─ MainEmployeeScreen                 ← child (route con hiện tại)
    //          └─ context.watch<ReportProvider>() ✅ tìm thấy Provider phía trên
    //
    // → Cả 4 màn hình đều dùng CÙNG 1 instance ReportProvider ✅
    //
    // VÒNG ĐỜI (Lifecycle) của ReportProvider:
    //   Tạo ra  → khi người dùng vào /main-employee lần đầu
    //   Tồn tại → trong suốt quá trình dùng các màn hình báo cáo
    //   Hủy bỏ  → khi người dùng đăng xuất (route thoát khỏi ShellRoute)
    //
    // SO SÁNH VỚI GLOBAL (cách cũ dùng MultiProvider trong main.dart):
    //   Global   → ReportProvider sống suốt vòng đời app, kể cả lúc ở Login
    //   ShellRoute → ReportProvider chỉ sống khi đang dùng màn hình báo cáo ✅
    // =========================================================================
    ShellRoute(
      // builder của ShellRoute nhận 3 tham số:
      //   context : BuildContext bình thường
      //   state   : GoRouterState chứa thông tin route hiện tại
      //   child   : Widget của route CON đang active (MainEmployee/Detail/Edit/Create)
      builder: (context, state, child) {
        // Bọc child (màn hình con) trong ChangeNotifierProvider.
        // Nhờ vậy, dù child là màn hình nào trong 4 route bên dưới,
        // nó đều có thể context.read/watch<ReportProvider>() được.
        return ChangeNotifierProvider(
          create: (_) => ReportProvider(reportService: ReportService()),
          child: child, // child = route con đang được hiển thị
        );
      },

      // Danh sách các route CON — đây là 4 màn hình cần dùng chung ReportProvider
      routes: [
        GoRoute(
          path: RoutePaths.mainEmployee,
          name: RouteNames.mainEmployee,
          // Không cần bọc Provider ở đây nữa — ShellRoute đã lo.
          builder: (context, state) => const MainEmployeeScreen(),
        ),
        GoRoute(
          path: RoutePaths.detailReport,
          name: RouteNames.detailReport,
          builder: (context, state) {
            if (state.extra is ReportModel) {
              return DetailReportScreen(report: state.extra as ReportModel);
            }
            return const Scaffold(
              body: Center(child: Text('Dữ liệu báo cáo bị lỗi!')),
            );
          },
        ),
        GoRoute(
          path: RoutePaths.createReport,
          name: RouteNames.createReport,
          builder: (context, state) => const CreateReportScreen(),
        ),
        GoRoute(
          path: RoutePaths.editReport,
          name: RouteNames.editReport,
          builder: (context, state) {
            // [FIX #3 — Type-Safe Route Extra]
            //
            // VẤN ĐỀ CŨ (Map<String, dynamic>):
            //   extra: {'report': r, 'currentEmployee': e} — hardcode String key.
            //   Nếu một ngày nào đó gõ nhầm key ('employee' thay vì 'currentEmployee'),
            //   trình biên dịch (VS Code) KHÔNG phát hiện → app vẫn build thành công,
            //   nhưng khi người dùng bấm nút Edit → nhận null → CRASH 💥 (Runtime Error).
            //
            // GIẢI PHÁP (EditReportExtra — Type-Safe Class):
            //   Kiểm tra kiểu dữ liệu bằng `is` trước khi ép kiểu. Dart đảm bảo
            //   nếu `state.extra is EditReportExtra` — các trưỜng `.report` và
            //   `.currentEmployee` CHẮC CHẮN tồn tại và đúng kiểu, không thể null.
            //   Nếu trưỜng thiếu lúc gọi → VS Code gạch Đỏ ngay khi gõ (Compile Time Error).
            if (state.extra is EditReportExtra) {
              final extra = state.extra as EditReportExtra;
              return EditReportScreen(
                report: extra.report,
                currentEmployee: extra.currentEmployee,
              );
            }
            // Fallback: Hiện màn hình lỗi nếu extra không đúng kiểu
            // (ví dụ: vô tình gời route này mà không truyền EditReportExtra).
            return const Scaffold(
              body: Center(child: Text('Dữ liệu không hợp lệ!')),
            );
          },
        ),
      ],
    ),
  ],

  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Trang không tồn tại!'))),
);
