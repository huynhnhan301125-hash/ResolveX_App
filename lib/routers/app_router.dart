import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/screens/auth_screen.dart';
import 'package:resolvex_mobile_app/screens/detail_report_screen.dart';
import 'package:resolvex_mobile_app/screens/forgot_password_screen.dart';
import 'package:resolvex_mobile_app/screens/main_employee_screen.dart';
import 'package:resolvex_mobile_app/screens/update_password_screen.dart';
import 'package:flutter/material.dart';

// Tạo lớp chứa tên đường dấn tránh bị gõ sai
class RoutePaths {
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String updatePassword = '/update-password';
  static const String mainEmployee = '/main-employee';
  static const String detailReport = '/detail-report';
}

final GoRouter goRouter = GoRouter(
  initialLocation: RoutePaths.login,

  routes: [
    GoRoute(
      path: RoutePaths.login,
      name: 'Login',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: RoutePaths.forgotPassword,
      name: 'forgot-password', // Dùng name để điều hướng an toàn hơn
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: RoutePaths.updatePassword,
      name: 'update-password',
      builder: (context, state) {
        final isFromOTP = state.extra as bool? ?? false;
        return UpdatePassword(isFromOTP: isFromOTP);
      },
    ),
    GoRoute(
      path: RoutePaths.mainEmployee,
      name: 'main-employee',
      builder: (context, state) => const MainEmployeeScreen(),
    ),
    GoRoute(
      path: RoutePaths.detailReport,
      name: 'detail-report',
      builder: (context, state) {
        //Ép kiểu an toàn để tránh văng app
        if (state.extra is ReportModel) {
          final report = state.extra as ReportModel;
          return DetailReportScreen(report: report);
        }
        return const Scaffold(
          body: Center(child: Text('Dữ liệu báo cáo bị lỗi!')),
        );
      },
    ),
  ],
  // Thêm trang báo lỗi để app không bi treo nếu lạc đường
  errorBuilder: (context, state) =>
  const Scaffold(body: Center(child: Text('Trang không tồn tại!'))),
);
