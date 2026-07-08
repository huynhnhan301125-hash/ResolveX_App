import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/utils/app_styles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Dùng AppColors thay vì hardcode Colors.yellow.shade200
        scaffoldBackgroundColor: AppColors.brandBackground,
        dialogTheme: DialogThemeData(backgroundColor: AppColors.brandBackground),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
        ),
      ),
      routerConfig: goRouter,
    );
  }
}
