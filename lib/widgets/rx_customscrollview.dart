import 'package:flutter/material.dart';

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
          title: title,// Tiêu đề của màn hình
          expandedHeight: expandedHeight,// Độ cao tối đa của phần đầu trang (AppBar) khi chưa cuộn
          flexibleSpace: flexibleSpace,// Đây là nội dung nằm "bên dưới" tiêu đề
          automaticallyImplyLeading: showBackButton,//Quyết định xem có hiện nút mũi tên "Quay lại" hay không
          pinned: true, // Giữ thanh tiêu đề ở đỉnh
          floating: true, // Hiện lại thanh tiêu đề nhanh khi kéo xuống
          snap: true, // Đi kèm với floating để hiện mượt hơn
          backgroundColor: Colors.yellow.shade600,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30)
            )
          ),
          toolbarHeight: 20,// // Thiết lập chiều cao khi đã thu nhỏ

        ),
        ...sliver,// Dấu ba chấm (...) gọi là Spread Operator
        /* Lấy phần tử trong danh sách sliver truyền vào và
        "trải" chúng ra ngay sau SliverAppBar */
      ],
    );
  }
}
