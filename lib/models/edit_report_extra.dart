import 'package:resolvex_mobile_app/models/employee_model.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';

// =============================================================================
// EDIT REPORT EXTRA — Lớp dữ liệu type-safe để truyền tham số khi điều hướng
//
// [VẤN ĐỀ CŨ — Map<String, dynamic>]
// Trước đây, khi điều hướng đến EditReportScreen, dữ liệu được truyền qua:
//   extra: {'report': myReport, 'currentEmployee': myEmployee}
//
// Nhược điểm chết người: Nếu gõ nhầm key ('employee' thay vì 'currentEmployee'),
//   - Trình biên dịch (VS Code) KHÔNG phát hiện → PASS xanh lá ✅
//   - Khi người dùng bấm nút Edit → app nhận được null → CRASH 💥
//   Loại lỗi này chỉ phát hiện được lúc runtime, rất nguy hiểm trên môi trường thật.
//
// [GIẢI PHÁP — Type-Safe Class]
// Dùng class với các trường `required` bắt buộc:
//   - Nếu thiếu bất kỳ trường nào → VS Code GẠch ĐỎ ngay lập tức ✅
//   - Dart compiler từ chối build app nếu code sai → Lỗi bị bắt ở Compile Time ✅
//   - IDE hỗ trợ autocomplete tên trường → Không thể gõ nhầm tên ✅
// =============================================================================

/// Lớp dữ liệu đóng gói thông tin cần thiết để mở màn hình [EditReportScreen].
///
/// Sử dụng:
/// ```dart
/// // Nơi gọi (type-safe, VS Code báo lỗi ngay nếu thiếu trường):
/// context.pushNamed(
///   RouteNames.editReport,
///   extra: EditReportExtra(report: myReport, currentEmployee: myEmployee),
/// );
///
/// // Trong app_router.dart (nhận và ép kiểu an toàn):
/// if (state.extra is EditReportExtra) {
///   final extra = state.extra as EditReportExtra;
///   return EditReportScreen(
///     report: extra.report,
///     currentEmployee: extra.currentEmployee,
///   );
/// }
/// ```
class EditReportExtra {
  /// Báo cáo cần chỉnh sửa — bắt buộc phải có.
  final ReportModel report;

  /// Nhân viên hiện đang đăng nhập — bắt buộc phải có.
  /// Dùng để kiểm tra quyền sửa và hiển thị thông tin người tạo.
  final EmployeeModel currentEmployee;

  const EditReportExtra({
    required this.report,
    required this.currentEmployee,
  });
}
