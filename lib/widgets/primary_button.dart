import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable Stark Group VMS Primary Action Button.
///
/// Colored in Corporate Blue (`#5B9BD5`) with accessible hover/focus states,
/// leading icon support (e.g., `Register Vehicle`), and White text.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 42,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    Color backgroundColor = AppColors.corporateBlue;
    if (!isEnabled) {
      backgroundColor = AppColors.corporateBlue.withValues(alpha: 0.5);
    } else if (_isHovered) {
      backgroundColor = AppColors.corporateBlueHover;
    }

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        child: ElevatedButton(
          onPressed: isEnabled ? widget.onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.corporateBlue.withValues(alpha: 0.5),
            disabledForegroundColor: AppColors.white.withValues(alpha: 0.8),
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: widget.height < 40 ? 12 : 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 18, color: AppColors.white),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
