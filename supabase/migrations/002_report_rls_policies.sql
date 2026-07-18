-- =============================================================================
-- MIGRATION: RLS Policies cho phép Nhân viên sửa/xóa báo cáo của mình
--
-- Giới hạn:
--   - Chỉ báo cáo của chính mình (auth.uid() = emp_id)
--   - Chỉ khi status = 'pending' (chưa Admin xử lý)
--   - Chỉ trong 10 phút đầu kể từ lúc tạo
--
-- Cách chạy: Dán vào Supabase Dashboard → SQL Editor → Run
-- =============================================================================

-- ---------------------------------------------------------------------------
-- XÓA POLICY CŨ (nếu đã tồn tại) để tránh lỗi khi chạy lại
-- ---------------------------------------------------------------------------
DROP POLICY IF EXISTS "employee_update_own_report" ON reports;
DROP POLICY IF EXISTS "employee_delete_own_report" ON reports;
DROP POLICY IF EXISTS "admin_update_any_report" ON reports;
DROP POLICY IF EXISTS "admin_delete_any_report" ON reports;
DROP POLICY IF EXISTS "employee_create_own_report" ON reports;
DROP POLICY IF EXISTS "employee_read_all_reports" ON reports;
DROP POLICY IF EXISTS "admin_read_all_reports" ON reports;

-- ---------------------------------------------------------------------------
-- POLICY: Nhân viên TẠO báo cáo mới
-- ---------------------------------------------------------------------------
-- WITH CHECK: đảm bảo nhân viên chỉ có thể tạo báo cáo dưới ID của chính mình
CREATE POLICY "employee_create_own_report"
ON reports
FOR INSERT
WITH CHECK (
  auth.uid()::TEXT = emp_id
);

-- ---------------------------------------------------------------------------
-- POLICY: Nhân viên ĐỌC danh sách báo cáo
-- ---------------------------------------------------------------------------
-- USING: cho phép bất kỳ user nào đã đăng nhập đều có thể đọc
CREATE POLICY "employee_read_all_reports"
ON reports
FOR SELECT
USING (
  auth.role() = 'authenticated'
);

-- ---------------------------------------------------------------------------
-- POLICY: Nhân viên CẬP NHẬT báo cáo của mình
-- ---------------------------------------------------------------------------
-- USING: điều kiện áp dụng cho hàng đang được chọn để UPDATE
-- WITH CHECK: điều kiện áp dụng cho dữ liệu MỚI sau khi UPDATE
-- Cả 2 điều kiện phải đúng thì UPDATE mới thành công
CREATE POLICY "employee_update_own_report"
ON reports
FOR UPDATE
USING (
  -- 1. Báo cáo phải là của người đang đăng nhập
  auth.uid()::TEXT = emp_id

  -- 2. Chỉ cập nhật được khi báo cáo còn ở trạng thái 'pending'
  AND status = 'pending'

  -- 3. Chỉ trong vòng 10 phút kể từ lúc tạo
  -- NOW() - INTERVAL '10 minutes' = thời điểm 10 phút trước
  AND report_date > NOW() - INTERVAL '10 minutes'
)
WITH CHECK (
  -- Điều kiện cho dữ liệu MỚI: nhân viên không được đổi emp_id hay status
  -- emp_id phải giữ nguyên (không chuyển báo cáo sang người khác)
  auth.uid()::TEXT = emp_id

  -- Status không được thay đổi (chỉ Admin mới đổi được)
  -- NEW.status phải = OLD.status = 'pending'
  AND status = 'pending'
);

-- ---------------------------------------------------------------------------
-- POLICY: Nhân viên XÓA báo cáo của mình
-- ---------------------------------------------------------------------------
-- USING: điều kiện để hàng này có thể bị DELETE
CREATE POLICY "employee_delete_own_report"
ON reports
FOR DELETE
USING (
  -- Logic giống UPDATE: phải là của mình + pending + trong 10 phút
  auth.uid()::TEXT = emp_id
  AND status = 'pending'
  AND report_date > NOW() - INTERVAL '10 minutes'
);

-- ---------------------------------------------------------------------------
-- POLICY: Admin ĐỌC TẤT CẢ báo cáo
-- ---------------------------------------------------------------------------
CREATE POLICY "admin_read_all_reports"
ON reports
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM employees
    WHERE id = auth.uid()
    AND user_role = 'admin'
  )
);

-- ---------------------------------------------------------------------------
-- POLICY: Admin cập nhật TẤT CẢ báo cáo (nếu chưa có)
-- ---------------------------------------------------------------------------
-- Kiểm tra Admin bằng cách tra bảng employees.user_role
-- auth.uid() là UUID của người đang đăng nhập → tra bảng employees để biết role
CREATE POLICY "admin_update_any_report"
ON reports
FOR UPDATE
USING (
  -- Subquery kiểm tra user đang đăng nhập có role = 'admin' không
  EXISTS (
    SELECT 1 FROM employees
    WHERE id = auth.uid()
    AND user_role = 'admin'
  )
);

-- ---------------------------------------------------------------------------
-- POLICY: Admin xóa TẤT CẢ báo cáo (nếu chưa có)
-- ---------------------------------------------------------------------------
CREATE POLICY "admin_delete_any_report"
ON reports
FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM employees
    WHERE id = auth.uid()
    AND user_role = 'admin'
  )
);

-- ---------------------------------------------------------------------------
-- KIỂM TRA: Xem các policy đã tạo
-- ---------------------------------------------------------------------------
-- SELECT schemaname, tablename, policyname, cmd, qual
-- FROM pg_policies
-- WHERE tablename = 'reports'
-- ORDER BY policyname;
