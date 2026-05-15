# ResolveX - Enterprise Issue Reporting System

## I. Tổng quan dự án (Project Overview)

### 1. Giới thiệu
**ResolveX** là giải pháp phần mềm chuyên dụng nhằm số hóa quy trình báo cáo và quản lý các sự cố kỹ 
thuật, hạ tầng và thiết bị trong môi trường doanh nghiệp. Hệ thống tối ưu hóa sự tương tác giữa nhân 
viên và bộ phận kỹ thuật, đảm bảo mọi vấn đề phát sinh đều được ghi nhận và xử lý theo quy trình chuẩn hóa.

### 2. Mục tiêu hệ thống
* **Tối ưu hóa vận hành:** Giảm thiểu thời gian chết (downtime) của thiết bị thông qua cơ chế phản hồi thời gian thực.
* **Minh bạch hóa dữ liệu:** Hệ thống hóa lịch sử sự cố, hỗ trợ công tác thống kê và đánh giá hiệu năng thiết bị.
* **Tăng cường hiệu suất:** Hỗ trợ điều phối nguồn lực kỹ thuật chính xác dựa trên mức độ ưu tiên của báo cáo.
---

## II. Kiến trúc công nghệ (Technical Stack)

Hệ thống được xây dựng trên nền tảng công nghệ tiên tiến nhằm đảm bảo tính ổn định và khả năng mở rộng:

| Thành phần      | Công nghệ sử dụng | Mô tả                                                                      |
|:----------------|:------------------|:---------------------------------------------------------------------------|
| **Frontend**    | Flutter SDK       | Phát triển ứng dụng đa nền tảng (Cross-platform) với hiệu năng cao.        |
| **Ngôn ngữ**    | Dart              | Ngôn ngữ lập trình hướng đối tượng, tối ưu cho UI/UX.                      |
| **Backend**     | Supabase          | Nền tảng BaaS (Backend as a Service) cung cấp Database, Auth và Real-time. |
| **Quản trị DB** | DBeaver           | Công cụ quản trị cơ sở dữ liệu quan hệ chuyên sâu.                         |
| **API**         | Chưa xác định     | Chưa xác dịnh                                                              |

---

## III. Mô hình phân quyền (Role-Based Access Control - RBAC)

Hệ thống phân định quyền hạn người dùng dựa trên các nhóm vai trò cụ thể:

### 1. Vai trò Quản trị viên (Administrator)
* Quản trị hệ thống người dùng và danh mục dữ liệu cốt lõi.
* Giám sát luồng công việc và điều phối kỹ thuật viên xử lý báo cáo.
* Thực hiện các thao tác quản trị dữ liệu (CRUD) nâng cao.

### 2. Vai trò Nhân viên (End-User)
* Khởi tạo báo cáo sự cố kèm theo minh chứng hình ảnh và mô tả chi tiết.
* Theo dõi tiến độ xử lý của các báo cáo đã gửi.
* Quản lý thông tin tài khoản và bảo mật định danh cá nhân.

---

## IV. Luồng nghiệp vụ chính (Core Workflows)

### 1. Quy trình xử lý báo cáo
1.  **Khởi tạo:** Nhân viên cung cấp thông tin về loại sự cố, vị trí địa lý và mức độ nghiêm trọng.
2.  **Tiếp nhận:** Hệ thống thông báo đến Quản trị viên thông qua giao thức Real-time.
3.  **Điều phối:** Quản trị viên phê duyệt và chỉ định nhân sự chuyên trách xử lý.
4.  **Hoàn tất:** Sau khi khắc phục, trạng thái báo cáo được cập nhật đồng bộ trên toàn hệ thống.

### 2. Quản trị dữ liệu
Quản trị viên sử dụng giao diện Dashboard để thực hiện các tác vụ lưu trữ, truy xuất và phân tích 
lịch sử báo cáo nhằm mục đích báo cáo định kỳ hoặc bảo trì hệ thống.

---

## V. Cấu trúc cơ sở dữ liệu (Database Schema)
*(Phần này sẽ được cập nhật chi tiết sau khi hoàn thiện sơ đồ ERD).*