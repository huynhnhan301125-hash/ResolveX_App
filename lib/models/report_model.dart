
import "package:flutter/material.dart";

enum ProblemType {
  network('Lỗi mạng', Icons.wifi,Colors.green),
  hardware("Lỗi phần cứng", Icons.memory,Colors.grey),
  software("Lỗi phần mềm", Icons.settings_suggest,Colors.blue),
  furniture("Hư cơ sở vật chất", Icons.construction,Colors.black);

  final String label;
  final IconData icon;
  final Color color;
  const ProblemType(this.label, this.icon,this.color);

}

enum Level {
  low('Thấp', Color(0xFF757575)),
  medium("Trung bình", Color(0xFFC0CA33)),
  high('Cao', Color(0xFFE53935));

  final String label;
  final Color color;

  const Level(this.label, this.color);
}

enum Status{
  pending('Đang chờ',Color(0xFFE0E0E0)),
  processing('Đang xữ lý',Color(0xFFFFE082)),
  resolved('Đã giải quyết',Color(0xFF66BB6A));
  final Color color;
  final String label;
  const Status(this.label,this.color);
}

class ReportModel {
  final String reportId;
  final String empId;
  final String problemRoom;
  final ProblemType problemType;
  final Level level;
  final String? problemDesciption;
  final String? imageUrl;
  final Status status;
  final DateTime reportDate;
  const ReportModel({
    required this.reportId,
    required this.empId,
    required this.problemRoom,
    required this.problemType,
    required this.level,
    this.problemDesciption,
    this.imageUrl,
    required this.status,
    required this.reportDate,
  });

}
