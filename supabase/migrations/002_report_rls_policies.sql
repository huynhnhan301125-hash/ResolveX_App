-- =============================================================================
-- MIGRATION: RLS Policies cho bảng reports
--
-- Phân quyền:
--   - Nhân viên: Tạo báo cáo của mình, đọc tất cả, sửa/xóa của mình
--               (chỉ trong 10 phút đầu khi status còn 'pending')
--   - Admin:    Đọc / Sửa / Xóa bất kỳ báo cáo nào, không giới hạn
--
-- Lưu ý quan trọng:
--   - Tất cả policy admin dùng is_admin() — hàm này được định nghĩa trong
--     migration 003_employee_rls_policies.sql với SECURITY DEFINER.
--   - Admin UPDATE phải có WITH CHECK = is_admin() để tránh bị chặn bởi
--     employee policy khi admin sửa báo cáo của nhân viên khác.
--   - Không được tạo policy trùng tên (gây xung đột và hành vi không xác định).
--
-- Cách chạy: Dán vào Supabase Dashboard → SQL Editor → Run
-- =============================================================================

-- ---------------------------------------------------------------------------
-- XÓA POLICY CŨ (nếu đã tồn tại) để tránh lỗi khi chạy lại
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "employee: create own report"  ON reports;
DROP POLICY IF EXISTS "employee: read all reports"   ON reports;
DROP POLICY IF EXISTS "employee: update own report"  ON reports;
DROP POLICY IF EXISTS "employee: delete own report"  ON reports;
DROP POLICY IF EXISTS "admin: read all reports"      ON reports;
DROP POLICY IF EXISTS "admin: update report"         ON reports;
DROP POLICY IF EXISTS "admin: delete report"         ON reports;

-- ---------------------------------------------------------------------------
-- POLICY: Nhân viên TẠO báo cáo mới
-- ---------------------------------------------------------------------------
-- WITH CHECK: nhân viên chỉ được tạo báo cáo dưới đúng ID của mình
CREATE POLICY "employee: create own report"
ON reports FOR INSERT
WITH CHECK (auth.uid() = emp_id);

-- ---------------------------------------------------------------------------
-- POLICY: Tất cả user đã đăng nhập ĐỌC danh sách báo cáo
-- ---------------------------------------------------------------------------
-- Áp dụng cho cả nhân viên lẫn admin (admin: read all reports chỉ để rõ ràng)
CREATE POLICY "employee: read all reports"
ON reports FOR SELECT
USING (auth.role() = 'authenticated');

-- ---------------------------------------------------------------------------
-- POLICY: Nhân viên SỬA báo cáo của mình
-- ---------------------------------------------------------------------------
-- USING: điều kiện để hàng được phép UPDATE:
--   1. Phải là báo cáo của chính mình
--   2. Status còn 'pending' (chưa admin xử lý)
--   3. Trong vòng 10 phút kể từ lúc tạo
-- WITH CHECK: điều kiện cho dữ liệu SAU KHI UPDATE:
--   - Không được đổi emp_id (không chuyển báo cáo cho người khác)
--   - Không được đổi status (chỉ admin mới được đổi)
CREATE POLICY "employee: update own report"
ON reports FOR UPDATE
USING (
  auth.uid() = emp_id
  AND status = 'pending'
  AND report_date > NOW() - INTERVAL '10 minutes'
)
WITH CHECK (
  auth.uid() = emp_id
  AND status = 'pending'
);

-- ---------------------------------------------------------------------------
-- POLICY: Nhân viên XÓA báo cáo của mình
-- ---------------------------------------------------------------------------
-- Logic giống UPDATE: phải là của mình + pending + trong 10 phút
CREATE POLICY "employee: delete own report"
ON reports FOR DELETE
USING (
  auth.uid() = emp_id
  AND status = 'pending'
  AND report_date > NOW() - INTERVAL '10 minutes'
);

-- ---------------------------------------------------------------------------
-- POLICY: Admin ĐỌC tất cả báo cáo
-- ---------------------------------------------------------------------------
-- Dùng is_admin() — hàm có SECURITY DEFINER, bypass RLS, không gây recursion
CREATE POLICY "admin: read all reports"
ON reports FOR SELECT
USING (is_admin());

-- ---------------------------------------------------------------------------
-- POLICY: Admin SỬA bất kỳ báo cáo nào
-- ---------------------------------------------------------------------------
-- WITH CHECK = is_admin() là BẮT BUỘC:
--   Nếu không có WITH CHECK, PostgreSQL sẽ kiểm tra WITH CHECK của policy
--   "employee: update own report" → điều kiện auth.uid() = emp_id sẽ FAIL
--   khi admin sửa báo cáo của nhân viên khác → bị chặn dù USING đã pass.
CREATE POLICY "admin: update report"
ON reports FOR UPDATE
USING (is_admin())
WITH CHECK (is_admin());

-- ---------------------------------------------------------------------------
-- POLICY: Admin XÓA bất kỳ báo cáo nào
-- ---------------------------------------------------------------------------
CREATE POLICY "admin: delete report"
ON reports FOR DELETE
USING (is_admin());
