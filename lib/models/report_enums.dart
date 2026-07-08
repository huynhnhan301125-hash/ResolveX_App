import 'package:flutter/material.dart';

// =============================================================================
// REPORT ENUMS — Các kiểu liệt kê dùng trong module Báo cáo sự cố
//
// Tại sao tách ra file riêng?
//   - report_model.dart chỉ nên chứa định nghĩa class ReportModel
//   - Các Enum này được dùng ở nhiều nơi ngoài Model:
//     ReportFilterBar, RXContainer, applyReportFilters, UI chọn Level...
//   - Tách ra giúp tránh import cả Model chỉ để dùng một cái Enum
// =============================================================================

enum ProblemType {
  network('Lỗi mạng', Icons.wifi, Colors.green),
  hardware('Lỗi phần cứng', Icons.memory, Colors.grey),
  software('Lỗi phần mềm', Icons.settings_suggest, Colors.blue),
  furniture('Hư cơ sở vật chất', Icons.construction, Colors.black);

  final String label;
  final IconData icon;
  final Color color;

  const ProblemType(this.label, this.icon, this.color);
}

enum Level {
  low('Thấp', Color(0xFF757575)),
  medium('Trung bình', Color(0xFFC0CA33)),
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

  // Getter giúp kiểm tra trạng thái nhanh gọn — thay vì viết dài:
  // if (report.status == Status.pending) → if (report.status.isPending)
  bool get isPending    => this == Status.pending;
  bool get isProcessing => this == Status.processing;
  bool get isResolved   => this == Status.resolved;
}
