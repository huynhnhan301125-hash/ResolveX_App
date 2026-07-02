
import 'package:flutter/material.dart';

class RXIcon extends StatelessWidget {
  final IconData iconData;
  final VoidCallback onTap;
  final bool isSelected;
  final BoxDecoration? boxDecoration;
  final double size;
  const RXIcon({
    super.key,
    required this.iconData,
    required this.onTap,
    this.isSelected = false,
    this.boxDecoration,
    required this.size
  });

  @override
  Widget build(BuildContext context) {
    return Material( // Cần Material để hiện hiệu ứng gợn sóng (InkWell)
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),// Bo tròn hiệu ứng chạm
        child: AnimatedContainer(// Giúp chuyển màu mượt mà
          duration: const Duration(milliseconds: 300),// Thời gian đổi màu 0.3s
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 6),
          decoration: boxDecoration??BoxDecoration(
            color: isSelected?Colors.yellow.shade600:Colors.transparent,
            borderRadius: BorderRadius.circular(20)
          ),
          child: Icon(
            iconData,
            color: isSelected?Colors.black:Colors.black54,
            size: size,
          ),
        ),
      ),
    );
  }
}
