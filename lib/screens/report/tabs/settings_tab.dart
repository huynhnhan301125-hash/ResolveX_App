import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resolvex_mobile_app/providers/theme_provider.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/core/theme/theme.dart';
import 'package:resolvex_mobile_app/widgets/rx_customscrollview.dart';

// =============================================================================
// SETTINGS TAB — Màn hình cài đặt của ứng dụng
//
// Thay đổi so với trước:
//   - Dark Mode toggle giờ CÓ LOGIC THẬT — kết nối với ThemeProvider
//   - Dùng Consumer<ThemeProvider> để lắng nghe thay đổi theme
//   - Khi user bật/tắt, ThemeProvider lưu vào SharedPreferences tự động
// =============================================================================
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer<ThemeProvider>: lắng nghe ThemeProvider, rebuild phần này khi theme đổi
    // Chỉ bọc phần NHỎ NHẤT cần rebuild thay vì bọc toàn bộ màn hình
    // → tối ưu hiệu năng, tránh rebuild không cần thiết
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Lấy màu sắc đúng theo theme hiện tại
        // Theme.of(context) tự động trả về light/dark ThemeData
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = themeProvider.isDark;

        return RXCustomScrollView(
          expandedHeight: 120,
          showBackButton: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: const EdgeInsets.only(top: 40, left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cài đặt',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    // Màu chữ tự thích nghi theo theme sử dụng AppColors
                    color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          sliver: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppStyles.spaceL, vertical: AppStyles.spaceM),
                child: Container(
                  padding: const EdgeInsets.all(AppStyles.spaceL),
                  decoration: BoxDecoration(
                    // Màu nền card tự thích nghi theo theme
                    color: isDark
                        ? AppColorsDark.surfaceWhite
                        : AppColors.surfaceWhite,
                    borderRadius: AppStyles.brXL,
                    boxShadow: AppStyles.shadowMedium,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.brandDark,
                        radius: 30,
                        child: const Icon(Icons.person,
                            color: Colors.black, size: 32),
                      ),
                      const SizedBox(width: AppStyles.spaceL),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Trọng Nhân',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColorsDark.textPrimary : AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            Text('Mã NV: NV1003',
                                style: TextStyle(
                                    color: isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
                                    fontSize: 13)),
                            Text('Bộ phận: Kỹ thuật viên',
                                style: TextStyle(
                                    color: isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppStyles.spaceL, vertical: AppStyles.spaceS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tài khoản & Bảo mật',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        // Màu label section tự thích nghi
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: AppStyles.spaceS),
                    _buildSettingItem(
                      context,
                      icon: Icons.lock_outline,
                      title: 'Đổi mật khẩu',
                      isDark: isDark,
                      onTap: () =>
                          context.pushNamed(RouteNames.updatePassword),
                    ),
                    _buildSettingItem(
                      context,
                      icon: Icons.notifications_none,
                      title: 'Cấu hình thông báo',
                      isDark: isDark,
                      trailing: Switch(
                        value: true,
                        onChanged: (val) {},
                        // Màu thumb khi Switch bật — dùng màu thương hiệu
                        activeThumbColor: AppColors.brandDark,
                      ),
                    ),
                    const SizedBox(height: AppStyles.spaceL),
                    Text(
                      'Hệ thống',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: AppStyles.spaceS),

                    // ── DARK MODE TOGGLE — Đây là phần có logic thật ──────────
                    _buildSettingItem(
                      context,
                      icon: isDark
                          ? Icons.dark_mode        // Icon mặt trăng khi đang tối
                          : Icons.light_mode,      // Icon mặt trời khi đang sáng
                      title: isDark ? 'Chế độ tối (Bật)' : 'Chế độ tối (Tắt)',
                      isDark: isDark,
                      trailing: Switch(
                        // value: liên kết với trạng thái thật trong ThemeProvider
                        value: themeProvider.isDark,

                        // onChanged: gọi toggleTheme() khi user bật/tắt
                        // Hàm này sẽ:
                        //   1. Đổi _themeMode trong ThemeProvider
                        //   2. Gọi notifyListeners() → toàn app rebuild với theme mới
                        //   3. Lưu lựa chọn vào SharedPreferences
                        onChanged: (_) => themeProvider.toggleTheme(),

                        activeThumbColor: AppColors.brandDark,
                        // Màu khi tắt: mờ hơn trong dark mode
                        inactiveThumbColor: isDark
                            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    // ────────────────────────────────────────────────────────

                    _buildSettingItem(
                      context,
                      icon: Icons.info_outline,
                      title: 'Về ứng dụng',
                      subtitle: 'Phiên bản 1.0.0',
                      isDark: isDark,
                    ),
                    const SizedBox(height: AppStyles.spaceXXL),
                    _buildLogoutButton(context, colorScheme),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Widget helper để tạo từng dòng cài đặt.
  /// [isDark] được truyền vào để điều chỉnh màu sắc theo theme hiện tại.
  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      // Viền card thích nghi theo theme
      shape: RoundedRectangleBorder(
        borderRadius: AppStyles.brM,
        side: BorderSide(
          color: isDark ? AppColorsDark.borderLight : AppColors.borderLight,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: AppStyles.spaceXS),
      child: ListTile(
        leading: Icon(
          icon,
          // Icon màu vàng trong cả 2 mode để nhất quán thương hiệu
          color: AppColors.brandDark,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? Icon(
          Icons.chevron_right,
          color: isDark ? Colors.white38 : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  /// Nút đăng xuất — nổi bật màu đỏ trong cả 2 theme
  Widget _buildLogoutButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.goNamed(RouteNames.login),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Đăng xuất',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: AppStyles.brM),
        ),
      ),
    );
  }
}
