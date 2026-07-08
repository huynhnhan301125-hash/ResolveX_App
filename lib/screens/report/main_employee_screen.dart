import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/routers/app_router.dart';
import 'package:resolvex_mobile_app/utils/app_styles.dart';
import 'package:resolvex_mobile_app/widgets/rx_icon.dart';
import 'package:resolvex_mobile_app/screens/report/tabs/home_tab.dart';
import 'package:resolvex_mobile_app/screens/report/tabs/report_list_tab.dart';
import 'package:resolvex_mobile_app/screens/report/tabs/report_history_tab.dart';
import 'package:resolvex_mobile_app/screens/report/tabs/settings_tab.dart';

/// [MainEmployeeScreen] là màn hình chính của nhân viên sau khi đăng nhập.
/// Đây là màn hình "Shell" (Khung xương) — chứa Bottom Navigation Bar
/// và quản lý trạng thái danh sách báo cáo (`listReport`) như nguồn dữ liệu gốc.
class MainEmployeeScreen extends StatefulWidget {
  const MainEmployeeScreen({super.key});

  @override
  State<StatefulWidget> createState() => MainEmployeeScreenState();
}

class MainEmployeeScreenState extends State<MainEmployeeScreen> {
  // selectedIndex: theo dõi Tab nào đang hiển thị
  // (0 = Trang chủ, 1 = Danh sách, 2 = Lịch sử, 3 = Cài đặt)
  int selectedIndex = 0;

  // listReport: là "Single Source of Truth" — nguồn dữ liệu duy nhất cho toàn bộ app.
  // Sau khi kết nối Database, đây sẽ là nơi lưu dữ liệu từ Supabase về.
  // Được truyền xuống các Tab con qua constructor (Prop Drilling pattern).
  List<ReportModel> listReport = [];

  @override
  Widget build(BuildContext context) {
    // Danh sách Tab theo thứ tự hiển thị trong BottomNavigationBar
    final List<Widget> pages = [
      HomeTab(listReport: listReport),
      ReportListTab(listReport: listReport),
      ReportHistoryTab(listReport: listReport),
      const SettingsTab(),
    ];

    return Scaffold(
      floatingActionButton: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: AppStyles.shadowElevated,
        ),
        child: FloatingActionButton(
          onPressed: () async {
            // pushNamed trả về ReportModel khi CreateReportScreen gọi context.pop(newReport)
            // async/await để chờ màn hình tạo báo cáo đóng lại mới chạy tiếp
            final newReport = await context.pushNamed<ReportModel>(
              RouteNames.createReport,
            );
            // mounted check: đảm bảo widget còn trên màn hình trước khi gọi setState
            if (newReport != null && mounted) {
              // insert(0,...) thêm vào đầu danh sách để báo cáo mới luôn xuất hiện trên cùng
              setState(() => listReport.insert(0, newReport));
            }
          },
          shape: const CircleBorder(),
          elevation: 6,
          highlightElevation: 1,
          backgroundColor: AppColors.brandPrimary,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // IndexedStack: hiển thị đúng 1 Tab tại một thời điểm nhưng GIỮ NGUYÊN
      // trạng thái các Tab còn lại (scroll position, filter đã chọn...)
      // Khác với if/else thông thường sẽ destroy và rebuild Tab mỗi lần chuyển.
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        height: 70,
        color: AppColors.surfaceWhite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RXIcon(iconData: Icons.home, onTap: () => setState(() => selectedIndex = 0), isSelected: selectedIndex == 0, size: 26),
            RXIcon(iconData: Icons.receipt_long, onTap: () => setState(() => selectedIndex = 1), isSelected: selectedIndex == 1, size: 26),
            const Spacer(),
            RXIcon(iconData: Icons.history, onTap: () => setState(() => selectedIndex = 2), isSelected: selectedIndex == 2, size: 26),
            RXIcon(iconData: Icons.settings, onTap: () => setState(() => selectedIndex = 3), isSelected: selectedIndex == 3, size: 26),
          ],
        ),
      ),
    );
  }
}
