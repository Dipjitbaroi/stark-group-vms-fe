import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable Stark Group VMS Status Badge.
///
/// Strictly adheres to color tokens:
/// - Green (`#2E7D32`): Active / Success status badges ONLY with soft green pill background.
/// - Neutral Gray (`#6B7280`): Inactive status badges with neutral gray pill background.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  bool get _isActive => status.trim().toLowerCase() == 'active';

  @override
  Widget build(BuildContext context) {
    final bool active = _isActive;

    final Color backgroundColor =
        active ? AppColors.greenBackground : AppColors.neutralStatusBackground;
    final Color textColor =
        active ? AppColors.green : AppColors.neutralStatusText;
    final Color dotColor =
        active ? AppColors.green : AppColors.neutralStatusText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active
              ? const Color(0xFFC8E6C9)
              : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
