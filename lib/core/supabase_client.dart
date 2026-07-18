import 'package:supabase_flutter/supabase_flutter.dart';

// =============================================================================
// SUPABASE CLIENT — Điểm kết nối duy nhất đến Supabase trong toàn bộ app
//
// Tại sao nằm ở core/ thay vì services/?
//   File này là "connection setup" — hạ tầng kỹ thuật thuần túy, không chứa
//   bất kỳ business logic nào. Nó là thứ mà các Service *dùng để* hoạt động,
//   chứ bản thân nó không phải một Service.
//
//   Tương tự: file cấu hình database connection không nằm trong tầng Repository.
//
// Cách dùng:
//   import 'package:resolvex_mobile_app/core/supabase_client.dart';
//   supabase.from('reports').select();
// =============================================================================

/// Getter toàn cục để truy cập Supabase client từ bất kỳ đâu.
/// Chỉ cần import file này và gọi `supabase.from(...)` — không cần khởi tạo lại.
final supabase = Supabase.instance.client;
