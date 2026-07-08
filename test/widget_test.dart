// This is a basic Flutter widget test for ResolveX App.
// Antigravity: Đã viết lại file test này để kiểm tra đúng giao diện đăng nhập của ResolveX thay vì dự án Counter mặc định.

import 'package:flutter_test/flutter_test.dart';
import 'package:resolvex_mobile_app/main.dart';

void main() {
  testWidgets('ResolveX App login screen smoke test', (WidgetTester tester) async {
    // Build app ResolveX và kích hoạt một frame.
    await tester.pumpWidget(const MyApp());

    // Kiểm tra xem các văn bản giao diện đăng nhập có hiển thị đúng không.
    expect(find.text('ResolveX'), findsOneWidget);
    expect(find.text('Hệ thống báo cáo sự cố'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
    expect(find.text('ĐĂNG NHẬP'), findsOneWidget);
  });
}
