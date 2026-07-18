import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// =============================================================================
// REPORT SERVICE — Quản lý toàn bộ thao tác CRUD cho bảng reports
//
// Thiết kế theo nguyên tắc "Single Responsibility":
//   Mỗi class chỉ làm 1 việc. ReportService chỉ làm việc với dữ liệu báo cáo.
//   Màn hình (Widget) không được phép gọi Supabase trực tiếp — phải qua Service.
//
// Sơ đồ luồng dữ liệu:
//   Widget → gọi → ReportService → gọi → Supabase (PostgreSQL)
//   Supabase trả về Map → ReportService parse → ReportModel → Widget nhận
// =============================================================================
class ReportService {
  // ---------------------------------------------------------------------------
  // 1. LẤY TẤT CẢ BÁO CÁO (Admin dùng)
  // ---------------------------------------------------------------------------

  /// Trả về một trang báo cáo, mới nhất lên đầu.
  ///
  /// [page]: trang cần lấy, bắt đầu từ 0.
  /// [pageSize]: số báo cáo mỗi trang, mặc định 20.
  ///
  /// Nếu kết quả trả về ít hơn [pageSize] → đã hết dữ liệu (không cần load thêm).
  Future<List<ReportModel>> getAllReports({
    int page     = 0,
    int pageSize = 20,
  }) async {
    final int from = page * pageSize;       // trang 0 → từ record 0
    final int to   = from + pageSize - 1;   // trang 0 → đến record 19

    final data = await supabase
        .from('reports')
        .select()
        .order('report_date', ascending: false)
        .range(from, to); // ✅ Chỉ kéo đúng [pageSize] record thay vì toàn bộ bảng

    return data.map((row) => ReportModel.fromMap(row)).toList();
  }

  // ---------------------------------------------------------------------------
  // 2. LẤY BÁO CÁO CỦA MỘT NHÂN VIÊN CỤ THỂ (Employee dùng)
  // ---------------------------------------------------------------------------

  /// Trả về một trang báo cáo của nhân viên có [empId] tương ứng.
  ///
  /// [page]: trang cần lấy, bắt đầu từ 0.
  /// [pageSize]: số báo cáo mỗi trang, mặc định 20.
  Future<List<ReportModel>> getReportsByEmployee(
    String empId, {
    int page     = 0,
    int pageSize = 20,
  }) async {
    final int from = page * pageSize;
    final int to   = from + pageSize - 1;

    final data = await supabase
        .from('reports')
        .select()
        .eq('emp_id', empId)
        .order('report_date', ascending: false)
        .range(from, to); // ✅ Pagination — tránh kéo toàn bộ lịch sử của nhân viên


    /*
    Lấy danh sách dữ liệu thô (data), chạy vòng lặp qua từng dòng (map), ném từng dòng
    vào khuôn đúc để tạo ra đối tượng ReportModel (fromMap), cuối cùng gom tất cả lại
    thành một cái danh sách chuẩn (toList) và trả về cho màn hình sử dụng (return).
     */
    return data.map((row) => ReportModel.fromMap(row)).toList();
  }

  // ---------------------------------------------------------------------------
  // 3. LẤY CHI TIẾT MỘT BÁO CÁO
  // ---------------------------------------------------------------------------

  /// Trả về đúng 1 báo cáo theo [reportId].
  ///
  /// Ném Exception nếu không tìm thấy (dùng .single()).
  Future<ReportModel> getReportById(String reportId) async {
    final data = await supabase
        .from('reports')
        .select()
        .eq('report_id', reportId)   // WHERE report_id = reportId
        .single();                   // Đảm bảo trả đúng 1 hàng, ném lỗi nếu không có

    return ReportModel.fromMap(data);
  }

  // ---------------------------------------------------------------------------
  // 4. TẠO BÁO CÁO MỚI
  // ---------------------------------------------------------------------------

  /// Tạo một báo cáo mới trong database.
  ///
  /// Trả về [ReportModel] đã được tạo (bao gồm report_id và report_date do DB tự sinh).
  ///
  /// Quan trọng: Ta KHÔNG truyền report_id, status, report_date vào payload vì:
  ///   - report_id: DB tự tạo bằng gen_random_uuid()
  ///   - status:    DB tự gán DEFAULT 'pending'
  ///   - report_date: DB tự gán DEFAULT now() theo giờ UTC
  Future<ReportModel> createReport({
    required String empId,
    required String problemRoom,
    required ProblemType problemType,
    required Level level,
    String? problemDescription,
    String? imageUrl,
  }) async {
    // Tạo Map chứa dữ liệu cần INSERT
    // Chú ý: Enum phải chuyển sang String bằng .name (ví dụ: Level.high → "high")
    // vì Supabase nhận String, không nhận Dart Enum trực tiếp.
    final payload = {
      'emp_id':              empId,
      'problem_room':        problemRoom,
      'problem_type':        problemType.name, // Enum → String, khớp với ENUM type trong DB
      'level':               level.name,       // Enum → String
      'problem_description': problemDescription,
      'image_url':           imageUrl,
      // status và report_id bị bỏ qua có chủ đích (xem docstring ở trên)
    };

    // .insert(payload)  → INSERT INTO reports (...) VALUES (...)
    // .select().single() → Sau khi INSERT thành công, lấy lại hàng vừa tạo về
    //                      (quan trọng vì ta cần biết report_id và report_date mà DB tự tạo)
    final response = await supabase
        .from('reports')
        .insert(payload)
        .select()   // Nếu không có .select() sau .insert() thì sẽ không trả về gì
        .single();

    return ReportModel.fromMap(response);
  }

  // ---------------------------------------------------------------------------
  // 5. CẬP NHẬT TRẠNG THÁI BÁO CÁO (Admin dùng)
  // ---------------------------------------------------------------------------

  /// Thay đổi [status] của báo cáo có [reportId].
  ///
  /// Ví dụ: Admin đọc báo cáo → đổi từ pending → processing,
  ///         Sau khi xử lý xong → đổi từ processing → resolved.
  Future<ReportModel> updateReportStatus({
    required String reportId,
    required Status newStatus,
  }) async {
    final response = await supabase
        .from('reports')
        .update({'status': newStatus.name})  // UPDATE reports SET status = '...'
        .eq('report_id', reportId)           // WHERE report_id = reportId
        .select()                            // Trả về hàng sau khi update
        .single();

    return ReportModel.fromMap(response);
  }

  // ---------------------------------------------------------------------------
  // 6. XÓA BÁO CÁO
  // ---------------------------------------------------------------------------

  /// Xóa vĩnh viễn báo cáo có [reportId] khỏi database.
  ///
  /// Không có undo! Cân nhắc dùng soft delete (thêm cột is_deleted) cho production.
  Future<void> deleteReport(String reportId) async {
    await supabase
        .from('reports')
        .delete()                    // DELETE FROM reports
        .eq('report_id', reportId);  // WHERE report_id = reportId
  }

  // ---------------------------------------------------------------------------
  // 7. CẬP NHẬT TOÀN BỘ NỘI DUNG BÁO CÁO (Admin dùng)
  // ---------------------------------------------------------------------------

  /// Cập nhật nội dung đầy đủ của một báo cáo.
  ///
  /// Admin có thể sửa tất cả field, kể cả status.
  /// Khác với [updateReportStatus] chỉ sửa 1 field, hàm này sửa toàn bộ.
  Future<ReportModel> updateReport({
    required String reportId,
    required String problemRoom,
    required ProblemType problemType,
    required Level level,
    String? problemDescription,
    String? imageUrl,
    required Status status,
  }) async {
    // Tạo Map chỉ chứa các field cần UPDATE
    // Không UPDATE emp_id, report_id, report_date vì những field này không đổi
    final payload = {
      'problem_room':        problemRoom,
      'problem_type':        problemType.name,  // Enum → String
      'level':               level.name,
      'problem_description': problemDescription,
      'image_url':           imageUrl,
      'status':              status.name,
    };

    final response = await supabase
        .from('reports')
        .update(payload)               // UPDATE reports SET ...
        .eq('report_id', reportId)     // WHERE report_id = reportId
        .select()                      // Trả về hàng đã cập nhật
        .single();

    return ReportModel.fromMap(response);
  }

  // ---------------------------------------------------------------------------
  // 8. CẬP NHẬT BÁO CÁO BỞI NHÂN VIÊN (có giới hạn thời gian)
  // ---------------------------------------------------------------------------

  /// Nhân viên cập nhật nội dung báo cáo của mình.
  ///
  /// Hàm này KHÔNG kiểm tra quyền (việc đó do RLS Policy trên Supabase làm).
  /// Phía app chỉ kiểm tra để ẩn/hiện nút (UX), còn bảo mật thật sự là ở DB.
  ///
  /// Nếu RLS từ chối → Supabase ném Exception → app bắt và hiện thông báo lỗi.
  Future<ReportModel> updateReportByEmployee({
    required String reportId,
    required String problemRoom,
    required ProblemType problemType,
    required Level level,
    String? problemDescription,
    String? imageUrl,
  }) async {
    // Nhân viên KHÔNG được đổi status — chỉ Admin mới được
    // Vì vậy payload không có trường 'status'
    final payload = {
      'problem_room':        problemRoom,
      'problem_type':        problemType.name,
      'level':               level.name,
      'problem_description': problemDescription,
      'image_url':           imageUrl,
    };

    final response = await supabase
        .from('reports')
        .update(payload)
        .eq('report_id', reportId)
        .select()
        .single();

    return ReportModel.fromMap(response);
  }

  // ---------------------------------------------------------------------------
  // 9. REAL-TIME — Lắng nghe thay đổi từ database theo thời gian thực
  // ---------------------------------------------------------------------------

  /// Lắng nghe thay đổi realtime trong bảng reports qua WebSocket.
  ///
  /// Thay vì fetch lại toàn bộ danh sách mỗi khi có thay đổi (tốn băng thông),
  /// hàm này tách 3 callback riêng để caller chỉ cập nhật đúng 1 phần tử trong list.
  ///
  /// Supabase tự động truyền dữ liệu của record bị thay đổi vào [payload] —
  /// ta chỉ cần parse và dùng, không cần gọi thêm bất kỳ query nào.
  ///
  /// ⚠️ Nhớ gọi channel.unsubscribe() trong dispose() để tránh memory leak.
  ///
  /// Cách dùng:
  /// ```dart
  /// late RealtimeChannel _channel;
  ///
  /// void initState() {
  ///   _channel = reportService.listenToReports(
  ///     onInsert: (r) => setState(() => listReport.insert(0, r)),
  ///     onUpdate: (r) {
  ///       final i = listReport.indexWhere((x) => x.reportId == r.reportId);
  ///       if (i != -1) setState(() => listReport[i] = r);
  ///     },
  ///     onDelete: (id) => setState(() => listReport.removeWhere((x) => x.reportId == id)),
  ///   );
  /// }
  ///
  /// void dispose() {
  ///   _channel.unsubscribe();
  /// }
  /// ```
  RealtimeChannel listenToReports({
    required void Function(ReportModel report) onInsert,
    required void Function(ReportModel report) onUpdate,
    required void Function(String reportId)    onDelete,
  }) {
    return supabase
        .channel('public:reports')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reports',
          callback: (payload) {
            // payload.newRecord: dữ liệu mới (có ở INSERT và UPDATE)
            // payload.oldRecord: dữ liệu cũ (có ở DELETE và UPDATE)
            switch (payload.eventType) {
              case PostgresChangeEvent.insert:
                onInsert(ReportModel.fromMap(payload.newRecord));

              case PostgresChangeEvent.update:
                onUpdate(ReportModel.fromMap(payload.newRecord));

              case PostgresChangeEvent.delete:
                // DELETE chỉ trả về primary key trong oldRecord
                final id = payload.oldRecord['report_id'] as String;
                onDelete(id);

              default:
                break;
            }
          },
        )
        .subscribe();
  }
}
