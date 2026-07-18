import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/services/report_service.dart';

// =============================================================================
// REPORT PROVIDER — Nguồn dữ liệu trung tâm cho toàn bộ báo cáo
//
// Tại sao cần Provider thay vì truyền props trực tiếp?
//   Trước đây, MainEmployeeScreen truyền listReport xuống từng Tab qua constructor
//   (gọi là "Prop Drilling"). Cách này khiến mỗi khi dữ liệu thay đổi, TẤT CẢ
//   các Tab đều bị Flutter rebuild lại — kể cả Tab đang ẩn mà người dùng không xem.
//
//   Với Provider, mỗi Tab chỉ tự "đăng ký" lắng nghe (context.watch) những gì
//   nó cần. Tab không lắng nghe sẽ KHÔNG bị rebuild khi Provider thay đổi.
//
// Vị trí trong kiến trúc:
//   UI (Tab) → đọc dữ liệu từ ReportProvider
//   ReportProvider → gọi ReportService để lấy data từ Supabase
//   ReportService → giao tiếp với Supabase
// =============================================================================
class ReportProvider extends ChangeNotifier {
  final ReportService _reportService;

  // ---------------------------------------------------------------------------
  // STATE — Toàn bộ trạng thái liên quan đến danh sách báo cáo
  // ---------------------------------------------------------------------------

  List<ReportModel> _listReport = [];
  bool _isLoading = true;       // true = đang tải lần đầu, hiện full-screen spinner
  bool _isLoadingMore = false;  // true = đang tải trang tiếp, hiện spinner cuối list
  bool _hasMore = true;         // false khi server trả về ít hơn pageSize (hết data)
  int _page = 0;                // Trang hiện tại (bắt đầu từ 0)

  static const int _pageSize = 20;

  // ---------------------------------------------------------------------------
  // GETTERS — Cho phép UI đọc state nhưng không thể gán lại từ bên ngoài
  // ---------------------------------------------------------------------------

  List<ReportModel> get listReport => _listReport;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  // ---------------------------------------------------------------------------
  // CONSTRUCTOR
  // ---------------------------------------------------------------------------

  /// Constructor nhận ReportService từ bên ngoài (Dependency Injection).
  /// Tương tự AuthProvider — giúp dễ thay bằng MockReportService khi viết test.
  ReportProvider({required ReportService reportService})
      : _reportService = reportService;

  // ---------------------------------------------------------------------------
  // METHODS — Các hành động thay đổi state
  // ---------------------------------------------------------------------------

  /// Tải báo cáo từ Supabase.
  ///
  /// [reset]: true = bắt đầu lại từ trang 0 (refresh).
  ///          false = tải trang tiếp theo và ghép vào cuối list (load more).
  Future<void> loadReports({bool reset = true}) async {
    if (reset) {
      // Refresh: reset về trang đầu, hiện full-screen loading spinner
      _isLoading = true;
      _page = 0;
      _hasMore = true;
      notifyListeners(); // Thông báo UI hiện spinner ngay
    } else {
      // Load more: bỏ qua nếu đã hết data hoặc đang có request đang chạy
      if (!_hasMore || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners(); // Thông báo UI hiện spinner cuối list
    }

    try {
      final results = await _reportService.getAllReports(
        page: reset ? 0 : _page,
        pageSize: _pageSize,
      );

      if (reset) {
        _listReport = results;       // Thay toàn bộ list khi refresh
      } else {
        _listReport.addAll(results); // Gập thêm vào cuối list khi load more
        _page++;
      }

      // Nếu server trả về ít hơn pageSize → không còn trang tiếp
      _hasMore = results.length == _pageSize;
      _isLoading = false;
      _isLoadingMore = false;

      // Sau khi reset xong, đặt đúng số trang hiện tại
      if (reset) _page = 1;
    } catch (e) {
      _isLoading = false;
      _isLoadingMore = false;
      // Ném lại exception để UI bắt và hiện SnackBar
      rethrow;
    } finally {
      // finally đảm bảo notifyListeners() luôn được gọi dù thành công hay thất bại
      notifyListeners();
    }
  }

  /// Thêm một báo cáo mới vào đầu danh sách (sau khi tạo báo cáo thành công).
  /// Không cần gọi lại API — chỉ cần chèn vào local list để UX nhanh hơn.
  void addReportToTop(ReportModel newReport) {
    _listReport.insert(0, newReport);
    notifyListeners(); // Thông báo tất cả Tab đang lắng nghe cập nhật lại
  }
}
