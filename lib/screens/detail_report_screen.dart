import 'package:flutter/material.dart';

class DetailReportScreen extends StatefulWidget {
  const DetailReportScreen({super.key});

  @override
  State<StatefulWidget> createState() => DetailReportScreenState();
}

class DetailReportScreenState extends State<DetailReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 50,
            floating: true,
            pinned: false,
            backgroundColor:  Colors.yellow.shade600,
            flexibleSpace: FlexibleSpaceBar(
                background: Padding(padding: EdgeInsets.only(top: 15, left: 10, bottom: 10),

                ),
            ),
          )
        ],
      ),
    );
  }
}
