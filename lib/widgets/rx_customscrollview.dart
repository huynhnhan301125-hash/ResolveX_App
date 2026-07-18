import 'package:flutter/material.dart';

/// [RXCustomScrollView] là widget bọc CustomScrollView với SliverAppBar chuẩn.
/// Tất cả các Tab màn hình chính và CreateReportScreen đều dùng widget này
/// để đảm bảo đồng bộ giao diện (hiệu ứng AppBar thu/mở khi cuộn).
class RXCustomScrollView extends StatelessWidget {
  const RXCustomScrollView({
    super.key,
    this.title,
    required this.expandedHeight,
    this.flexibleSpace,
    this.showBackButton = true,
    required this.sliver,
  });

  final Widget? title;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final bool showBackButton;
  final List<Widget> sliver;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: title,
          expandedHeight: expandedHeight,
          flexibleSpace: flexibleSpace,
          automaticallyImplyLeading: showBackButton,
          pinned: true,   // Giữ thanh tiêu đề ở đỉnh khi cuộn
          floating: true, // Hiện lại nhanh khi kéo xuống
          snap: true,     // Đi kèm floating để hiện mượt hơn
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
        // Spread operator: "trải" các phần tử từ list sliver vào ngay sau SliverAppBar
        ...sliver,
      ],
    );
  }
}
