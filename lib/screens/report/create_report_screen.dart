import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/services/report_service.dart';
import 'package:resolvex_mobile_app/services/auth_service.dart';
// [FIX #7] Thay import supabase_flutter bằng auth_service.dart.
// Tầng View (Screen) không được phép gọi thẳng vào SupabaseClient.
// Phải đi qua AuthService (tầng Service) để lấy currentUser —
// đúng phân tầng kiến trúc, dễ test và dễ thay thế sau này.
import 'package:resolvex_mobile_app/core/theme/theme.dart';
import 'package:resolvex_mobile_app/utils/app_validate.dart';
import 'package:resolvex_mobile_app/widgets/rx_customscrollview.dart';
import 'package:resolvex_mobile_app/widgets/rx_textfield.dart';

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
  // ✅ Fix (Memory): Xóa khai báo ImagePicker toàn cục để tránh chiếm dụng RAM ngay khi mở màn hình.

  // ✅ Fix (Crash): Dùng biến nullable cho ID thay vì force-unwrap (!) trực tiếp tại lúc khởi tạo.
  String? _currentId;

  // [FIX #8] Biến kiểm soát trạng thái đang gửi báo cáo.
  // true  = đang gửi → nút bấm bị vô hiệu, hiện icon xoay xoay (Loading Spinner).
  // false = rảnh rỗi → nút bấm bình thường, hiện chữ "GỬi BÁO CÁO".
  //
  // Lợi thế so với showDialog loading popup:
  //   - Không cần quản lý 2 lệnh Navigator.pop() riêng (1 cho dialog, 1 cho screen).
  //   - Không lo rủi ro pop nhầm màn hình nếu logic phức tạp hơn sau này.
  //   - UX hiện đại hơn: người dùng vẫn nhìn thấy form, không bị che bởi hộp thoại.
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // [FIX #7] Lấy currentUser qua AuthService thay vì gọi thẳng Supabase.instance
    //
    // VẤN ĐỀ CŨ: Supabase.instance.client.auth.currentUser?.id
    //   Tầng View (Screen) chọc thẳng vào SupabaseClient — "vượt quyền" tầng Service.
    //   Vi phạm nguyên tắc phân tầng: View → Service → Database.
    //   Khó test: không thể mock Supabase.instance trong Unit Test.
    //
    // GIẢI PHÁP: Dùng AuthService().currentUser?.id
    //   AuthService đã có getter currentUser (auth_service.dart line 78).
    //   Tầng View chỉ biết AuthService tồn tại, không biết bên trong dùng thư viện gì.
    _currentId = AuthService().currentUser?.id;

    if (_currentId == null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Phiên đăng nhập hết hạn!'), backgroundColor: Colors.red),
        );
      });
    }
  }

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
    // ✅ Fix (Memory): Khởi tạo ImagePicker (Lazy initialization) chỉ khi người dùng bấm chụp/chọn ảnh
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 70);
    if (image != null) setState(() => _selectedImage = File(image.path));
  }

  /// Hàm xử lý gửi báo cáo sự cố
  Future<void> _submitReport() async {
    // Đảm bảo user id hợp lệ trước khi gửi
    if (_currentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể gửi báo cáo vì chưa xác thực người dùng!'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // [FIX #8] Bật trạng thái loading ngay khi bắt đầu gửi.
    // setState → build() chạy lại → nút chuyển sang hiện CircularProgressIndicator
    // và onPressed = null (không cho bấm nhiều lần).
    setState(() => _isSubmitting = true);

    try {
      // GỎi Supabase + AWAIT (chờ DB insert xong mới chạy tiếp)
      final ReportModel savedReport = await ReportService().createReport(
        empId: _currentId!,
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

      // Đóng màn hình và trả object THẬT về cho màn hình gọi.
      // MainEmployeeScreen dùng object này để insert vào listReport → UI tự cập nhật.
      if (mounted) context.pop(savedReport);
    } catch (e) {
      // Nếu lỗi (mất mạng, RLS từ chối...) → hiện snackbar đỏ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gửi báo cáo thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // [FIX #8] finally LUON chạy dù thành công hay lỗi.
      // Tắt loading để nút trở lại bình thường nếu có lỗi (không đóng màn hình).
      // mounted check: tránh gọi setState() sau khi màn hình đã được đóng (dispose).
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [FIX — Nút ghím cố định + Loading Button]
      // Đưa nút ra khỏi ScrollView, đặt vào bottomNavigationBar.
      // SafeArea tự động thêm padding phía dưới bằng đúng chiều cao
      // thanh 3 nút hệ thống — không cần hardcode, đúng mọi dòng máy.
      //
      // [FIX #8] Nút có 2 trạng thái:
      //   _isSubmitting = false: Hiện chữ "GỬi BÁO CÁO", bấm được bình thường.
      //   _isSubmitting = true : onPressed = null (khóa nút), hiện vòng xoay loading.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppStyles.spaceL,
            AppStyles.spaceS,
            AppStyles.spaceL,
            AppStyles.spaceM,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              // _isSubmitting = true → null = vô hiệu hóa nút (không cho bấm nhiều lần)
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandDark,
                shape: RoundedRectangleBorder(borderRadius: AppStyles.brL),
              ),
              child: _isSubmitting
                  // Hiện vòng xoay (Spinner) ngay trên nút khi đang gửi
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  // Hiện chữ bình thường khi rảnh rỗi
                  : const Text(
                      'GỬi BÁO CÁO',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
          ),
        ),
      ),
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
                // [FIX — System Navigation Bar]
                // Trên Android modern (Edge-to-Edge), app vẽ xuyên qua cả vùng thanh 3 nút hệ thống.
                // MediaQuery.of(context).padding.bottom trả về chiều cao của vùng đó (ví dụ: 48px).
                // Cộng thêm vào padding.bottom để nút "GỬI BÁO CÁO" không bị thanh đó đè lên.
                // Không cần hardcode giá trị cứng — tự động chính xác cho mọi dòng máy.
                padding: EdgeInsets.only(
                  left: AppStyles.spaceL,
                  right: AppStyles.spaceL,
                  top: AppStyles.spaceL,
                  bottom: AppStyles.spaceL + MediaQuery.of(context).padding.bottom,
                ),
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
                    // Nút "GỬI BÁO CÁO" đã được chuyển ra bottomNavigationBar
                    // phía trên để ghim cố định, không còn nằm trong ScrollView nữa.
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
