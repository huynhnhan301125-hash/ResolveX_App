

import "package:flutter/material.dart";
import 'package:equatable/equatable.dart';
enum ProblemType {
  network('Lỗi mạng', Icons.wifi, Colors.green),
  hardware("Lỗi phần cứng", Icons.memory, Colors.grey),
  software("Lỗi phần mềm", Icons.settings_suggest, Colors.blue),
  furniture("Hư cơ sở vật chất", Icons.construction, Colors.black);

  final String label;
  final IconData icon;
  final Color color;

  const ProblemType(this.label, this.icon, this.color);
}

enum Level {
  low('Thấp', Color(0xFF757575)),
  medium("Trung bình", Color(0xFFC0CA33)),
  high('Cao', Color(0xFFE53935));

  final String label;
  final Color color;

  const Level(this.label, this.color);
}

enum Status {
  pending('Đang chờ', Color(0xFFE0E0E0)),
  processing('Đang xử lý', Color(0xFFFFE082)),
  resolved('Đã giải quyết', Color(0xFF66BB6A));

  final Color color;
  final String label;

  const Status(this.label, this.color);

  // Getter: Giúp kiểm tra nhanh trạng thái mà không cần viết dài dòng
  // Thay vì viết: if (report.status == Status.pending)
  // Bạn chỉ cần: if (report.status.isPending)
  bool get isPending => this == Status.pending;

  bool get isProcessing => this == Status.processing;

  bool get isResolved => this == Status.resolved;
}

class ReportModel extends Equatable{
  final String reportId;
  final String empId;
  final String problemRoom;
  final ProblemType problemType;
  final Level level;
  final String? problemDescription;
  final String? imageUrl;
  final Status status;
  final DateTime reportDate;

  const ReportModel({
    required this.reportId,
    required this.empId,
    required this.problemRoom,
    required this.problemType,
    required this.level,
    this.problemDescription,
    this.imageUrl,
    required this.status,
    required this.reportDate,
  });

  //Chuyển đối tượng thành Map để lưu trữ hoặc gửi lên Server
    Map<String, dynamic> toMap() {
      return {
        'reportId': reportId,
        'empId': empId,
        'problemRoom': problemRoom,
        'problemType': problemType.name,
        'level': level.name,
        'problemDescription': problemDescription,
        'imageUrl': imageUrl,
        'status': status.name,
        'reportDate': reportDate.toIso8601String(),
      };
    }

    // Chuyển từ Map sang đối tượng ReportModel
    factory ReportModel.fromMap(Map<String, dynamic> map) {
      return ReportModel(
        reportId: map['reportId'] as String? ?? '',
        empId: map['empId'] as String? ?? '',
        problemRoom: map['problemRoom'] as String? ?? '',

        // Dùng firstWhere an toàn hơn byName vì có 'orElse' phòng hờ dữ liệu sai
        problemType: ProblemType.values.firstWhere(
          (e) => e.name == map['problemType'],
          orElse: () => ProblemType.software,
        ),
        level: Level.values.firstWhere(
          (e) => e.name == map['level'],
          orElse: () => Level.low,
        ),

        problemDescription: map['problemDescription'] as String?,

        // imageUrl phải là String? vì nó có thể null
        imageUrl: map['imageUrl'] as String?,

        status: Status.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => Status.pending,
        ),

        // tryParse giúp app không bị crash nếu chuỗi ngày tháng bị sai định dạng
        reportDate:
            DateTime.tryParse(map['reportDate'] as String? ?? '') ??
            DateTime.now(),
      );
    }

    // Tạo bản sao mới khi muốn thay đổi giá trị (vì biến của bạn là 'final')
    ReportModel copyWith({
      String? reportId,
      String? empId,
      String? problemRoom,
      ProblemType? problemType,
      Level? level,
      String? problemDescription,
      String? imageUrl,
      Status? status,
      DateTime? reportDate,
    }) {
      return ReportModel(
        reportId: reportId ?? this.reportId,
        empId: empId ?? this.empId,
        problemRoom: problemRoom ?? this.problemRoom,
        problemType: problemType ?? this.problemType,
        level: level ?? this.level,
        problemDescription: problemDescription ?? this.problemDescription,
        imageUrl: imageUrl ?? this.imageUrl,
        status: status ?? this.status,
        reportDate: reportDate ?? this.reportDate,
      );
    }

    // // So sánh giá trị giúp Flutter biết khi nào cần vẽ lại (rebuild) giao diện
    // @override
    // bool operator ==(Object other) =>
    //     identical(this, other) ||
    //     other is ReportModel &&
    //         runtimeType == other.runtimeType &&
    //         reportId == other.reportId &&
    //         empId == other.empId &&
    //         problemRoom == other.problemRoom &&
    //         problemType == other.problemType &&
    //         level == other.level &&
    //         problemDescription == other.problemDescription &&
    //         imageUrl == other.imageUrl &&
    //         status == other.status &&
    //         reportDate == other.reportDate;
    //
    // @override
    // int get hashCode => Object.hash(
    //   reportId,
    //   empId,
    //   problemRoom,
    //   problemType,
    //   level,
    //   problemDescription,
    //   imageUrl,
    //   status,
    //   reportDate,
    // );
    //
    // // Giúp bạn xem dữ liệu thật khi sử dụng lệnh print() để debug
    // @override
    // String toString() {
    //   return 'ReportModel(id: $reportId, room: $problemRoom, status: ${status.label})';
    // }

  // Sử dụng Equatable thay vì gõ operator == và hashCode thủ công
  @override
  List<Object?> get props=>[
    reportId,
    empId,
    problemRoom,
    problemType,
    level,
    problemDescription,
    imageUrl,
    status,
    reportDate
  ];
}
