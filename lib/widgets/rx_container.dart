import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:intl/intl.dart';

class RXContainer extends StatelessWidget {
  final ReportModel reportModel;
  final VoidCallback onTap;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  const RXContainer({
    super.key,
    required this.reportModel,
    this.margin = const EdgeInsets.all(10),
    this.padding = const EdgeInsets.all(10),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding,
            // Sử dụng IntrinsicHeight để ép các con trong Row có chiều cao bằng nhau (theo thằng cao nhất).
            // Nhờ đó, Column bên phải mới có đủ chiều cao để thực hiện spaceBetween (đẩy status lên đầu và time xuống cuối).
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Id: ${reportModel.empId}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Phòng: ${reportModel.problemRoom}"),
                      SizedBox(height: 10),
                      Text("Vấn đề: ${reportModel.problemType.label}"),
                      SizedBox(height: 10),
                      Text(
                        "Mức độ: ${reportModel.level.label}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: reportModel.level.color,
                        ),
                      ),
                    ],
                  ),
              
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: reportModel.status.color,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              spreadRadius: 1,
                            )
                          ]
                        ),
              
                        child: Text(
                          reportModel.status.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // kk:mm ép định dạng về 24h (09:00)
                      Icon(
                        reportModel.problemType.icon,
                        size: 55,
                        color: reportModel.problemType.color,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 6,
                            offset: Offset(4, 4),
                          ),
                        ],
                      ),
                      Text(
                        DateFormat(
                          'kk:mm - dd/MM',
                        ).format(reportModel.reportDate),
                        style: TextStyle(color: Colors.black, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
