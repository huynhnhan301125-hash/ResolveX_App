-- =============================================================================
-- MIGRATION: Auto Generate Employee Code (empCode)
--
-- Mục đích: Tự động sinh mã nhân viên dạng NV-{DEPT}-{NNN} khi tạo tài khoản
-- Ví dụ:
--   department = "IT"        → emp_code = "NV-IT-001"
--   department = "HR"        → emp_code = "NV-HR-001"
--   department = "Kế toán"   → emp_code = "NV-KE-002" (2 ký tự đầu)
--   department = "Marketing" → emp_code = "NV-MA-001"
--
-- Cách chạy: Dán vào Supabase Dashboard → SQL Editor → Run
-- =============================================================================

-- ---------------------------------------------------------------------------
-- BƯỚC 1: Tạo SEQUENCE để đảm bảo số thứ tự không trùng
-- ---------------------------------------------------------------------------
-- Sequence là bộ đếm do PostgreSQL quản lý, đảm bảo mỗi lần gọi nextval()
-- trả về 1 số duy nhất, ngay cả khi nhiều request đến cùng lúc (thread-safe)
CREATE SEQUENCE IF NOT EXISTS employees_emp_code_seq
  START WITH 1        -- Bắt đầu từ 1
  INCREMENT BY 1      -- Tăng 1 mỗi lần
  NO MAXVALUE         -- Không có giới hạn trên
  CACHE 1;            -- Không cache (cache=1 = mỗi lần fetch 1 giá trị mới)

-- ---------------------------------------------------------------------------
-- BƯỚC 2: Tạo Function sinh mã nhân viên
-- ---------------------------------------------------------------------------
-- Hàm này chạy TRƯỚC KHI INSERT (BEFORE INSERT trigger)
-- nhận dữ liệu từ hàng sắp được insert (NEW record)
-- và điền emp_code vào NEW.emp_code trước khi lưu vào DB
CREATE OR REPLACE FUNCTION generate_emp_code()
RETURNS TRIGGER AS $$
DECLARE
  dept_code TEXT;   -- 2 ký tự đại diện phòng ban (viết hoa)
  seq_num   INT;    -- Số thứ tự từ sequence
  new_code  TEXT;   -- Mã hoàn chỉnh sẽ được gán
BEGIN
  -- Lấy 2 ký tự đầu của department, chuyển thành chữ HOA
  -- VD: "IT" → "IT", "Kế toán" → "KE" (chỉ lấy ASCII, bỏ dấu tiếng Việt)
  -- UPPER() + LEFT() là hàm PostgreSQL built-in
  dept_code := UPPER(LEFT(NEW.department, 2));

  -- Lấy số thứ tự tiếp theo từ sequence (tự tăng, không trùng, thread-safe)
  -- nextval() LUÔN tăng kể cả khi transaction bị rollback → đảm bảo không trùng
  SELECT nextval('employees_emp_code_seq') INTO seq_num;

  -- Ghép thành format: NV-IT-001
  -- LPAD: đệm 0 vào bên trái nếu seq_num < 3 chữ số
  -- VD: 1 → "001", 12 → "012", 123 → "123", 1234 → "1234" (không cắt)
  new_code := 'NV-' || dept_code || '-' || LPAD(seq_num::TEXT, 3, '0');

  -- Gán mã mới vào hàng sắp được insert
  -- NEW là record giả đại diện cho dữ liệu TRƯỚC KHI lưu vào DB
  NEW.emp_code := new_code;

  -- RETURN NEW bắt buộc trong BEFORE trigger → PostgreSQL mới biết dùng NEW đã sửa
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------------
-- BƯỚC 3: Tạo TRIGGER gắn Function vào bảng employees
-- ---------------------------------------------------------------------------
-- Xóa trigger cũ nếu đã tồn tại (để chạy migration nhiều lần không bị lỗi)
DROP TRIGGER IF EXISTS trg_auto_emp_code ON employees;

-- Tạo trigger mới:
-- BEFORE INSERT: chạy TRƯỚC khi INSERT → có thể sửa NEW trước khi lưu
-- FOR EACH ROW:  chạy 1 lần cho mỗi hàng được insert
-- WHEN (...):    chỉ chạy khi emp_code rỗng → không ghi đè nếu Admin tự nhập
CREATE TRIGGER trg_auto_emp_code
BEFORE INSERT ON employees
FOR EACH ROW
WHEN (NEW.emp_code IS NULL OR NEW.emp_code = '')
EXECUTE FUNCTION generate_emp_code();

-- ---------------------------------------------------------------------------
-- BƯỚC 4: Kiểm tra bằng cách thử INSERT (tùy chọn, bỏ comment để test)
-- ---------------------------------------------------------------------------
-- INSERT INTO employees (id, full_name, email, department, user_role, avatar_url)
-- VALUES (gen_random_uuid(), 'Test User', 'test@example.com', 'IT', 'employee', '');
-- → emp_code sẽ tự được điền là 'NV-IT-001'

-- SELECT emp_code, full_name, department FROM employees ORDER BY created_at DESC LIMIT 5;
