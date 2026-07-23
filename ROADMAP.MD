## TIẾN TRÌNH CHI TIẾT (MILESTONES)

### Giai đoạn 1: UI/UX Foundation (Start | 21/04/2026)
- [X] **Màn hình Login:** 2 input field, nút đăng nhập, logo app, text button "Quên mật khẩu".
- [X] **Màn hình nhập email & hộp thoại mã OTP:** Input email, nút gửi/gửi lại OTP, dialog nhập PIN OTP.
- [X] **Màn hình đặt lại mật khẩu:** Phân luồng OTP và Settings, input mật khẩu cũ/mới/xác nhận.
- [X] **Màn hình Dashboard (Staff/Admin):** Body Ticket Card, phân loại màu sắc trạng thái, Bottom Navigation Menu.
- [X] **Màn hình chi tiết báo cáo:** Thông tin chi tiết, hình ảnh, đồng hồ đếm ngược 10 phút đếm ngược quyền sửa.
- [X] **Màn hình Create Ticket (Full Screen):** Chuyển từ Popup sang trang riêng, nút Hủy & nút Back chuẩn.
- [X] **Màn hình Profile/Settings:** Thông tin cá nhân, Dark Mode toggle thực tế, Đăng xuất.

### Giai đoạn 2: Database & Backend Setup
- [X] Thiết kế Schema trên Supabase (Tables: `employees`, `reports`).
- [X] Kết nối Flutter với Supabase Auth & Session Stream.
- [X] Viết Logic CRUD cho Report/Ticket (Tạo, Đọc, Sửa, Xóa, Phân trang Pagination).
- [X] **[Bổ sung] Real-time WebSockets:** Lắng nghe thay đổi báo cáo tức thì qua `RealtimeChannel`.
- [X] **[Bổ sung] Supabase RLS Policies:** Thiết lập Row Level Security bảo mật 2 lớp cho Nhân viên & Admin.
- [X] **[Bổ sung] Admin CSV Import:** Màn hình import nhân viên hàng loạt từ file CSV (`ImportEmployeesScreen`).
- [X] **[Bổ sung] Dark/Light Theme Storage:** Lưu trữ cấu hình Chế độ tối/sáng vĩnh viễn xuống `SharedPreferences`.

### Giai đoạn 2.5: Kiến Trúc & Tối Ưu Hiệu Năng (Refactoring & Architecture)
- [X] **Phân tầng kiến trúc Clean:** View $\rightarrow$ Service $\rightarrow$ SupabaseClient (Không gọi DB trực tiếp từ View).
- [X] **Tối ưu bộ nhớ RAM:** Áp dụng `ShellRoute` quản lý `ReportProvider` tự hủy khi đăng xuất.
- [X] **Tối ưu Re-render (60 FPS):** Chuyển từ Prop Drilling sang `context.select` chọn lọc.
- [X] **Tối ưu Render Layout:** Loại bỏ Anti-pattern `IntrinsicHeight` (Double-pass layout).
- [X] **Type-Safe Routing:** Chuyển từ `Map<String, dynamic>` sang Class `EditReportExtra` phòng văng app.
- [X] **Bảo vệ Bộ nhớ:** Dispose 100% Controllers, ValueNotifier, Timer và StreamSubscription.
- [X] **Lưới bắt lỗi toàn cục:** Tích hợp `runZonedGuarded` + `FlutterError.onError` và kiểm tra an toàn `.env`.

### Giai đoạn 3: AI & Camera Integration (Tính năng "khè" thầy)
- [X] Tích hợp Camera chụp ảnh & chọn ảnh từ thư viện (`ImagePicker` Lazy Loading).
- [ ] Kết nối Gemini Vision API để tự phân loại lỗi qua ảnh.
- [ ] Quét mã QR để định vị thiết bị nhanh.

### Giai đoạn 4: Final Polish & Deployment
- [ ] Hệ thống Push Notification (Thông báo khi có ticket mới).
- [ ] Build bản Web App (PWA) để demo 0đ.
- [ ] Xuất file APK nộp cho thầy gắt.

---

## 📝 NHẬT KÝ LỖI & FIX (ISSUE LOG CHI TIẾT DỰ ÁN)

- *20/04/2026:* Giao diện cũ xấu -> Quyết định làm lại Full Screen cho màn Create Ticket.
- *22/07/2026:* **[FIX #1]** `ColorScheme.fromSeed()` làm lệch màu thương hiệu -> Chuyển sang định nghĩa cứng `ColorScheme.light()` & `ColorScheme.dark()`.
- *22/07/2026:* **[FIX #2]** Nút bấm bị biến đổi màu ngẫu nhiên -> Ép màu `backgroundColor` & `foregroundColor` cố định trong `ElevatedButtonThemeData`.
- *22/07/2026:* **[FIX #2 - Env]** Crash app do toán tử `!` khi đọc file `.env` -> Bọc try-catch và kiểm tra null chủ động với Exception hướng dẫn chi tiết.
- *22/07/2026:* **[FIX #3 - Theme]** Nhãn TextField (Floating Label) tàng hình trong Dark Mode khi bay lên -> Cấu hình `floatingLabelStyle` màu vàng `brandPrimary` nổi bật trên nền tối.
- *22/07/2026:* **[FIX #3 - Extra]** Dùng `Map<String, dynamic>` nhầm key String gây Runtime Error Crash -> Chuyển sang dùng Class `EditReportExtra` Type-Safe (Compile Time Error).
- *22/07/2026:* **[FIX #4]** Nút bấm che thanh điều hướng Android -> Bọc `SafeArea` tự động thêm padding đáy theo thiết bị.
- *23/07/2026:* **[FIX #5]** `didChangeDependencies` + `context.watch` gây F5 hai lần liên tiếp / vòng lặp rebuild -> Chuyển sang `context.select` trực tiếp trong `build()`.
- *23/07/2026:* **[FIX #6]** Nút Đăng nhập rebuild thừa khi `errorMessage` thay đổi -> Thay `Builder` bằng `context.select<AuthProvider, bool>((p) => p.isLoading)`.
- *23/07/2026:* **[FIX #7]** Tầng View chọc thẳng `Supabase.instance.client` vi phạm phân tầng -> Đổi sang gọi qua `AuthService().currentUser`.
- *23/07/2026:* **[FIX #8]** Dialog Loading che toàn màn hình dễ `Navigator.pop()` nhầm -> Chuyển sang biến `_isSubmitting` với nút bấm khóa `onPressed = null` + `CircularProgressIndicator`.
- *23/07/2026:* **[FIX - Memory]** `ImagePicker` toàn cục làm tốn RAM khi vừa mở màn hình -> Đổi sang Lazy Initialization chỉ khởi tạo khi bấm chọn ảnh.
- *23/07/2026:* **[FIX - Memory Leak]** `Future.delayed` đệ quy làm rò rỉ RAM -> Chuyển sang `Timer.periodic` và hủy `timer.cancel()` trong `dispose()`.
- *23/07/2026:* **[FIX - Performance]** `IntrinsicHeight` làm giật lag khi cuộn danh sách -> Xóa `IntrinsicHeight` triệt tiêu Double-pass layout.
- *23/07/2026:* **[FIX - Tab State]** Chuyển Tab bị reset vị trí cuộn cuộn (Scroll Position) -> Khai báo mảng `late final _pages` ở `initState()` thay vì trong `build()`.
- *23/07/2026:* **[FIX - DB SQL]** Lỗi ép kiểu UUID trong RLS Policy ở Supabase Database -> Cập nhật lại migration `002_report_rls_policies.sql` và `003_employee_rls_policies.sql`.
