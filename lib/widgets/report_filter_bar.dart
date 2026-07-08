import 'package:flutter/material.dart';
import 'package:resolvex_mobile_app/models/report_model.dart';

/// [ReportFilterBar] là thanh bộ lọc dạng Dropdown (Danh sách thả xuống).
/// Widget này giúp người dùng kết hợp nhiều điều kiện lọc (Sắp xếp, Loại sự cố, Mức độ ưu tiên)
/// mà không làm rối giao diện (tiết kiệm không gian hơn so với dạng Chip chọn).
class ReportFilterBar extends StatelessWidget {
  final ProblemType? selectedType;
  final Level? selectedLevel;
  final bool isNewestFirst;
  final ValueChanged<ProblemType?> onTypeChanged;
  final ValueChanged<Level?> onLevelChanged;
  final ValueChanged<bool> onSortChanged;

  const ReportFilterBar({
    super.key,
    required this.selectedType,
    required this.selectedLevel,
    required this.isNewestFirst,
    required this.onTypeChanged,
    required this.onLevelChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          // 1. Dropdown Sắp xếp thời gian
          Expanded(
            child: _buildDropdownContainer(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<bool>(
                  value: isNewestFirst,
                  isExpanded: true,
                  isDense: true, // Làm gọn kích thước dropdown
                  padding: EdgeInsets.zero, // Xóa padding mặc định của Dropdown để tiết kiệm không gian
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 18),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  onChanged: (value) {
                    if (value != null) onSortChanged(value);
                  },
                  items: const [
                    DropdownMenuItem(
                      value: true,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, size: 12, color: Colors.amber),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Mới nhất",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: false,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Cũ nhất",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // 2. Dropdown Lọc Loại Sự Cố
          Expanded(
            child: _buildDropdownContainer(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ProblemType?>(
                  value: selectedType,
                  isExpanded: true,
                  isDense: true, // Làm gọn kích thước dropdown
                  padding: EdgeInsets.zero, // Xóa padding mặc định
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 18),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  onChanged: onTypeChanged,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          Icon(Icons.category_outlined, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Tất cả loại",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...ProblemType.values.map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(type.icon, size: 12, color: type.color),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                type.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // 3. Dropdown Lọc Mức Độ Ưu Tiên
          Expanded(
            child: _buildDropdownContainer(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Level?>(
                  value: selectedLevel,
                  isExpanded: true,
                  isDense: true, // Làm gọn kích thước dropdown
                  padding: EdgeInsets.zero, // Xóa padding mặc định
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 18),
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  onChanged: onLevelChanged,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          Icon(Icons.priority_high, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Tất cả mức",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...Level.values.map(
                      (lvl) => DropdownMenuItem(
                        value: lvl,
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: lvl.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                lvl.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hàm bổ trợ (Helper method) để trang trí cho khung Dropdown.
  /// Giúp đồng bộ giao diện bo góc nhẹ, viền xám nhạt và đổ bóng cực nhẹ.
  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4), // Giảm padding viền để chừa chỗ cho chữ dài
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 1.0),
      ),
      child: Center(child: child),
    );
  }
}
