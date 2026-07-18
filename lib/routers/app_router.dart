import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resolvex_mobile_app/models/employee_model.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';

import 'package:resolvex_mobile_app/providers/auth_provider.dart';
import 'package:resolvex_mobile_app/providers/report_provider.dart';
import 'package:resolvex_mobile_app/services/auth_service.dart';
import 'package:resolvex_mobile_app/services/report_service.dart';

// Import từ vị trí mới sau khi tái cấu trúc thư mục
import 'package:resolvex_mobile_app/screens/auth/auth_screen.dart';
import 'package:resolvex_mobile_app/screens/auth/forgot_password_screen.dart';
import 'package:resolvex_mobile_app/screens/auth/update_password_screen.dart';
import 'package:resolvex_mobile_app/screens/main_employee_screen.dart';
import 'package:resolvex_mobile_app/screens/report/detail_report_screen.dart';
import 'package:resolvex_mobile_app/screens/report/create_report_screen.dart';
import 'package:resolvex_mobile_app/screens/report/edit_report_screen.dart';

// =============================================================================
// ROUTE PATHS — Đường dẫn URL (dùng cho GoRoute(path:) và go() method)
// Luôn bắt đầu bằng dấu /
// =============================================================================
class RoutePaths {
  static const String login          = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String updatePassword = '/update-password';
  static const String mainEmployee   = '/main-employee';
  static const String detailReport   = '/detail-report';
  static const String createReport   = '/create-report';
  static const String editReport     = '/edit-report';
}

// =============================================================================
// ROUTE NAMES — Tên route (dùng cho pushNamed() và goNamed())
// =============================================================================
class RouteNames {
  static const String login          = 'login';
  static const String forgotPassword = 'forgot-password';
  static const String updatePassword = 'update-password';
  static const String mainEmployee   = 'main-employee';
  static const String detailReport   = 'detail-report';
  static const String createReport   = 'create-report';
  static const String editReport     = 'edit-report';
}

final GoRouter goRouter = GoRouter(
  initialLocation: RoutePaths.login,

  routes: [
    // =========================================================================
    // ĐỊNH NGHĨA CÁC ĐƯỜNG DẪN (ROUTES)
    //
    // GIẢI THÍCH VỀ CÁC THUỘC TÍNH TRONG GOROUTE:
    // - builder: (context, state) => Widget
    //   Đây là hàm callback của GoRouter. Nó được gọi khi người dùng chuyển hướng
    //   đến một đường dẫn (Path). Hàm này nhận vào `context` của app và `state` của route
    //   (chứa thông tin như các tham số truyền qua URL hoặc dữ liệu phụ `extra`).
    //   Nó trả về Widget đại diện cho màn hình sẽ hiển thị.
    //
    // - ChangeNotifierProvider:
    //   Đây là một widget của package `provider`. Nó được dùng để khởi tạo và cung cấp
    //   một State/Logic Controller (ở đây là AuthProvider) cho màn hình con của nó.
    //   * create: (context) => T
    //     Hàm khởi tạo đối tượng Provider. Nó chỉ chạy ĐÚNG 1 LẦN khi màn hình được tạo.
    //     Ở đây ta dùng `create: (_) => AuthProvider(...)` (dấu `_` thay cho `context` vì ta
    //     không dùng đến biến `context` này).
    //   * child: Widget
    //     Màn hình con thực tế được hiển thị (ví dụ: AuthScreen). Màn hình này cùng với
    //     tất cả các widget con của nó sẽ có quyền truy cập và lắng nghe AuthProvider.
    //
    // - Tại sao các màn hình auth lại được bọc ChangeNotifierProvider ở đây?
    //   Bởi vì AuthProvider chỉ cần thiết cho các màn hình đăng nhập, quên mật khẩu và 
    //   đổi mật khẩu. Bọc cục bộ ở từng Route giúp giải phóng bộ nhớ (hủy AuthProvider) 
    //   khi người dùng rời khỏi các trang này, thay vì đặt global trong main.dart.
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
    GoRoute(
      path: RoutePaths.mainEmployee,
      name: RouteNames.mainEmployee,
      // ReportProvider được bọc cục bộ ở đây — đúng kiến trúc vì:
      //   - ReportProvider chỉ cần cho MainEmployeeScreen và 3 Tab bên trong.
      //   - Khi người dùng đăng xuất (rời khỏi mainEmployee route),
      //     Provider bị hủy tự động — giải phóng bộ nhớ.
      //   Tương tự cách AuthProvider được bọc cục bộ cho các màn hình auth.
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => ReportProvider(reportService: ReportService()),
        child: const MainEmployeeScreen(),
      ),
    ),
    GoRoute(
      path: RoutePaths.detailReport,
      name: RouteNames.detailReport,
      builder: (context, state) {
        if (state.extra is ReportModel) {
          return DetailReportScreen(report: state.extra as ReportModel);
        }
        return const Scaffold(body: Center(child: Text('Dữ liệu báo cáo bị lỗi!')));
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
        if (state.extra is Map<String, dynamic>) {
          final extra = state.extra as Map<String, dynamic>;
          final report = extra['report'] as ReportModel?;
          final employee = extra['currentEmployee'] as EmployeeModel?;

          if (report != null && employee != null) {
            return EditReportScreen(
              report: report,
              currentEmployee: employee,
            );
          }
        }
        return const Scaffold(
          body: Center(child: Text('Dữ liệu không hợp lệ!')),
        );
      },
    ),
  ],

  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Trang không tồn tại!'))),
);
