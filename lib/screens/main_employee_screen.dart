import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';
import 'package:resolvex_mobile_app/widgets/rx_customscrollview.dart';
import 'package:resolvex_mobile_app/widgets/rx_icon.dart';
import 'package:resolvex_mobile_app/widgets/rx_container.dart';

class MainEmployeeScreen extends StatefulWidget {
  const MainEmployeeScreen({super.key});

  @override
  State<StatefulWidget> createState() => MainEmployeeScreenState();
}

class MainEmployeeScreenState extends State<MainEmployeeScreen> {
  int selectedIndex = 0; //: Dùng để theo dõi xem người dùng đang đứng ở Tab nào
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeSliverContent(listReport: listReport), // Danh sách báo cáo
      //const Center(child: Text("Danh sách")),
      //const Center(child: Text("Lịch sử")),
      //const Center(child: Text("Cài đặt")),
    ];
  }

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
    ReportModel(
      reportId: "3711255",
      empId: "NV005",
      problemRoom: "C05",
      problemType: ProblemType.software,
      level: Level.high,
      status: Status.pending,
      reportDate: DateTime.now(),
    ),
    ReportModel(
      reportId: "6311255",
      empId: "NV006",
      problemRoom: "C05",
      problemType: ProblemType.software,
      level: Level.high,
      status: Status.pending,
      reportDate: DateTime.now(),
    ),
    ReportModel(
      reportId: "2311255",
      empId: "NV007",
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
              color: Colors.black.withOpacity(0.1),
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
      body: _pages[selectedIndex],
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
              size: 26,
            ),
            RXIcon(
              iconData: Icons.receipt_long,
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
              },
              isSelected: selectedIndex == 1,
              size: 26,
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
              size: 26,
            ),
            RXIcon(
              iconData: Icons.settings,
              onTap: () {
                setState(() {
                  selectedIndex = 3;
                });
              },
              isSelected: selectedIndex == 3,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSliverContent extends StatelessWidget {
  const HomeSliverContent({super.key, required this.listReport});

  final List<ReportModel> listReport;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RXCustomScrollView(
      expandedHeight: 80,
      showBackButton: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(top: 40, left: 20),
          child: Row(
            children: [
              const CircleAvatar(backgroundColor: Colors.green, radius: 30),
              const SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Xin chao,", style: TextStyle(fontSize: 16)),
                  Text(
                    "Trong Nhan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      sliver: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 10),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => RXContainer(
                reportModel: listReport[index],
                onTap: () => context.pushNamed(
                  "detail-report",
                  extra: listReport[index],
                ),
              ),
              childCount: listReport.length
            ),
          ),
        ),
      ],
    );
  }
}
