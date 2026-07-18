## TIẾN TRÌNH CHI TIẾT (MILESTONES)

### Giai đoạn 1: UI/UX Foundation (Start | 21/04/2026)
- [X] **Màn hình Login:** 
    - Xây dựng 2 input field: đăng nhập, mật khẩu
    - Nút đăng nhập.
    - Logo app.
    - Text button "Quên mật khẩu".
- [X] **Màn hình nhập email (quên mật khẩu) và hộp thoại mã OTP: **
    - Input nhập email
    - Nút xác nhận email
    - Hộp thoại nhận và nhâp mã OTP
    - Text button gửi lại mã OTP.
    - Nút gửi OTP
- [X] **Màn hình đặt lại mật khẩu:**
    - Hai luông chính: Khi nhập OTP quên mật khẩu thành công, khi đổi mật khẩu từ cài đặt
    - Xây dựng 2 input field: mật khẩu cũ (xuất hiện khi thiết lập ở cài đặt), mật khẩu mới, xác nhận mật khẩu mới
    - Nút xác nhận.
- [X] **Màn hình Dashboard (Staff/Admin):**
    - Thiết kế lại Body danh sách Ticket (Dạng Card, không làm kiểu bảng xấu nữa).
    - Phân loại màu sắc theo trạng thái (Đang chờ, Đã xong, Đang sửa).
    - Xây dựng menu tác vụ ( trang chủ, danh sách báo cáo, tạo báo cáo mới, lịch sử, cài đặt).
- [X] **Màn hình chi tiết báo cáo:
    - Hiện các trường thông tin cơ bản, chi tiết của báo cáo: mô tả, hình ảnh,..,
- [X] **Màn hình Create Ticket (Full Screen):**
    - Chuyển từ Popup sang trang riêng.
    - Đổi nút "Reset" -> "Hủy".
    - Thêm nút "Quay lại" (Back) chuẩn cho tất cả trang.
- [X] **Màn hình Profile/Settings:** Thông tin cá nhân & Đăng xuất.

### Giai đoạn 2: Database & Backend Setup
- [ ] Thiết kế Schema trên Supabase (Tables: Users, Tickets, Devices).
- [ ] Kết nối Flutter với Supabase Auth.
- [ ] Viết Logic CRUD cho Ticket (Tạo, Đọc, Sửa trạng thái).

### Giai đoạn 3: AI & Camera Integration (Tính năng "khè" thầy)
- [ ] Tích hợp Camera chụp ảnh.
- [ ] Kết nối Gemini Vision API để tự phân loại lỗi qua ảnh.
- [ ] Quét mã QR để định vị thiết bị nhanh.

### Giai đoạn 4: Final Polish & Deployment
- [ ] Hệ thống Push Notification (Thông báo khi có ticket mới).
- [ ] Build bản Web App (PWA) để demo 0đ.
- [ ] Xuất file APK nộp cho thầy gắt.

---

## 📝 NHẬT KÝ LỖI & FIX (ISSUE LOG)
- *20/04/2026:* Thầy chê giao diện cũ xấu -> Quyết định làm lại Full Screen cho màn Create Ticket.
- *Chưa fix:* Lỗi logic chia lương trong SQL (Đã bàn cách sửa).