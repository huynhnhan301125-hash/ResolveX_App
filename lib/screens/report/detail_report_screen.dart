import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:resolvex_mobile_app/models/employee_model.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/services/auth_service.dart';
import 'package:resolvex_mobile_app/services/report_service.dart';
import 'package:resolvex_mobile_app/core/theme/theme.dart';

// =============================================================================
// DETAIL REPORT SCREEN — Chi tiết báo cáo + hành động Sửa/Xóa
//
// Cải tiến so với phiên bản cũ:
//   1. Thêm nút SỬA — mở EditReportScreen, nhận lại báo cáo đã cập nhật
//   2. Thêm nút XÓA — confirm dialog trước khi xóa thật
//   3. Quyền hiển thị nút:
//      - Admin:     luôn thấy cả 2 nút
//      - Nhân viên: chỉ thấy khi báo cáo là của mình + trong 10 phút + pending
//   4. Màn hình có state để cập nhật UI sau khi sửa (không cần pop về)
//   5. Đếm ngược thời gian còn lại để sửa (cho nhân viên)
// =============================================================================
class DetailReportScreen extends StatefulWidget {
  final ReportModel report;

  const DetailReportScreen({super.key, required this.report});

  @override
  State<DetailReportScreen> createState() => _DetailReportScreenState();
}

class _DetailReportScreenState extends State<DetailReportScreen> {
  // Báo cáo hiện tại — có thể thay đổi sau khi Sửa (dùng state thay vì widget.report)
  late ReportModel _report;

  // Thông tin người đang đăng nhập (để kiểm tra quyền)
  EmployeeModel? _currentEmployee;

  // Trạng thái loading khi đang xóa
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _report = widget.report; // Khởi tạo từ dữ liệu truyền vào
    _fetchCurrentEmployee();  // Load thông tin người dùng hiện tại
  }

  /// Lấy thông tin nhân viên đang đăng nhập để kiểm tra quyền
  Future<void> _fetchCurrentEmployee() async {
    final employee = await AuthService().getCurrentEmployee();
    if (mounted) {
      setState(() => _currentEmployee = employee);
    }
  }

  // ---------------------------------------------------------------------------
  // KIỂM TRA QUYỀN HIỂN THỊ NÚT SỬA/XÓA
  // ---------------------------------------------------------------------------

  /// Có hiện nút Sửa không?
  /// Admin: luôn có | Nhân viên: chỉ khi là báo cáo của mình + isEditableByEmployee
  bool get _canEdit {
    if (_currentEmployee == null) return false;
    if (_currentEmployee!.userRole.isAdmin) return true;

    // Nhân viên: chỉ sửa được báo cáo của mình + trong 10 phút + pending
    return _report.empId == _currentEmployee!.id &&
        _report.isEditableByEmployee;
  }

  /// Có hiện nút Xóa không? (Logic tương tự Sửa)
  bool get _canDelete => _canEdit;

  // ---------------------------------------------------------------------------
  // XỬ LÝ SỬA
  // ---------------------------------------------------------------------------

  Future<void> _handleEdit() async {
    if (_currentEmployee == null) return;

    // Điều hướng đến EditReportScreen, truyền report + currentEmployee
    // pushNamed trả về ReportModel đã cập nhật nếu lưu thành công
    final updatedReport = await context.pushNamed<ReportModel>(
      RouteNames.editReport,
      extra: {
        'report': _report,
        'currentEmployee': _currentEmployee!,
      },
    );

    // Nếu có báo cáo trả về → cập nhật UI hiện tại ngay, không cần fetch lại
    if (updatedReport != null && mounted) {
      setState(() => _report = updatedReport);
    }
  }

  // ---------------------------------------------------------------------------
  // XỬ LÝ XÓA
  // ---------------------------------------------------------------------------

  Future<void> _handleDelete() async {
    // Luôn hỏi xác nhận trước khi xóa — tránh xóa nhầm
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Báo cáo sẽ bị xóa vĩnh viễn và không thể khôi phục.\n'
          'Bạn có chắc chắn muốn xóa?',
        ),
        actions: [
          TextButton(
            // Nhấn Hủy → trả về false → không xóa
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            // Nhấn Xóa → trả về true → tiến hành xóa
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // Người dùng nhấn Hủy hoặc bấm ra ngoài dialog → không làm gì
    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      await ReportService().deleteReport(_report.reportId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa báo cáo thành công'),
            backgroundColor: Colors.green,
          ),
        );
        // Quay về màn hình trước và báo đã xóa (truyền null signal)
        // Màn hình danh sách sẽ bắt signal này để xóa item khỏi list
        context.pop('deleted');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xóa thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Tính thời gian còn lại để sửa (chỉ hiển thị cho nhân viên)
    final bool showCountdown = _currentEmployee != null &&
        !_currentEmployee!.userRole.isAdmin &&
        _report.empId == _currentEmployee!.id &&
        _report.isEditableByEmployee;

    return Scaffold(
      appBar: AppBar(
        // Hiện ID rút gọn để không bị quá dài
        title: Text('Chi tiết #${_report.reportId.substring(0, 8)}...'),
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.black,
        actions: [
          // Chỉ hiện nút khi đã load xong thông tin user và có quyền
          if (_currentEmployee != null && _canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Sửa báo cáo',
              onPressed: _handleEdit,
            ),
          if (_currentEmployee != null && _canDelete)
            IconButton(
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.delete_outline),
              tooltip: 'Xóa báo cáo',
              // Disable nút khi đang xóa
              onPressed: _isDeleting ? null : _handleDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppStyles.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ĐỒNG HỒ ĐẾM NGƯỢC (chỉ nhân viên) ──────────────────────────
            if (showCountdown)
              _EditCountdownBanner(secondsLeft: _report.secondsLeftToEdit),

            // ── TRẠNG THÁI ───────────────────────────────────────────────────
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: _report.status.color,
                  borderRadius: AppStyles.brXXL,
                ),
                child: Text(
                  _report.status.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppStyles.spaceXL),

            // ── THÔNG TIN CHÍNH ───────────────────────────────────────────────
            _ReportInfoRow(
              icon: Icons.room,
              label: 'Phòng:',
              value: _report.problemRoom,
            ),
            _ReportInfoRow(
              icon: _report.problemType.icon,
              label: 'Loại lỗi:',
              value: _report.problemType.label,
            ),
            _ReportInfoRow(
              icon: Icons.priority_high,
              label: 'Mức độ:',
              value: _report.level.label,
              color: _report.level.color,
            ),
            _ReportInfoRow(
              icon: Icons.calendar_today,
              label: 'Ngày báo cáo:',
              value: DateFormat('HH:mm - dd/MM/yyyy').format(_report.reportDate),
            ),

            const Divider(height: 40),

            // ── MÔ TẢ ────────────────────────────────────────────────────────
            const Text(
              'Mô tả chi tiết:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 7),
            Text(
              _report.problemDescription ?? 'Không có mô tả chi tiết.',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: AppStyles.spaceXXXL),

            // ── HÌNH ẢNH ─────────────────────────────────────────────────────
            const Text(
              'Hình ảnh đính kèm:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 7),
            if (_report.imageUrl != null) ...[
              const SizedBox(height: AppStyles.spaceS),
              ClipRRect(
                borderRadius: AppStyles.brM,
                child: Image.network(
                  _report.imageUrl!,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
            ] else
              const Text(
                'Không có hình ảnh.',
                style: TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// _EditCountdownBanner — Banner đếm ngược thời gian còn lại để sửa
//
// Chỉ hiển thị cho nhân viên khi báo cáo còn trong thời hạn sửa.
// Dùng StatefulWidget + ticker để cập nhật đếm ngược mỗi giây.
// =============================================================================
class _EditCountdownBanner extends StatefulWidget {
  final int secondsLeft;

  const _EditCountdownBanner({required this.secondsLeft});

  @override
  State<_EditCountdownBanner> createState() => _EditCountdownBannerState();
}

class _EditCountdownBannerState extends State<_EditCountdownBanner> {
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _seconds = widget.secondsLeft;
    _startCountdown();
  }

  void _startCountdown() {
    // Dùng Future.delayed lặp để đếm ngược mỗi giây
    if (_seconds <= 0) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _seconds > 0) {
        setState(() => _seconds--);
        _startCountdown(); // Gọi đệ quy để tiếp tục đếm
      }
    });
  }

  /// Format giây thành "MM:SS" (ví dụ: 530 giây → "08:50")
  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;  // ~/ = integer division
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_seconds <= 0) return const SizedBox.shrink(); // Ẩn khi hết giờ

    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spaceL),
      padding: const EdgeInsets.all(AppStyles.spaceM),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: AppStyles.brM,
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: Colors.amber),
          const SizedBox(width: AppStyles.spaceS),
          Expanded(
            child: Text(
              'Còn ${_formatTime(_seconds)} để sửa/xóa báo cáo này',
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _ReportInfoRow — Widget private, chỉ dùng trong file này.
// (Giữ nguyên từ phiên bản cũ)
// =============================================================================
class _ReportInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _ReportInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).iconTheme.color),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
