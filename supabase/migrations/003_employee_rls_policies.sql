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
-- HÀM KIỂM TRA ADMIN
-- ---------------------------------------------------------------------------
-- SECURITY DEFINER: Hàm chạy với quyền của owner (bypass RLS), tránh lỗi
-- infinite recursion khi policy của bảng employees tự gọi lại chính nó.
-- STABLE: Kết quả không thay đổi trong cùng 1 transaction → được cache lại,
-- giúp tối ưu hiệu suất khi hàm được gọi nhiều lần.
-- SET search_path = public: Tránh lỗi search_path injection.
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.employees
    WHERE id = auth.uid()
      AND user_role = 'admin'
  );
$$;

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
-- Dùng hàm is_admin() thay vì subquery trực tiếp vào bảng employees
-- để tránh lỗi infinite recursion (policy tự tham chiếu chính bảng của nó).
CREATE POLICY "admin_read_all_employees"
ON employees
FOR SELECT
USING (
  is_admin()
);

-- ---------------------------------------------------------------------------
-- POLICY: Admin CẬP NHẬT thông tin nhân viên
-- ---------------------------------------------------------------------------
-- Dùng hàm is_admin() thay vì subquery trực tiếp vào bảng employees
-- để tránh lỗi infinite recursion (policy tự tham chiếu chính bảng của nó).
CREATE POLICY "admin_update_employee"
ON employees
FOR UPDATE
USING (
  is_admin()
);
