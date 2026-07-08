import 'package:resolvex_mobile_app/models/report_model.dart';

/// Hàm tiện ích xử lý lọc và sắp xếp danh sách báo cáo.
///
/// Tách ra file riêng để tuân thủ nguyên tắc DRY — tránh lặp code
/// giữa [ReportListTab] và [ReportHistoryTab].
///
/// Tham số:
/// - [baseList]: Danh sách gốc đã được lọc sơ bộ (ví dụ: chỉ lấy resolved hoặc chưa resolved)
/// - [selectedType]: Loại sự cố muốn lọc (null = tất cả)
/// - [selectedLevel]: Mức độ ưu tiên muốn lọc (null = tất cả)
/// - [isNewestFirst]: true = sắp xếp mới nhất lên đầu, false = cũ nhất lên đầu
///
/// Trả về: Danh sách đã qua bộ lọc và được sắp xếp, sẵn sàng để hiển thị.
List<ReportModel> applyReportFilters({
  required List<ReportModel> baseList,
  required ProblemType? selectedType,
  required Level? selectedLevel,
  required bool isNewestFirst,
}) {
  // Tạo bản copy để không làm thay đổi danh sách gốc
  List<ReportModel> result = List.from(baseList);

  // Áp dụng bộ lọc loại sự cố nếu người dùng đã chọn
  if (selectedType != null) {
    result = result.where((r) => r.problemType == selectedType).toList();
  }

  // Áp dụng bộ lọc mức độ ưu tiên nếu người dùng đã chọn
  if (selectedLevel != null) {
    result = result.where((r) => r.level == selectedLevel).toList();
  }

  // Sắp xếp theo thời gian
  result.sort((a, b) => isNewestFirst
      ? b.reportDate.compareTo(a.reportDate)  // Mới nhất lên đầu
      : a.reportDate.compareTo(b.reportDate)); // Cũ nhất lên đầu

  return result;
}
