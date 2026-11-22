import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'primary_button.dart';

/// Reusable Stark Group VMS Empty State Card.
///
/// Displayed when no vehicle records match current filters or when all
/// mock records are deleted. Offers a clear title, description, and action button.
class EmptyStateCard extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;
  final Widget? secondaryAction;

  const EmptyStateCard({
    super.key,
    this.title = 'No Vehicles Found',
    this.message =
        'There are currently no vehicle records to display. Try adjusting your search query, status filters, or register a new fleet vehicle.',
    this.actionLabel = 'Register Vehicle',
    this.onAction,
    this.icon = Icons.directions_car_outlined,
    this.secondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.softGray,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: AppColors.charcoalMuted,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.charcoalSecondary,
                  height: 1.5,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                PrimaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  icon: Icons.add_rounded,
                ),
              ],
              if (secondaryAction != null) ...[
                const SizedBox(height: 12),
                secondaryAction!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
