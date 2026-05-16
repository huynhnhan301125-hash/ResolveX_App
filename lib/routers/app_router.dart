import 'package:go_router/go_router.dart';
import 'package:resolvex_mobile_app/screens/auth_screen.dart';
import 'package:resolvex_mobile_app/screens/detail_report_screen.dart';
import 'package:resolvex_mobile_app/screens/forgot_password_screen.dart';
import 'package:resolvex_mobile_app/screens/main_employee_screen.dart';
import 'package:resolvex_mobile_app/screens/update_password_screen.dart';

// GoRouter: Bộ điều phối trung tâm: Quản lý toàn bộ lộ trình của App
// initiallocation: Điểm dừng chân đầu tiên khi vừa mở App (mặc định là Login)
// routes: Danh sách các tuyến đường hợp lệ trong toàn bộ hệ thống
// GoRoute: Định nghĩa 1 con đường: path là địa chỉ, builder là cái nhà (màn hình)
final GoRouter goRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/login_screen',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/forgot_password_screen',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/update_password_screen',
      builder: (context, state) {
        // Trích xuất "thẻ bài" từ extra, nếu không có (null) thì mặc định là false (luồng đổi pass bình thường)
        final isFromOTP = state.extra as bool? ?? false;
        return UpdatePassword(isFromOTP: isFromOTP);
      },
    ),
    GoRoute(
      path: '/main_emp_screen',
      builder: (context, state) => const MainEmployeeScreen(),
    ),
    GoRoute(
      path: '/-',
      builder: (context, state) => const DetailReportScreen(),
    ),
  ],
  initialLocation: '/login_screen',
);
