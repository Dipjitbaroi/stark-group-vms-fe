import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/api_exception.dart';
import '../state/vms_state.dart';
import '../theme/app_colors.dart';
import '../widgets/labeled_dropdown.dart';
import '../widgets/labeled_form_field.dart';
import '../widgets/primary_button.dart';

/// Screen for Registering a New Vehicle or Editing an Existing Vehicle.
///
/// Features:
/// - Supports both Create (empty form) and Edit (pre-filled fields)
/// - White (#FFFFFF) form card with subtle 1px border (#E5E7EB)
/// - Consistent top-aligned labels in Charcoal (#1F2937)
/// - Subtle input borders with focus highlight in Corporate Blue (#5B9BD5)
/// - Validation error messages in Red (#D32F2F)
/// - All 6 required vehicle fields:
///   1. Vehicle Number
///   2. Company
///   3. Type
///   4. Brand
///   5. Model
///   6. Status
/// - Corporate Blue (#5B9BD5) primary Save/Update button
/// - Clean secondary Cancel button
/// - Updates local mock state smoothly without API calls
class RegisterEditVehicleScreen extends StatefulWidget {
  final Vehicle? vehicleToEdit;
  final VoidCallback onFinished;
  final VoidCallback onCancel;

  const RegisterEditVehicleScreen({
    super.key,
    this.vehicleToEdit,
    required this.onFinished,
    required this.onCancel,
  });

  bool get isEditing => vehicleToEdit != null;

  @override
  State<RegisterEditVehicleScreen> createState() =>
      _RegisterEditVehicleScreenState();
}

class _RegisterEditVehicleScreenState extends State<RegisterEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _vehicleNumberController;
  late final TextEditingController _companyController;
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;

  String? _selectedType;
  String? _selectedStatus;
  bool _isSaving = false;
  String? _serverErrorMessage;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicleToEdit;

    _vehicleNumberController = TextEditingController(text: v?.vehicleNumber ?? '');
    _companyController = TextEditingController(text: v?.company ?? 'Stark Logistics');
    _brandController = TextEditingController(text: v?.brand ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');

    _selectedType = v?.type ?? Vehicle.standardTypes.first;
    _selectedStatus = v?.status ?? 'Active';
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _companyController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() {
      _serverErrorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final vmsState = VmsScope.of(context);

    try {
      if (widget.isEditing) {
        final updated = widget.vehicleToEdit!.copyWith(
          vehicleNumber: _vehicleNumberController.text.trim().toUpperCase(),
          company: _companyController.text.trim(),
          type: _selectedType ?? Vehicle.standardTypes.first,
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          status: _selectedStatus ?? 'Active',
        );
        await vmsState.updateVehicle(updated);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.charcoal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            content: Text(
              'Vehicle ${updated.vehicleNumber} updated successfully',
              style: const TextStyle(color: AppColors.white),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        final newVehicle = Vehicle(
          id: '',
          vehicleNumber: _vehicleNumberController.text.trim().toUpperCase(),
          company: _companyController.text.trim(),
          type: _selectedType ?? Vehicle.standardTypes.first,
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          status: _selectedStatus ?? 'Active',
          createdAt: DateTime.now(),
        );
        final created = await vmsState.addVehicle(newVehicle);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.charcoal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            content: Text(
              'Vehicle ${created.vehicleNumber} registered successfully',
              style: const TextStyle(color: AppColors.white),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (mounted) {
        widget.onFinished();
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _serverErrorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _serverErrorMessage = 'Network error communicating with VMS backend.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 28,
        vertical: 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form Card Container
              Container(
                padding: EdgeInsets.all(isCompact ? 20 : 32),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Form Header
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.corporateBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              widget.isEditing
                                  ? Icons.edit_note_rounded
                                  : Icons.app_registration_rounded,
                              color: AppColors.deepBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.isEditing
                                      ? 'Edit Vehicle Details'
                                      : 'Register New Fleet Vehicle',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.deepBlue,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.isEditing
                                      ? 'Modify the vehicle record information below. All changes update local state immediately.'
                                      : 'Complete all 6 mandatory vehicle specifications to register this asset in the fleet.',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.charcoalSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 24),

                      // Inline Server Error Banner (e.g. 409 Conflict duplicate Vehicle Number or 400 Bad Request)
                      if (_serverErrorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.redBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.redBorder, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                color: AppColors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _serverErrorMessage!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Field 1 & 2: Vehicle Number & Company
                      if (isCompact) ...[
                        _buildVehicleNumberField(),
                        const SizedBox(height: 18),
                        _buildCompanyField(),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildVehicleNumberField()),
                            const SizedBox(width: 20),
                            Expanded(child: _buildCompanyField()),
                          ],
                        ),
                      ],
                      const SizedBox(height: 18),

                      // Field 3 & 4: Type & Brand
                      if (isCompact) ...[
                        _buildTypeDropdown(),
                        const SizedBox(height: 18),
                        _buildBrandField(),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildTypeDropdown()),
                            const SizedBox(width: 20),
                            Expanded(child: _buildBrandField()),
                          ],
                        ),
                      ],
                      const SizedBox(height: 18),

                      // Field 5 & 6: Model & Status
                      if (isCompact) ...[
                        _buildModelField(),
                        const SizedBox(height: 18),
                        _buildStatusDropdown(),
                      ] else ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildModelField()),
                            const SizedBox(width: 20),
                            Expanded(child: _buildStatusDropdown()),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: _isSaving ? null : widget.onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.charcoal,
                              side: const BorderSide(color: AppColors.border, width: 1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 14),
                          PrimaryButton(
                            label: widget.isEditing
                                ? 'Update Vehicle'
                                : 'Save Vehicle',
                            isLoading: _isSaving,
                            icon: widget.isEditing
                                ? Icons.check_rounded
                                : Icons.add_rounded,
                            onPressed: _handleSubmit,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Field Builders with strict Charcoal labels & Red validation ---

  Widget _buildVehicleNumberField() {
    return LabeledFormField(
      label: 'Vehicle Number',
      isRequired: true,
      controller: _vehicleNumberController,
      hintText: 'e.g. STK-8421 or ABC-1234',
      textCapitalization: TextCapitalization.characters,
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Vehicle Number is required';
        }
        if (val.trim().length < 3) {
          return 'Vehicle Number must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildCompanyField() {
    return LabeledFormField(
      label: 'Company',
      isRequired: true,
      controller: _companyController,
      hintText: 'e.g. Stark Logistics or Apex Fleet Corp',
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Company is required';
        }
        return null;
      },
    );
  }

  Widget _buildTypeDropdown() {
    return LabeledDropdown<String>(
      label: 'Vehicle Type',
      isRequired: true,
      value: _selectedType,
      items: Vehicle.standardTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedType = val),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Vehicle Type is required';
        }
        return null;
      },
    );
  }

  Widget _buildBrandField() {
    return LabeledFormField(
      label: 'Brand',
      isRequired: true,
      controller: _brandController,
      hintText: 'e.g. Toyota, Volvo, Ford, Mercedes-Benz',
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Brand is required';
        }
        return null;
      },
    );
  }

  Widget _buildModelField() {
    return LabeledFormField(
      label: 'Model',
      isRequired: true,
      controller: _modelController,
      hintText: 'e.g. F-150, Hilux, Sprinter 314',
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Model is required';
        }
        return null;
      },
    );
  }

  Widget _buildStatusDropdown() {
    return LabeledDropdown<String>(
      label: 'Status',
      isRequired: true,
      value: _selectedStatus,
      items: Vehicle.standardStatuses.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: status == 'Active'
                      ? AppColors.green
                      : AppColors.neutralStatusText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(status),
            ],
          ),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedStatus = val),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Status is required';
        }
        return null;
      },
    );
  }
}
