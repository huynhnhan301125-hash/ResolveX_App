import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/core/theme/theme.dart';
import 'package:intl/intl.dart';

class RXContainer extends StatelessWidget {
  final ReportModel reportModel;
  final VoidCallback onTap;

  const RXContainer({
    super.key,
    required this.reportModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias, // Cắt các con theo bo góc của Card
      margin: const EdgeInsets.symmetric(
        horizontal: AppStyles.spaceM,
        vertical: AppStyles.spaceS,
      ),
      elevation: 4,
      // Dùng AppStyles.brL thay vì BorderRadius.circular(15)
      shape: RoundedRectangleBorder(borderRadius: AppStyles.brL),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppStyles.brL,
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.spaceM),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Cột trái: Thông tin chính
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Mã NV: ${reportModel.empId}",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppStyles.spaceXS),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Phòng: ${reportModel.problemRoom}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppStyles.spaceXS),
                      Text("Loại: ${reportModel.problemType.label}"),
                      const SizedBox(height: AppStyles.spaceXS),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: reportModel.level.color.withValues(alpha: .1),
                          // Dùng AppStyles.brXS thay vì BorderRadius.circular(4)
                          borderRadius: AppStyles.brXS,
                          border: Border.all(
                            color: reportModel.level.color.withValues(alpha: .3),
                          ),
                        ),
                        child: Text(
                          "Ưu tiên: ${reportModel.level.label}",
                          style: TextStyle(
                            color: reportModel.level.color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Cột phải: Status và Icon
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: reportModel.status.color,
                        // Dùng AppStyles.brM thay vì BorderRadius.circular(12)
                        borderRadius: AppStyles.brM,
                      ),
                      child: Text(
                        reportModel.status.label,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: reportModel.status.textColor),
                      ),
                    ),
                    Icon(
                      reportModel.problemType.icon,
                      size: 40,
                      color: reportModel.problemType.color.withValues(alpha: .8),
                    ),
                    Text(
                      DateFormat('HH:mm - dd/MM').format(reportModel.reportDate),
                      style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
