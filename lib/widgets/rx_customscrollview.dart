import 'package:flutter/material.dart';

class RXCustomScrollView extends StatelessWidget {
  const RXCustomScrollView({
    super.key,
    required this.title,
    required this.expandedHeight,
    this.flexibleSpace,
    this.showBackButton = true,
    required this.sliver,
  });

  final Widget title;
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
        ),
        ...sliver,
      ],
    );
  }
}
