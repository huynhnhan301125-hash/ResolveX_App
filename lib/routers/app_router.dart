import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';

// Import từ vị trí mới sau khi tái cấu trúc thư mục
import 'package:resolvex_mobile_app/screens/auth/auth_screen.dart';
import 'package:resolvex_mobile_app/screens/auth/forgot_password_screen.dart';
import 'package:resolvex_mobile_app/screens/auth/update_password_screen.dart';
import 'package:resolvex_mobile_app/screens/report/main_employee_screen.dart';
import 'package:resolvex_mobile_app/screens/report/detail_report_screen.dart';
import 'package:resolvex_mobile_app/screens/report/create_report_screen.dart';

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
}

// =============================================================================
// ROUTE NAMES — Tên route (dùng cho pushNamed() và goNamed())
//
// Phân biệt với RoutePaths:
//   RoutePaths = địa chỉ URL → '/detail-report' (có dấu /)
//   RouteNames = tên định danh → 'detail-report' (không có dấu /)
//
// Lý do cần cả 2 class:
//   - Dùng constant thay vì String thô → IDE báo lỗi ngay nếu gõ sai
//   - Khi đổi tên route, chỉ sửa tại đây, không phải tìm khắp codebase
// =============================================================================
class RouteNames {
  static const String login          = 'login';
  static const String forgotPassword = 'forgot-password';
  static const String updatePassword = 'update-password';
  static const String mainEmployee   = 'main-employee';
  static const String detailReport   = 'detail-report';
  static const String createReport   = 'create-report';
}

final GoRouter goRouter = GoRouter(
  initialLocation: RoutePaths.login,

  routes: [
    GoRoute(
      path: RoutePaths.login,
      name: RouteNames.login,
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: RoutePaths.forgotPassword,
      name: RouteNames.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: RoutePaths.updatePassword,
      name: RouteNames.updatePassword,
      builder: (context, state) {
        final isFromOTP = state.extra as bool? ?? false;
        return UpdatePasswordScreen(isFromOTP: isFromOTP);
      },
    ),
    GoRoute(
      path: RoutePaths.mainEmployee,
      name: RouteNames.mainEmployee,
      builder: (context, state) => const MainEmployeeScreen(),
    ),
    GoRoute(
      path: RoutePaths.detailReport,
      name: RouteNames.detailReport,
      builder: (context, state) {
        if (state.extra is ReportModel) {
          return DetailReportScreen(report: state.extra as ReportModel);
        }
        // Trang dự phòng tránh crash nếu truyền sai kiểu dữ liệu
        return const Scaffold(body: Center(child: Text('Dữ liệu báo cáo bị lỗi!')));
      },
    ),
    GoRoute(
      path: RoutePaths.createReport,
      name: RouteNames.createReport,
      builder: (context, state) => const CreateReportScreen(),
    ),
  ],

  // Trang báo lỗi dự phòng khi điều hướng đến route không tồn tại
  errorBuilder: (context, state) =>
      const Scaffold(body: Center(child: Text('Trang không tồn tại!'))),
);
