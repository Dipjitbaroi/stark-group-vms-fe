import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../theme/app_colors.dart';
import 'delete_button.dart';

/// Confirmation dialog for safely deleting a vehicle from local mock state.
class ConfirmationDialog extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.vehicle,
    required this.onConfirm,
  });

  static Future<bool?> show(BuildContext context, Vehicle vehicle) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ConfirmationDialog(
        vehicle: vehicle,
        onConfirm: () => Navigator.of(ctx).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.redBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.redBorder, width: 1),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Delete Vehicle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Body
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.charcoal,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Are you sure you want to delete vehicle ',
                    ),
                    TextSpan(
                      text: vehicle.vehicleNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' (${vehicle.brand} ${vehicle.model} - ${vehicle.company})? This action will immediately remove the record from mock state.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.charcoal,
                      side: const BorderSide(color: AppColors.border, width: 1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  DeleteButton(
                    label: 'Delete Vehicle',
                    height: 40,
                    onPressed: onConfirm,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
