import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
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
      clipBehavior: Clip.antiAlias,// Giúp các con bên trong bị cắt theo bo góc của Card
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,// Chỉ hiện 1 dòng
                        overflow: TextOverflow.ellipsis,// Nếu dài quá thì hiện dấu ...
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          //const Icon(Icons.meeting_room, size: 16, color: Colors.grey),
                          //const SizedBox(width: 4),
                          // Bọc Expanded để tên phòng dài không làm vỡ Row
                          Expanded(
                              child: Text("Phòng: ${reportModel.problemRoom}",
                              maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Loại: ${reportModel.problemType.label}",
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: reportModel.level.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: reportModel.level.color.withOpacity(0.3))
                        ),
                        child: Text(
                          "Ưu tiên: ${reportModel.level.label}",
                          style: TextStyle(color: reportModel.level.color, fontSize: 12, fontWeight: FontWeight.bold),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        reportModel.status.label,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(reportModel.problemType.icon, size: 40, color: reportModel.problemType.color.withOpacity(0.8)),
                    Text(
                      DateFormat('HH:mm - dd/MM').format(reportModel.reportDate),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
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
