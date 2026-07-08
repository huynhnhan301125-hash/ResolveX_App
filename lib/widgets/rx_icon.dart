import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/utils/app_styles.dart';

/// [RXIcon] là widget icon dùng cho Bottom Navigation Bar.
/// Hỗ trợ hiệu ứng chuyển màu mượt mà (AnimatedContainer) khi tab được chọn.
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
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material( // Cần Material để hiển thị hiệu ứng gợn sóng (InkWell ripple)
      child: InkWell(
        onTap: onTap,
        borderRadius: AppStyles.brXXL, // Bo tròn hiệu ứng chạm
        child: AnimatedContainer( // Chuyển màu mượt mà khi đổi tab
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: AppStyles.spaceXL, vertical: AppStyles.spaceXS + 2),
          decoration: boxDecoration ?? BoxDecoration(
            // Dùng AppColors.brandPrimary thay vì Colors.yellow.shade600
            color: isSelected ? AppColors.brandPrimary : Colors.transparent,
            borderRadius: AppStyles.brXXL,
          ),
          child: Icon(
            iconData,
            color: isSelected ? Colors.black : Colors.black54,
            size: size,
          ),
        ),
      ),
    );
  }
}
