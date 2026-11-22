import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable Stark Group VMS Delete Action Button.
///
/// Strictly uses Red (`#D32F2F`) for Delete actions ONLY:
/// Soft red-tinted container background with `#D32F2F` trash icon and label.
class DeleteButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool compact;
  final double height;

  const DeleteButton({
    super.key,
    required this.onPressed,
    this.label = 'Delete',
    this.compact = false,
    this.height = 34,
  });

  @override
  State<DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;

    final Color bgColor = _isHovered
        ? const Color(0xFFFBD5D5)
        : AppColors.redBackground;

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: widget.height,
        child: OutlinedButton(
          onPressed: isEnabled ? widget.onPressed : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: AppColors.red,
            side: const BorderSide(color: AppColors.redBorder, width: 1),
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: widget.compact ? 10 : 14,
              vertical: 0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                size: 16,
                color: AppColors.red,
              ),
              if (!widget.compact) ...[
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
