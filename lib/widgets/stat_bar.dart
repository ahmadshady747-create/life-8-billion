import 'package:flutter/material.dart';

/// شريط إحصاءة واحدة مع لون يتغير حسب القيمة.
class StatBar extends StatelessWidget {
  final String icon;
  final String label;
  final int value;
  final VoidCallback? onTap;

  const StatBar({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  Color get _color {
    if (value >= 70) return Colors.teal;
    if (value >= 40) return Colors.amber.shade700;
    return Colors.red.shade400;
  }

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          SizedBox(
            width: 62,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                color: _color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text('$value',
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (onTap == null) return row;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: row,
    );
  }
}
