import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resolvex_mobile_app/models/employee_model.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/services/report_service.dart';
import 'package:resolvex_mobile_app/core/theme/theme.dart';
import 'package:resolvex_mobile_app/utils/app_validate.dart';
import 'package:resolvex_mobile_app/widgets/rx_customscrollview.dart';
import 'package:resolvex_mobile_app/widgets/rx_textfield.dart';

// =============================================================================
// EDIT REPORT SCREEN — Màn hình sửa báo cáo
//
// Dùng chung cho Admin và Nhân viên, nhưng với quyền khác nhau:
//   - Admin (isAdmin = true):
//       + Sửa tất cả field
//       + Được đổi Status (dropdown xuất hiện)
//       + Không giới hạn thời gian
//   - Nhân viên (isAdmin = false):
//       + Chỉ sửa nội dung (phòng, loại, mức độ, mô tả)
//       + KHÔNG thấy dropdown Status
//       + Chỉ sửa được trong 10 phút đầu khi status == pending
//
// Giao diện tái sử dụng form từ CreateReportScreen nhưng đã điền sẵn dữ liệu.
// =============================================================================
class EditReportScreen extends StatefulWidget {
  /// Báo cáo cần sửa (được truyền qua GoRouter extra)
  final ReportModel report;

  /// Thông tin người đang đăng nhập (xác định Admin hay Nhân viên)
  final EmployeeModel currentEmployee;

  const EditReportScreen({
    super.key,
    required this.report,
    required this.currentEmployee,
  });

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  // Form key để validate trước khi submit
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các ô nhập văn bản
  late final TextEditingController _roomController;
  late final TextEditingController _descriptionController;

  // Trạng thái các field đã chọn — được khởi tạo từ dữ liệu hiện tại của báo cáo
  late ProblemType _selectedType;
  late Level _selectedLevel;
  late Status _selectedStatus; // Chỉ Admin mới thay đổi được

  // Trạng thái loading khi đang gửi request lên Supabase
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Điền sẵn dữ liệu hiện tại của báo cáo vào form
    // late final: khai báo ở trên nhưng khởi tạo ở đây (sau khi widget.report sẵn sàng)
    _roomController = TextEditingController(text: widget.report.problemRoom);
    _descriptionController = TextEditingController(
      text: widget.report.problemDescription ?? '',
    );
    _selectedType = widget.report.problemType;
    _selectedLevel = widget.report.level;
    _selectedStatus = widget.report.status;
  }

  @override
  void dispose() {
    // Luôn giải phóng TextEditingController để tránh memory leak
    _roomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // XỬ LÝ GỬI FORM
  // ---------------------------------------------------------------------------

  Future<void> _submitEdit() async {
    // Validate: kiểm tra các ô nhập hợp lệ trước khi gửi
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      ReportModel updatedReport;

      if (widget.currentEmployee.userRole.isAdmin) {
        // ADMIN: gọi updateReport() — có thể đổi status
        updatedReport = await ReportService().updateReport(
          reportId: widget.report.reportId,
          problemRoom: _roomController.text.trim(),
          problemType: _selectedType,
          level: _selectedLevel,
          problemDescription: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          status: _selectedStatus,
        );
      } else {
        // NHÂN VIÊN: gọi updateReportByEmployee() — KHÔNG đổi được status
        updatedReport = await ReportService().updateReportByEmployee(
          reportId: widget.report.reportId,
          problemRoom: _roomController.text.trim(),
          problemType: _selectedType,
          level: _selectedLevel,
          problemDescription: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
      }

      if (mounted) {
        // Trả báo cáo đã cập nhật về cho màn hình trước
        // DetailReportScreen sẽ dùng object này để cập nhật UI mà không cần fetch lại
        context.pop(updatedReport);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // finally: luôn chạy dù thành công hay thất bại
      // Đảm bảo tắt loading dù có lỗi
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // BUILD UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.currentEmployee.userRole.isAdmin;

    return Scaffold(
      body: Form(
        key: _formKey,
        child: GestureDetector(
          // Tắt bàn phím khi tap vào vùng trống
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: RXCustomScrollView(
            title: Text(
              isAdmin ? 'Sửa báo cáo (Admin)' : 'Sửa báo cáo',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            expandedHeight: 70,
            showBackButton: true,
            sliver: [
              SliverPadding(
                padding: const EdgeInsets.all(AppStyles.spaceL),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── 1. THÔNG BÁO QUYỀN HẠN ──────────────────────────────
                    // Hiển thị banner nhắc nhở quyền chỉnh sửa khác nhau
                    Container(
                      padding: const EdgeInsets.all(AppStyles.spaceM),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? Colors.blue.shade50
                            : Colors.orange.shade50,
                        borderRadius: AppStyles.brM,
                        border: Border.all(
                          color: isAdmin
                              ? Colors.blue.shade200
                              : Colors.orange.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isAdmin ? Icons.admin_panel_settings : Icons.timer,
                            color: isAdmin ? Colors.blue : Colors.orange,
                          ),
                          const SizedBox(width: AppStyles.spaceS),
                          Expanded(
                            child: Text(
                              isAdmin
                                  ? 'Bạn đang sửa với quyền Admin — có thể thay đổi tất cả trường kể cả trạng thái.'
                                  : 'Bạn có thể sửa trong 10 phút đầu khi báo cáo còn "Chờ xử lý".',
                              style: TextStyle(
                                fontSize: 13,
                                color: isAdmin
                                    ? Colors.blue.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppStyles.spaceXL),

                    // ── 2. PHÒNG ────────────────────────────────────────────
                    const Text(
                      'Vị trí sự cố',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: AppStyles.spaceS),
                    RXTextField(
                      controller: _roomController,
                      labelText: 'Ví dụ: Phòng A.102',
                      prefixIcon: const Icon(Icons.location_on),
                      validator: (value) =>
                          AppValidate.checkEmpty(value, 'Vị trí phòng'),
                    ),
                    const SizedBox(height: AppStyles.spaceXL),

                    // ── 3. LOẠI VẤN ĐỀ ──────────────────────────────────────
                    const Text(
                      'Loại vấn đề',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: AppStyles.spaceS),
                    DropdownButtonFormField<ProblemType>(
                      initialValue: _selectedType,
                      dropdownColor: AppColors.surfaceWhite,
                      style: const TextStyle(color: AppColors.textPrimary),
                      items: ProblemType.values
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Row(children: [
                                  Icon(type.icon, color: type.color),
                                  const SizedBox(width: 10),
                                  Text(type.label, style: const TextStyle(color: AppColors.textPrimary)),
                                ]),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedType = value!),
                    ),
                    const SizedBox(height: AppStyles.spaceXL),

                    // ── 4. MỨC ĐỘ ────────────────────────────────────────────
                    const Text(
                      'Mức độ ưu tiên',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: AppStyles.spaceS),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: Level.values.map((level) {
                        final bool isSelected = _selectedLevel == level;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedLevel = level),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? level.color
                                  : level.color.withValues(alpha: .1),
                              borderRadius: AppStyles.brM,
                              border: Border.all(color: level.color),
                            ),
                            child: Text(
                              level.label,
                              style: TextStyle(
                                color: isSelected ? Colors.white : level.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppStyles.spaceXL),

                    // ── 5. TRẠNG THÁI (chỉ Admin thấy) ──────────────────────
                    // if/else ở Widget level: Widget chỉ tồn tại khi điều kiện đúng
                    if (isAdmin) ...[
                      const Text(
                        'Trạng thái',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: AppStyles.spaceS),
                      DropdownButtonFormField<Status>(
                        initialValue: _selectedStatus,
                        dropdownColor: AppColors.surfaceWhite,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: Status.values
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Row(children: [
                                    // Chấm màu đại diện trạng thái
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: s.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(s.label, style: const TextStyle(color: AppColors.textPrimary)),
                                  ]),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedStatus = value!),
                      ),
                      const SizedBox(height: AppStyles.spaceXL),
                    ],

                    // ── 6. MÔ TẢ ─────────────────────────────────────────────
                    const Text(
                      'Mô tả chi tiết',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: AppStyles.spaceS),
                    RXTextField(
                      controller: _descriptionController,
                      labelText: 'Nhập mô tả tình trạng hư hỏng...',
                      minLines: 3,
                      maxLines: 5,
                    ),
                    const SizedBox(height: AppStyles.spaceXXXL),

                    // ── 7. NÚT LƯU ───────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        // Disable nút khi đang loading, tránh double submit
                        onPressed: _isLoading ? null : _submitEdit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppStyles.brL,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                'LƯU THAY ĐỔI',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
