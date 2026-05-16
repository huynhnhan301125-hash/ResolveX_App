
import 'package:flutter/material.dart';

class RXIcon extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onTap;
  final bool isSelected;
  final BoxDecoration? boxDecoration;
  const RXIcon({
    super.key,
    required this.iconData,
    required this.onTap,
    this.isSelected = false,
    this.boxDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 6),
        decoration: boxDecoration?? BoxDecoration(
          color: isSelected ? Colors.yellow.shade600 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          iconData,
          color: Colors.black,
        ),
      ),
    );
  }
}
