import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/models/employee_model.dart';
import 'package:resolvex_mobile_app/providers/report_provider.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/core/theme/theme.dart';
import 'package:resolvex_mobile_app/services/auth_service.dart';
import 'package:resolvex_mobile_app/widgets/rx_container.dart';
import 'package:resolvex_mobile_app/widgets/rx_customscrollview.dart';

// =============================================================================
// HOME TAB — Trang chủ, hiện tổng quan và 6 báo cáo gần nhất
//
// Thay đổi kiến trúc (Prop Drilling → Provider):
//   Trước: nhận listReport, onRefresh, onLoadMore, hasMore, isLoadingMore
//          qua constructor (5 props, 3 props không dùng đến).
//   Sau:   không nhận prop nào — tự đọc dữ liệu từ ReportProvider.
//
//   context.watch<ReportProvider>(): đăng ký lắng nghe Provider.
//   Khi ReportProvider gọi notifyListeners(), CHỈ Tab này rebuild (nếu đang hiển thị),
//   thay vì toàn bộ 4 Tab như trước.
// =============================================================================

// [FIX 1] Không còn props nào — HomeTab không nhận tham số nào qua constructor
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  EmployeeModel? _currentEmployee;

  @override
  void initState() {
    super.initState();
    _fetchEmployee();
  }

  Future<void> _fetchEmployee() async {
    final employee = await AuthService().getCurrentEmployee();
    if (mounted) {
      setState(() {
        _currentEmployee = employee;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.watch<ReportProvider>(): lắng nghe toàn bộ ReportProvider.
    // Mỗi khi Provider gọi notifyListeners() (dữ liệu mới, loading đổi,...),
    // widget này sẽ tự rebuild để hiển thị dữ liệu mới nhất.
    final reportProvider = context.watch<ReportProvider>();

    final int pendingCount    = reportProvider.listReport.where((r) => r.status.isPending).length;
    final int processingCount = reportProvider.listReport.where((r) => r.status.isProcessing).length;
    final int resolvedCount   = reportProvider.listReport.where((r) => r.status.isResolved).length;
    final List<ReportModel> recentReports = reportProvider.listReport.take(6).toList();

    return RXCustomScrollView(
      expandedHeight: 120,
      showBackButton: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(top: 40, left: AppStyles.spaceXL, right: AppStyles.spaceXL),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.brandDark,
                    radius: 28,
                    child: const Icon(Icons.person, color: Colors.black, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào,',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColorsDark.textSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _currentEmployee?.fullName ?? 'Đang tải...', 
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColorsDark.textPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(icon: const Icon(Icons.notifications_none, size: 26), onPressed: () {}),
            ],
          ),
        ),
      ),
      sliver: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppStyles.spaceL, vertical: AppStyles.spaceM),
            child: Row(
              children: [
                Expanded(child: _buildStatCard(title: 'Chờ xử lý', count: pendingCount, color: Status.pending.color, icon: Icons.hourglass_empty)),
                const SizedBox(width: AppStyles.spaceS),
                Expanded(child: _buildStatCard(title: 'Đang xử lý', count: processingCount, color: Status.processing.color, icon: Icons.sync)),
                const SizedBox(width: AppStyles.spaceS),
                Expanded(child: _buildStatCard(title: 'Đã xong', count: resolvedCount, color: Status.resolved.color, icon: Icons.check_circle_outline)),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: AppStyles.spaceL, top: AppStyles.spaceS, bottom: AppStyles.spaceS),
            child: Text(
              'Báo cáo gần đây (${recentReports.length})', 
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColorsDark.textPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
        if (recentReports.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_late_outlined, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Chưa có báo cáo nào được tạo', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => RXContainer(
                  reportModel: recentReports[index],
                  onTap: () async {
                    // Lưu provider trước khi await — tránh use_build_context_synchronously
                    final provider = context.read<ReportProvider>();
                    await context.pushNamed(RouteNames.detailReport, extra: recentReports[index]);
                    // Làm mới dữ liệu sau khi quay lại từ màn hình chi tiết.
                    if (mounted) {
                      provider.loadReports(reset: true);
                    }
                  },
                ),
                childCount: recentReports.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required int count, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.spaceM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppStyles.brM,
        boxShadow: AppStyles.shadowLight,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(count.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppStyles.spaceS),
          Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }
}
