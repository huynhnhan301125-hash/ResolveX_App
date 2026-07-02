class AppValidate {
  // Dòng này là Private Constructor: Ngăn không cho ai dùng từ khóa 'new' (hoặc gọi trực tiếp) để tạo instance của class này.
  AppValidate._();

  static String? checkEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName không được bỏ trống.";
    }
    return null;
  }

  static String? checkEmail(String? value, String fieldName) {
    String? errorText = checkEmpty(value, fieldName);
    if (errorText != null) {
      return errorText;
    }

    // ^ và $ : Bắt đầu và kết thúc chuỗi (chặn khoảng trắng/ký tự lạ ở 2 đầu).
    // [\w-\.]+ : Tên tài khoản (cho phép chữ, số, dấu gạch ngang, dấu chấm).
    // @ : Bắt buộc phải có chữ A còng.
    // ([\w-]+\.)+ : Tên miền (như gmail., resolvex., bắt buộc kết thúc bằng dấu chấm).
    // [a-zA-Z]{2,} : Đuôi mở rộng (chỉ nhận chữ cái, dài từ 2 ký tự trở lên như com, vn, online).
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[a-zA-Z]{2,}$').hasMatch(value!)) {
      return "$fieldName sai định dạng.";
    }
    return null;
  }

  static String? checkPassword(String? value, String fieldName) {
    String? errorText = checkEmpty(value, fieldName);
    if (errorText != null) {
      return errorText;
    }

    //   (?=.*[A-Z]) : Trạm 1: Phải có ít nhất 1 chữ IN HOA.
    // (?=.*[a-z]) : Trạm 2: Phải có ít nhất 1 chữ thường.
    // (?=.*\d) : Trạm 3: Phải có ít nhất 1 con số (0-9).
    // (?=.*[!@#\$&*~]) : Trạm 4: Phải có ít nhất 1 ký tự đặc biệt trong nhóm được chỉ định.
    // [A-Za-z\d!@#\$&*~]{8,} : Gom tất cả ký tự hợp lệ ở trên lại và ép tổng độ dài phải từ 8 ký tự trở lên.
    if (!RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~])[A-Za-z\d!@#\$&*~]{8,}$',
    ).hasMatch(value!)) {
      return "$fieldName cần nhâp tối thiểu 8 ký tự bao gồm Chữ in hoa, chữ thường, số và ký tự đặc biệt.";
    }
    return null;
  }

  static String? checkConfirmPassword(
    String? original,
    String? confirm,
    String fieldName,
  ) {
    String? errorText = checkEmpty(confirm, fieldName);
    if (errorText != null) {
      return errorText;
    }
    if (original != confirm) {
      return "$fieldName không chính xác.";
    }
    return null;
  }
}
