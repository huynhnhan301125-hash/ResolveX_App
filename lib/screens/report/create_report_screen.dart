import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/services/report_service.dart';
import 'package:resolvex_mobile_app/core/theme/theme.dart';
import 'package:resolvex_mobile_app/utils/app_validate.dart';
import 'package:resolvex_mobile_app/widgets/rx_customscrollview.dart';
import 'package:resolvex_mobile_app/widgets/rx_textfield.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  // GlobalKey để quản lý Form validation
  final _formKey = GlobalKey<FormState>();

  // Controllers thu thập dữ liệu chữ từ các ô nhập
  final _roomController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Biến lưu trữ trạng thái lựa chọn của Form (Mặc định khi mở màn hình)
  ProblemType _selectedType = ProblemType.software;
  Level _selectedLevel = Level.low;

  // File lưu trữ ảnh tạm thời được chụp/chọn từ máy
  File? _selectedImage;
  // Thời gian xảy ra sự cố (Mặc định lấy thời gian hiện tại)
  DateTime _selectedDate = DateTime.now();
  // Thư viện ImagePicker để tương tác với máy ảnh / thư viện của máy
  final ImagePicker _picker = ImagePicker();
  // Lây ID của user đang đăng nhập bằng supabase
  String currentId = Supabase.instance.client.auth.currentUser!.id;

  @override
  void dispose() {
    // Luôn giải phóng bộ nhớ khi hủy màn hình
    _roomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Hàm mở giao diện chọn Ngày và Giờ (Date & Time Picker)
  Future<void> _pickDateTime() async {
    // 1. Mở DatePicker để chọn ngày (Năm - Tháng - Ngày)
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (mounted && pickedDate != null) {
      // 2. Nếu đã chọn ngày thành công, tiếp tục mở TimePicker để chọn giờ (Giờ - Phút)
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (pickedTime != null) {
        // 3. Hợp nhất thông tin ngày và giờ đã chọn vào biến trạng thái _selectedDate
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day,
            pickedTime.hour, pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source, imageQuality: 70);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  /// Hàm xử lý gửi báo cáo sự cố
  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {

      // 1. Hiện loading dialog TRƯỚC khi gọi mạng
      // barrierDismissible: false -> người dùng không bấm ra ngoài tắt được
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Đang gửi báo cáo sự cố...'),
            ],
          ),
        ),
      );

      try {
        // 2. GỌI SUPABASE + AWAIT (chờ DB insert xong mới chạy tiếp)
        // Thiếu await -> app không chờ -> đóng màn hình ngay dù DB chưa xong
        // savedReport là object THẬT được DB trả về (có reportId, reportDate thật)
        final ReportModel savedReport = await ReportService().createReport(
          empId: currentId, // UID thật lấy từ Supabase Auth session (dòng 43)
          problemRoom: _roomController.text.trim(),
          problemType: _selectedType,
          level: _selectedLevel,
          problemDescription: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );

        if (kDebugMode) {
          print('=== BÁO CÁO ĐÃ LƯU LÊN SUPABASE ===');
          print('Report ID thật: ${savedReport.reportId}');
          print('Phòng: ${savedReport.problemRoom}');
          print('Loại lỗi: ${savedReport.problemType.label}');
          print('Thời gian: ${savedReport.reportDate}');
        }

        if (mounted) {
          // 3. Tắt loading dialog
          Navigator.of(context, rootNavigator: true).pop();
          // 4. Đóng màn hình và trả object THẬT về cho MainEmployeeScreen
          // MainEmployeeScreen dùng object này để insert vào listReport -> UI tự cập nhật
          context.pop(savedReport);
        }
      } catch (e) {
        // Nếu lỗi (mất mạng, RLS từ chối...) -> tắt loading, hiện snackbar đỏ
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gửi báo cáo thất bại: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: RXCustomScrollView(
            title: const Text('Tạo báo cáo mới', style: TextStyle(fontWeight: FontWeight.bold)),
            expandedHeight: 70,
            showBackButton: true,
            sliver: [
              SliverPadding(
                padding: const EdgeInsets.all(AppStyles.spaceL),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Vị trí (Phòng)
                    const Text('Vị trí sự cố', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: AppStyles.spaceS),
                    RXTextField(
                      controller: _roomController,
                      labelText: 'Ví dụ: Phòng A.102',
                      prefixIcon: const Icon(Icons.location_on),
                      validator: (value) => AppValidate.checkEmpty(value, 'Vị trí phòng'),
                    ),
                    const SizedBox(height: AppStyles.spaceXL),

                    // 2. Loại vấn đề
                    const Text('Loại vấn đề', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: AppStyles.spaceS),
                    DropdownButtonFormField<ProblemType>(
                      initialValue: _selectedType,
                      dropdownColor: AppColors.surfaceWhite,
                      style: const TextStyle(color: AppColors.textPrimary),
                      items: ProblemType.values.map((type) => DropdownMenuItem(
                        value: type,
                        child: Row(children: [
                          Icon(type.icon, color: type.color),
                          const SizedBox(width: 10),
                          Text(type.label, style: const TextStyle(color: AppColors.textPrimary)),
                        ]),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedType = value!),
                    ),
                    const SizedBox(height: AppStyles.spaceXL),

                    // 3. Mức độ ưu tiên
                    const Text('Mức độ ưu tiên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: AppStyles.spaceS),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: Level.values.map((level) {
                        final bool isSelected = _selectedLevel == level;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedLevel = level),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? level.color : level.color.withValues(alpha: .1),
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

                    // 4. Mô tả chi tiết
                    const Text('Mô tả chi tiết', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: AppStyles.spaceS),
                    RXTextField(
                      controller: _descriptionController,
                      labelText: 'Nhập mô tả tình trạng hư hỏng...',
                      minLines: 3,
                      maxLines: 5,
                    ),
                    const SizedBox(height: AppStyles.spaceXXXL),

                    // 5. Chọn thời gian
                    const Text('Thời gian ghi nhận', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: AppStyles.spaceS),
                    InkWell(
                      onTap: _pickDateTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(color: Theme.of(context).colorScheme.outline),
                          borderRadius: AppStyles.brL,
                          color: AppColors.surfaceWhite,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Dùng DateFormat thay vì format thủ công
                            Text(DateFormat('dd/MM/yyyy - HH:mm').format(_selectedDate), style: const TextStyle(fontSize: 16)),
                            const Icon(Icons.calendar_today, color: Colors.blue),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppStyles.spaceXL),

                    // 6. Chụp / Chọn ảnh
                    const Text('Hình ảnh đính kèm (Tùy chọn)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: AppStyles.spaceS),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Chụp ảnh'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.image),
                          label: const Text('Thư viện'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppStyles.spaceM),

                    // 7. Preview ảnh
                    if (_selectedImage != null)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: AppStyles.brM,
                            child: Image.file(_selectedImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 5, right: 5,
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              child: IconButton(
                                icon: Icon(Icons.close, color: Theme.of(context).scaffoldBackgroundColor),
                                onPressed: () => setState(() => _selectedImage = null),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppStyles.spaceXXXL),

                    // 8. Nút Gửi
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandDark,
                          shape: RoundedRectangleBorder(borderRadius: AppStyles.brL),
                        ),
                        child: Text(
                          'GỬI BÁO CÁO',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ),
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
