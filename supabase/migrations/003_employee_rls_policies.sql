-- =============================================================================
-- MIGRATION: RLS Policies cho bảng employees
--
-- Phân quyền:
--   - Nhân viên: Chỉ được đọc thông tin của chính mình.
--   - Admin: Được quyền xem tất cả và chỉnh sửa thông tin nhân viên.
--
-- Cách chạy: Dán vào Supabase Dashboard → SQL Editor → Run
-- =============================================================================

-- ---------------------------------------------------------------------------
-- XÓA POLICY CŨ (nếu đã tồn tại) để tránh lỗi khi chạy lại
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "employee_read_own_profile" ON employees;
DROP POLICY IF EXISTS "admin_read_all_employees" ON employees;
DROP POLICY IF EXISTS "admin_update_employee" ON employees;

-- Xóa các policy đang có trên Supabase để đồng bộ với tên mới
DROP POLICY IF EXISTS "admin: read all employees" ON employees;
DROP POLICY IF EXISTS "admin: update employee" ON employees;
DROP POLICY IF EXISTS "employee: read own profile" ON employees;

-- ---------------------------------------------------------------------------
-- POLICY: Nhân viên ĐỌC thông tin của chính mình
-- ---------------------------------------------------------------------------
-- USING: Chỉ hiển thị dữ liệu nếu ID của dòng tương ứng khớp với ID người dùng
CREATE POLICY "employee_read_own_profile"
ON employees
FOR SELECT
USING (
  auth.uid() = id
);

-- ---------------------------------------------------------------------------
-- POLICY: Admin ĐỌC toàn bộ danh sách nhân viên
-- ---------------------------------------------------------------------------
-- USING: Hàm is_admin() kiểm tra quyền Admin của user hiện tại
CREATE POLICY "admin_read_all_employees"
ON employees
FOR SELECT
USING (
  -- Sử dụng hàm kiểm tra admin (nếu bạn dùng hàm tùy chỉnh)
  -- Hoặc dùng truy vấn trực tiếp bảng nếu chưa có hàm: 
  -- (SELECT user_role FROM employees WHERE id = auth.uid()) = 'admin'
  (SELECT user_role FROM employees WHERE id = auth.uid()) = 'admin'
);

-- ---------------------------------------------------------------------------
-- POLICY: Admin CẬP NHẬT thông tin nhân viên
-- ---------------------------------------------------------------------------
-- USING: Chỉ admin mới có quyền thực hiện UPDATE
CREATE POLICY "admin_update_employee"
ON employees
FOR UPDATE
USING (
  (SELECT user_role FROM employees WHERE id = auth.uid()) = 'admin'
);
