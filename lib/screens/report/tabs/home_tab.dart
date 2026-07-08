import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/utils/app_styles.dart';
import 'package:resolvex_mobile_app/widgets/rx_container.dart';
import 'package:resolvex_mobile_app/widgets/rx_customscrollview.dart';

class HomeTab extends StatelessWidget {
  final List<ReportModel> listReport;

  const HomeTab({super.key, required this.listReport});

  @override
  Widget build(BuildContext context) {
    final int pendingCount    = listReport.where((r) => r.status.isPending).length;
    final int processingCount = listReport.where((r) => r.status.isProcessing).length;
    final int resolvedCount   = listReport.where((r) => r.status.isResolved).length;
    final List<ReportModel> recentReports = listReport.take(6).toList();

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
                    child: const Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 15),
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Xin chào,', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      Text('Trọng Nhân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
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
            child: Text('Báo cáo gần đây (${recentReports.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  onTap: () => context.pushNamed(RouteNames.detailReport, extra: recentReports[index]),
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
        color: AppColors.surfaceWhite,
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
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}
