import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:intl/intl.dart';
import '../widgets/rx_detail_report_info.dart';

class DetailReportScreen extends StatelessWidget {
  final ReportModel report;

  const DetailReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết báo cáo #${report.reportId}"),
        backgroundColor: Colors.yellow.shade600,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trạng thái
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: report.status.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  report.status.label,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Thông tin chính
            RXDetailReportInfo(icon:  Icons.room,label:  "Phòng:",value:  report.problemRoom),
            RXDetailReportInfo(icon:report.problemType.icon,label:  "Loại lỗi:",value: report.problemType.label),
            RXDetailReportInfo(icon:Icons.priority_high,label:  "Mức độ:",value: report.level.label, color: report.level.color),
            RXDetailReportInfo(icon:Icons.calendar_today,label:  "Ngày báo cáo:",value: DateFormat('HH:mm - dd/MM/yyyy').format(report.reportDate)),

            Divider(height: 40),

            Text("Mô tả chi tiết:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 7),
            Text(report.problemDescription ?? "Không có mô tả chi tiết.", style: TextStyle(fontSize: 16)),

            SizedBox(height: 30),
            Text("Hình ảnh đính kèm:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 7),
            if (report.imageUrl != null) ...[
              SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  report.imageUrl!,
                  loadingBuilder: (context,child,loadingProgress){
                    if(loadingProgress==null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
            ]else Text("Không có hình ảnh.",style: TextStyle(fontSize: 16),),
          ],
        ),
      ),
    );
  }
}
