import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../state/vms_state.dart';
import '../theme/app_colors.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/delete_button.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/status_badge.dart';

/// Vehicle List Screen for Stark Group VMS.
///
/// Features:
/// - Top header with page title and "Register Vehicle" primary action (#5B9BD5)
/// - Metric summary indicators (Total, Active with Green dot, Inactive)
/// - Search and filter bar for fleet scannability
/// - White (#FFFFFF) table card with subtle 1px border (#E5E7EB)
/// - Displays all 6 required fields:
///   1. Vehicle Number
///   2. Company
///   3. Type
///   4. Brand
///   5. Model
///   6. Status (using reusable [StatusBadge])
/// - Clear Edit action and soft-red [DeleteButton] (#D32F2F) with confirmation dialog
/// - Responsive layout (table on wide viewports, card view on compact viewports)
/// - Polished empty state
class VehicleListScreen extends StatefulWidget {
  final VoidCallback onRegisterVehicle;
  final ValueChanged<Vehicle> onEditVehicle;

  const VehicleListScreen({
    super.key,
    required this.onRegisterVehicle,
    required this.onEditVehicle,
  });

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vmsState = VmsScope.of(context);
        if (vmsState.allVehicles.isEmpty && !vmsState.isLoadingVehicles) {
          vmsState.fetchVehicles();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, Vehicle vehicle) async {
    final messenger = ScaffoldMessenger.of(context);
    final vmsState = VmsScope.of(context);
    final confirmed = await ConfirmationDialog.show(context, vehicle);
    if (confirmed == true && mounted) {
      try {
        final removed = await vmsState.deleteVehicle(vehicle.id);
        if (removed && mounted) {
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: AppColors.charcoal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              content: Text(
                'Vehicle ${vehicle.vehicleNumber} deleted successfully',
                style: const TextStyle(color: AppColors.white),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              content: Text(
                'Failed to delete vehicle: $e',
                style: const TextStyle(color: AppColors.white),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vmsState = VmsScope.of(context);
    final vehicles = vmsState.filteredVehicles;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16 : 28,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // KPI Metric Overview Cards
          _buildKpiMetrics(vmsState, isCompact),
          const SizedBox(height: 20),

          // Search and Filters Bar
          _buildSearchAndFilterBar(vmsState, isCompact),
          const SizedBox(height: 16),

          // Vehicle Records Container (Table / Responsive Cards / Loading / Error)
          if (vmsState.isLoadingVehicles)
            _buildLoadingState()
          else if (vmsState.vehiclesError != null)
            _buildErrorState(vmsState)
          else if (vehicles.isEmpty)
            _buildEmptyState(vmsState)
          else if (isCompact)
            _buildCompactVehicleList(vehicles)
          else
            _buildDesktopTable(vehicles),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppColors.corporateBlue,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading fleet vehicles from database...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.charcoalSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(VmsState state) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.redBorder, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.redBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.red,
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to Load Fleet Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.deepBlue,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              state.vehiclesError ?? 'Failed to communicate with VMS backend server.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.charcoalSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => state.fetchVehicles(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry Connection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.corporateBlue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Metric cards communicating fleet status
  Widget _buildKpiMetrics(VmsState state, bool isCompact) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _buildMetricCard(
          label: 'Total Fleet',
          value: '${state.totalCount}',
          subtitle: 'Registered vehicles',
          indicatorColor: AppColors.deepBlue,
          width: isCompact ? double.infinity : 220,
        ),
        _buildMetricCard(
          label: 'Active Vehicles',
          value: '${state.activeCount}',
          subtitle: 'Operational in service',
          indicatorColor: AppColors.green,
          isStatusGreen: true,
          width: isCompact ? double.infinity : 220,
        ),
        _buildMetricCard(
          label: 'Inactive / Maintenance',
          value: '${state.inactiveCount}',
          subtitle: 'Idle or scheduled repair',
          indicatorColor: AppColors.neutralStatusText,
          width: isCompact ? double.infinity : 220,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String subtitle,
    required Color indicatorColor,
    bool isStatusGreen = false,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 38,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoalSecondary,
                      ),
                    ),
                    if (isStatusGreen) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.charcoalMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Search and Filter Toolbar
  Widget _buildSearchAndFilterBar(VmsState state, bool isCompact) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchInput(state),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStatusFilterDropdown(state)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCompanyFilterDropdown(state)),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildSearchInput(state),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 170,
                  child: _buildStatusFilterDropdown(state),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 200,
                  child: _buildCompanyFilterDropdown(state),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchInput(VmsState state) {
    return TextField(
      controller: _searchController,
      onChanged: (val) => state.setSearchQuery(val),
      style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
      decoration: InputDecoration(
        hintText: 'Search by Vehicle #, brand, model, company...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 20,
          color: AppColors.charcoalSecondary,
        ),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                color: AppColors.charcoalSecondary,
                onPressed: () {
                  _searchController.clear();
                  state.setSearchQuery('');
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.softGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.corporateBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStatusFilterDropdown(VmsState state) {
    return DropdownButtonFormField<String>(
      initialValue: state.statusFilter,
      items: const [
        DropdownMenuItem(value: 'All', child: Text('Status: All')),
        DropdownMenuItem(value: 'Active', child: Text('Active Only')),
        DropdownMenuItem(value: 'Inactive', child: Text('Inactive Only')),
      ],
      onChanged: (val) {
        if (val != null) state.setStatusFilter(val);
      },
      dropdownColor: AppColors.white,
      style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.softGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    );
  }

  Widget _buildCompanyFilterDropdown(VmsState state) {
    final companies = ['All', ...Vehicle.standardCompanies];

    return DropdownButtonFormField<String>(
      initialValue: state.companyFilter,
      items: companies.map((c) {
        return DropdownMenuItem(
          value: c,
          child: Text(
            c == 'All' ? 'Company: All' : c,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) state.setCompanyFilter(val);
      },
      dropdownColor: AppColors.white,
      style: const TextStyle(fontSize: 13, color: AppColors.charcoal),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.softGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
    );
  }

  /// Desktop Table with subtle borders, Charcoal text, StatusBadge, and row actions
  Widget _buildDesktopTable(List<Vehicle> vehicles) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header
          Container(
            color: const Color(0xFFF9FAFB),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'VEHICLE NUMBER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'COMPANY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'TYPE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'BRAND',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'MODEL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: Text(
                    'ACTIONS',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: vehicles.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border,
            ),
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return _TableRowItem(
                vehicle: vehicle,
                onEdit: () => widget.onEditVehicle(vehicle),
                onDelete: () => _confirmDelete(context, vehicle),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Compact card layout for tablets / smaller screens
  Widget _buildCompactVehicleList(List<Vehicle> vehicles) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Vehicle Number + Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.softGray,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Text(
                          vehicle.vehicleNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(status: vehicle.status),
                ],
              ),
              const SizedBox(height: 12),
              // Grid of specs
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildSpecItem('Company', vehicle.company),
                  _buildSpecItem('Type', vehicle.type),
                  _buildSpecItem('Brand', vehicle.brand),
                  _buildSpecItem('Model', vehicle.model),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => widget.onEditVehicle(vehicle),
                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.charcoal),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.charcoal,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DeleteButton(
                    onPressed: () => _confirmDelete(context, vehicle),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoalSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.charcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(VmsState state) {
    final bool hasFilter = state.searchQuery.isNotEmpty ||
        state.statusFilter != 'All' ||
        state.companyFilter != 'All';

    return EmptyStateCard(
      title: hasFilter ? 'No Vehicles Match Filter' : 'No Vehicles in Fleet',
      message: hasFilter
          ? 'No vehicles found matching "${state.searchQuery}". Try clearing filters or searching with different criteria.'
          : 'Your vehicle fleet list is currently empty. You can register a new vehicle or refresh from the server.',
      actionLabel: 'Register Vehicle',
      onAction: widget.onRegisterVehicle,
      secondaryAction: OutlinedButton(
        onPressed: () {
          _searchController.clear();
          state.fetchVehicles();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border, width: 1),
          foregroundColor: AppColors.charcoal,
        ),
        child: const Text('Refresh from Server'),
      ),
    );
  }
}

/// Interactive table row with hover state
class _TableRowItem extends StatefulWidget {
  final Vehicle vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TableRowItem({
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_TableRowItem> createState() => _TableRowItemState();
}

class _TableRowItemState extends State<_TableRowItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _isHovered ? const Color(0xFFF9FAFB) : AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // Vehicle Number
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.softGray,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    child: Text(
                      v.vehicleNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Company
            Expanded(
              flex: 4,
              child: Text(
                v.company,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            // Type
            Expanded(
              flex: 3,
              child: Text(
                v.type,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            // Brand
            Expanded(
              flex: 3,
              child: Text(
                v.brand,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            // Model
            Expanded(
              flex: 3,
              child: Text(
                v.model,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            // Status Badge
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusBadge(status: v.status),
              ),
            ),
            // Actions (Edit + DeleteButton)
            SizedBox(
              width: 170,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 15,
                      color: AppColors.charcoal,
                    ),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.charcoal,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      minimumSize: const Size(64, 34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DeleteButton(
                    onPressed: widget.onDelete,
                    compact: false,
                    height: 34,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
