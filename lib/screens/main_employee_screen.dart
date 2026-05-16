import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/widgets/rx_icon.dart';
import 'package:resolvex_mobile_app/widgets/rx_container.dart';


class MainEmployeeScreen extends StatefulWidget {
  const MainEmployeeScreen({super.key});

  @override
  State<StatefulWidget> createState() => MainEmployeeScreenState();
}

class MainEmployeeScreenState extends State<MainEmployeeScreen> {
  int selectedIndex = 0;
  List<ReportModel> listReport = [
    ReportModel(
      reportId: "3011255",
      empId: "NV001",
      problemRoom: "C01",
      problemType: ProblemType.network,
      level: Level.low,
      status: Status.pending,
      reportDate: DateTime.now(),
    ),
    ReportModel(
      reportId: "3111255",
      empId: "NV002",
      problemRoom: "C02",
      problemType: ProblemType.hardware,
      level: Level.medium,
      status: Status.processing,
      reportDate: DateTime.now(),
    ),
    ReportModel(
      reportId: "3211255",
      empId: "NV003",
      problemRoom: "C04",
      problemType: ProblemType.furniture,
      level: Level.high,
      status: Status.resolved,
      reportDate: DateTime.now(),
    ),
    ReportModel(
      reportId: "3311255",
      empId: "NV004",
      problemRoom: "C05",
      problemType: ProblemType.software,
      level: Level.high,
      status: Status.pending,
      reportDate: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {},
          shape: CircleBorder(),
          elevation: 6,
          highlightElevation: 1,
          backgroundColor: Colors.yellow.shade600,
          child: Icon(Icons.add, size: 40, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // Thiết lập độ cao tối đa cho Header khi chưa cuộn.
            expandedHeight: 100,
            // Hiển thị lại AppBar ngay lập tức khi vừa kéo xuống.
            floating: true,
            // Cố định AppBar ở đỉnh màn hình (không cho cuộn trôi đi).
            pinned: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: Colors.yellow.shade600,
            //Tự động tạo nút Back nếu màn hình có trang trước đó.
            automaticallyImplyLeading: false,
            //Chứa nội dung (ảnh, tên...) có khả năng co giãn theo AppBar.
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(top: 35, left: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(backgroundColor: Colors.green, radius: 35),
                    SizedBox(width: 10),
                    Text(
                      "Huynh Le Trong Nhan,",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          //Chuyển đổi widget thông thường (SizedBox, Container...) thành dạng Sliver để đưa vào danh sách cuộn.
          SliverToBoxAdapter(child: SizedBox(height: 10)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: listReport.length,
              (context, index) => RXContainer(
                reportModel: listReport[index],
                onTap: () {
                  context.push('/detail_report_screen');
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        height: 60,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RXIcon(
              iconData: Icons.home,
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });
              },
              isSelected: selectedIndex == 0,
            ),
            RXIcon(
              iconData: Icons.receipt_long,
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
              },
              isSelected: selectedIndex == 1,
            ),
            Spacer(),
            RXIcon(
              iconData: Icons.history,
              onTap: () {
                setState(() {
                  selectedIndex = 2;
                });
              },
              isSelected: selectedIndex == 2,
            ),
            RXIcon(
              iconData: Icons.settings,
              onTap: () {
                setState(() {
                  selectedIndex = 3;
                });
              },
              isSelected: selectedIndex == 3,
            ),
          ],
        ),
      ),
    );
  }
}
