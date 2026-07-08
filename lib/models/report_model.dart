import 'package:equatable/equatable.dart';
import 'package:resolvex_mobile_app/models/report_enums.dart';

// Re-export để các file đang import report_model.dart vẫn lấy được Enum
// mà không cần thêm import mới. Tiện cho giai đoạn chuyển tiếp.
export 'package:resolvex_mobile_app/models/report_enums.dart';

// =============================================================================
// REPORT MODEL — Định nghĩa cấu trúc dữ liệu của một báo cáo sự cố
//
// Chỉ chứa class ReportModel. Các Enum liên quan đã được tách sang:
// → lib/models/report_enums.dart
// =============================================================================
class ReportModel extends Equatable {
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

  /// Chuyển đối tượng thành Map để lưu hoặc gửi lên Server
  Map<String, dynamic> toMap() {
    return {
      'report_id': reportId,
      'emp_id': empId,
      'problem_room': problemRoom,
      'problem_type': problemType.name,
      'level': level.name,
      'problem_description': problemDescription,
      'image_url': imageUrl,
      'status': status.name,
      'report_date': reportDate.toIso8601String(),
    };
  }

  /// Chuyển từ Map sang đối tượng ReportModel (ví dụ: dữ liệu từ Supabase)
  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      reportId: map['report_id'] as String? ?? '',
      empId: map['emp_id'] as String? ?? '',
      problemRoom: map['problem_room'] as String? ?? '',

      // firstWhere + orElse: an toàn hơn byName vì có fallback khi dữ liệu sai
      problemType: ProblemType.values.firstWhere(
        (e) => e.name == map['problem_type'],
        orElse: () => ProblemType.software,
      ),
      level: Level.values.firstWhere(
        (e) => e.name == map['level'],
        orElse: () => Level.low,
      ),
      problemDescription: map['problem_description'] as String?,
      imageUrl: map['image_url'] as String?,
      status: Status.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => Status.pending,
      ),
      // tryParse giúp app không crash nếu chuỗi ngày bị sai định dạng
      reportDate:
          DateTime.tryParse(map['report_date'] as String? ?? '') ?? DateTime.now(),
    );
  }

  /// Tạo bản sao với một số trường được thay đổi (immutable update pattern)
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

  // Equatable tự động tạo operator== và hashCode dựa trên list props này
  @override
  List<Object?> get props => [
    reportId, empId, problemRoom, problemType,
    level, problemDescription, imageUrl, status, reportDate,
  ];
}
