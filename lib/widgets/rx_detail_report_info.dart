import 'package:flutter/material.dart';

class RXDetailReportInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const RXDetailReportInfo({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.color ,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700),
          SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
