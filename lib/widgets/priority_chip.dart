import 'package:flutter/material.dart';
import '../models/app_models.dart';

class PriorityChipWidget extends StatelessWidget {
  final String priorityKey;

  const PriorityChipWidget({super.key, required this.priorityKey});

  @override
  Widget build(BuildContext context) {
    final priority = PriorityLevel.fromKey(priorityKey);
    if (priority == PriorityLevel.none) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: priority.bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: priority.textColor.withOpacity(0.35),
          width: 0.8,
        ),
      ),
      child: Text(
        priority.label.toUpperCase(),
        style: TextStyle(
          color: priority.textColor,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

