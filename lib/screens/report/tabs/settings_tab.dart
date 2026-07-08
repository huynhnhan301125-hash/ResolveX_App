import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/utils/app_styles.dart';
import 'package:resolvex_mobile_app/widgets/rx_customscrollview.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return RXCustomScrollView(
      expandedHeight: 120,
      showBackButton: false,
      flexibleSpace: const FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.only(top: 40, left: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Cài đặt', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),
        ),
      ),
      sliver: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.spaceL, vertical: AppStyles.spaceM),
            child: Container(
              padding: const EdgeInsets.all(AppStyles.spaceL),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: AppStyles.brXL,
                boxShadow: AppStyles.shadowMedium,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.brandDark,
                    radius: 30,
                    child: const Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: AppStyles.spaceL),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Trọng Nhân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Mã NV: NV1003', style: TextStyle(color: Colors.black54, fontSize: 13)),
                        Text('Bộ phận: Kỹ thuật viên', style: TextStyle(color: Colors.black54, fontSize: 13)),
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
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.spaceL, vertical: AppStyles.spaceS),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tài khoản & Bảo mật', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: AppStyles.spaceS),
                _buildSettingItem(context, icon: Icons.lock_outline, title: 'Đổi mật khẩu', onTap: () => context.pushNamed(RouteNames.updatePassword)),
                _buildSettingItem(
                  context,
                  icon: Icons.notifications_none,
                  title: 'Cấu hình thông báo',
                  trailing: Switch(value: true, onChanged: (val) {}, activeThumbColor: AppColors.brandDark),
                ),
                const SizedBox(height: AppStyles.spaceL),
                const Text('Hệ thống', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: AppStyles.spaceS),
                _buildSettingItem(
                  context,
                  icon: Icons.dark_mode_outlined,
                  title: 'Chế độ tối (Dark Mode)',
                  trailing: Switch(value: false, onChanged: (val) {}, activeThumbColor: AppColors.brandDark),
                ),
                _buildSettingItem(context, icon: Icons.info_outline, title: 'Về ứng dụng', subtitle: 'Phiên bản 1.0.0'),
                const SizedBox(height: AppStyles.spaceXXL),
                _buildLogoutButton(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(BuildContext context, {required IconData icon, required String title, String? subtitle, Widget? trailing, VoidCallback? onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppStyles.brM, side: BorderSide(color: AppColors.borderLight)),
      margin: const EdgeInsets.symmetric(vertical: AppStyles.spaceXS),
      child: ListTile(
        leading: Icon(icon, color: AppColors.brandDark),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.goNamed(RouteNames.login),
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.danger,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: AppStyles.brM),
        ),
      ),
    );
  }
}
