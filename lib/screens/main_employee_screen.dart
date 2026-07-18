import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/providers/report_provider.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/core/theme/theme.dart';
import 'package:resolvex_mobile_app/widgets/rx_icon.dart';
import 'package:resolvex_mobile_app/screens/report/tabs/home_tab.dart';
import 'package:resolvex_mobile_app/screens/report/tabs/report_list_tab.dart';
import 'package:resolvex_mobile_app/screens/report/tabs/report_history_tab.dart';
import 'package:resolvex_mobile_app/screens/report/tabs/settings_tab.dart';

// =============================================================================
// MAIN EMPLOYEE SCREEN — Màn hình Shell chính sau khi đăng nhập
//
// Vai trò sau khi refactor:
//   - KHÔNG còn giữ listReport hay bất kỳ state dữ liệu nào.
//   - Chỉ quản lý selectedIndex (tab đang hiển thị).
//   - Dữ liệu báo cáo đã được chuyển sang ReportProvider.
//   - Các Tab tự đọc dữ liệu từ ReportProvider — không cần truyền props nữa.
//
// Sửa lỗi kiến trúc:
//   [FIX 1] Prop Drilling: Không còn truyền listReport/onRefresh/... qua constructor.
//   [FIX 2] IndexedStack vô hiệu: _pages được khởi tạo 1 lần trong initState(),
//           không tạo lại trong build() → IndexedStack giữ đúng State các Tab.
// =============================================================================

/// Màn hình chính của nhân viên sau khi đăng nhập.
/// Chỉ quản lý Bottom Navigation Bar và chuyển tab.
/// Dữ liệu báo cáo được quản lý hoàn toàn bởi ReportProvider.
class MainEmployeeScreen extends StatefulWidget {
  const MainEmployeeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainEmployeeScreenState();
}

class _MainEmployeeScreenState extends State<MainEmployeeScreen> {
  int _selectedIndex = 0;

  // ---------------------------------------------------------------------------
  // [FIX 2] _pages được khai báo ở đây — BÊN NGOÀI build().
  //
  // Vấn đề cũ: pages = [...] nằm bên trong build(), nên mỗi lần setState()
  // được gọi (kể cả chỉ đổi tab), Flutter tạo ra 4 widget object MỚI HOÀN TOÀN.
  // IndexedStack nhận widget mới → phá hủy State cũ → scroll position bị reset.
  //
  // Giải pháp: late final đảm bảo danh sách này được tạo đúng 1 lần duy nhất
  // trong initState(). IndexedStack luôn nhận cùng 1 object instance → State
  // của các Tab (scroll position, bộ lọc,...) được giữ nguyên khi chuyển tab.
  // ---------------------------------------------------------------------------
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Khởi tạo danh sách Tab một lần duy nhất
    _pages = const [
      HomeTab(),
      ReportListTab(),
      ReportHistoryTab(),
      SettingsTab(),
    ];

    // Trigger tải dữ liệu lần đầu thông qua ReportProvider.
    // Dùng addPostFrameCallback để đảm bảo context đã sẵn sàng trước khi
    // gọi Provider — tránh lỗi "context not ready" trong initState.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });

    /*  WidgetsBinding.instance.addPostFrameCallback((_)... gọi provider lấy dữ liệu
    nhưng vì trg initstate trạng thái màn hình  chưa đươc gắn vào widget tree ( chưa có
    context). Lệnh này yêu cầu sau khi xây dựng sau khung thì tải dữ liêu (hàm được gọi trong lệnh).
     */

  }

  /// Gọi ReportProvider để tải dữ liệu lần đầu.
  /// Bắt lỗi ở đây và hiện SnackBar thay vì để Provider xử lý UI.
  Future<void> _loadInitialData() async {
    try {
      // context.read: chỉ đọc 1 lần, không đăng ký rebuild — phù hợp trong
      // hàm logic (initState, callback) chứ không phải trong build()
      await context.read<ReportProvider>().loadReports(reset: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không tải được báo cáo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // context.watch<ReportProvider>(): lắng nghe isLoading để quyết định
    // hiện spinner hay nội dung. Chỉ đọc 1 field duy nhất ở đây.
    final isLoading = context.watch<ReportProvider>().isLoading;

    // Khi đang tải dữ liệu từ Supabase, hiện vòng xoay loading ở giữa màn hình
    // thay vì hiện danh sách rỗng gây hiểu lầm "không có báo cáo nào".
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: AppStyles.shadowElevated,
        ),
        child: FloatingActionButton(
          onPressed: () async {
            // pushNamed trả về ReportModel khi CreateReportScreen gọi context.pop(newReport)
            // async/await để chờ màn hình tạo báo cáo đóng lại mới chạy tiếp.
            //
            // Lưu provider vào biến LOCAL trước khi await — tránh lỗi
            // use_build_context_synchronously (context có thể không còn hiệu lực
            // sau khi await hoàn tất nếu widget bị unmount trong thời gian đó).
            final provider = context.read<ReportProvider>();
            final newReport = await context.pushNamed<ReportModel>(
              RouteNames.createReport,
            );
            // mounted check: đảm bảo widget còn trên màn hình trước khi gọi Provider
            if (newReport != null && mounted) {
              // Gọi provider qua biến local đã lưu — không cần gọi context nữa
              provider.addReportToTop(newReport);
            }
          },
          shape: const CircleBorder(),
          elevation: 6,
          highlightElevation: 1,
          backgroundColor: AppColors.brandPrimary,
          child: const Icon(Icons.add, size: 32, color: Colors.black),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // IndexedStack: hiển thị đúng 1 Tab tại một thời điểm nhưng GIỮ NGUYÊN
      // trạng thái các Tab còn lại (scroll position, filter đã chọn...).
      //
      // [FIX 2] Hoạt động đúng vì _pages được tạo 1 lần trong initState().
      // IndexedStack nhận cùng 1 object instance qua mọi lần build()
      // → State của các Tab không bao giờ bị destroy khi chuyển tab.
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        height: 70,
        // Sử dụng màu nền của theme (đổi theo dark/light mode) thay vì fix cứng màu
        color: Theme.of(context).bottomAppBarTheme.color ?? AppColors.surfaceWhite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RXIcon(iconData: Icons.home, onTap: () => setState(() => _selectedIndex = 0), isSelected: _selectedIndex == 0, size: 26),
            RXIcon(iconData: Icons.receipt_long, onTap: () => setState(() => _selectedIndex = 1), isSelected: _selectedIndex == 1, size: 26),
            const Spacer(),
            RXIcon(iconData: Icons.history, onTap: () => setState(() => _selectedIndex = 2), isSelected: _selectedIndex == 2, size: 26),
            RXIcon(iconData: Icons.settings, onTap: () => setState(() => _selectedIndex = 3), isSelected: _selectedIndex == 3, size: 26),
          ],
        ),
      ),
    );
  }
}
