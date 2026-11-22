import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/vehicle.dart';
import 'screens/login_screen.dart';
import 'screens/register_edit_vehicle_screen.dart';
import 'screens/vehicle_list_screen.dart';
import 'state/vms_state.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';
import 'widgets/primary_button.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env", isOptional: true);
  } catch (e) {
    debugPrint('Note: .env could not be loaded; falling back to environment: $e');
  }
  runApp(const VmsApp());
}

/// Root Application Widget for Stark Group VMS.
class VmsApp extends StatefulWidget {
  final bool startAuthenticated;

  const VmsApp({
    super.key,
    this.startAuthenticated = false,
  });

  @override
  State<VmsApp> createState() => _VmsAppState();
}

class _VmsAppState extends State<VmsApp> {
  late final VmsState _vmsState;

  @override
  void initState() {
    super.initState();
    _vmsState = VmsState(initialAuthenticated: widget.startAuthenticated);
  }

  @override
  void dispose() {
    _vmsState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VmsScope(
      state: _vmsState,
      child: MaterialApp(
        title: 'VMS — Vehicle Management System | Stark Group',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const VmsRootRouter(),
      ),
    );
  }
}

/// Internal screen view states for the authenticated shell.
enum _ActiveView {
  vehicleList,
  registerVehicle,
  editVehicle,
}

/// Root view switcher that toggles between [LoginScreen] and [AppShell].
class VmsRootRouter extends StatefulWidget {
  const VmsRootRouter({super.key});

  @override
  State<VmsRootRouter> createState() => _VmsRootRouterState();
}

class _VmsRootRouterState extends State<VmsRootRouter> {
  _ActiveView _currentView = _ActiveView.vehicleList;
  Vehicle? _selectedVehicleForEdit;

  void _navigateToRegister() {
    setState(() {
      _selectedVehicleForEdit = null;
      _currentView = _ActiveView.registerVehicle;
    });
  }

  void _navigateToEdit(Vehicle vehicle) {
    setState(() {
      _selectedVehicleForEdit = vehicle;
      _currentView = _ActiveView.editVehicle;
    });
  }

  void _navigateToList() {
    setState(() {
      _selectedVehicleForEdit = null;
      _currentView = _ActiveView.vehicleList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vmsState = VmsScope.of(context);

    // If session is still being restored from local storage, display seamless loading indicator
    if (!vmsState.isSessionRestored) {
      return const Scaffold(
        backgroundColor: AppColors.softGray,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.corporateBlue,
            strokeWidth: 3,
          ),
        ),
      );
    }

    // If not authenticated, present the centralized Login Screen
    if (!vmsState.isAuthenticated) {
      return LoginScreen(
        onLoginSuccess: () {
          setState(() {
            _currentView = _ActiveView.vehicleList;
            _selectedVehicleForEdit = null;
          });
        },
      );
    }

    // Determine current AppShell navigation tab
    final AppShellNav activeNav = (_currentView == _ActiveView.registerVehicle)
        ? AppShellNav.register
        : AppShellNav.vehicles;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;

    // Build the corresponding view and header configuration
    switch (_currentView) {
      case _ActiveView.registerVehicle:
        return AppShell(
          currentNav: activeNav,
          title: 'Register Vehicle',
          subtitle: 'Add a new transport asset to the Stark Group fleet',
          primaryAction: OutlinedButton.icon(
            onPressed: _navigateToList,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: Text(isMobile ? 'Back' : 'Back to Fleet'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border, width: 1),
              foregroundColor: AppColors.charcoal,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          onNavSelected: (nav) {
            if (nav == AppShellNav.vehicles) {
              _navigateToList();
            }
          },
          child: RegisterEditVehicleScreen(
            vehicleToEdit: null,
            onFinished: _navigateToList,
            onCancel: _navigateToList,
          ),
        );

      case _ActiveView.editVehicle:
        final vehicle = _selectedVehicleForEdit;
        final vehicleNumber = vehicle?.vehicleNumber ?? '';

        return AppShell(
          currentNav: activeNav,
          title: isMobile ? 'Edit: $vehicleNumber' : 'Edit Vehicle: $vehicleNumber',
          subtitle: 'Modify specifications and fleet assignment for $vehicleNumber',
          primaryAction: OutlinedButton.icon(
            onPressed: _navigateToList,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: Text(isMobile ? 'Back' : 'Back to Fleet'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border, width: 1),
              foregroundColor: AppColors.charcoal,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          onNavSelected: (nav) {
            if (nav == AppShellNav.vehicles) {
              _navigateToList();
            } else if (nav == AppShellNav.register) {
              _navigateToRegister();
            }
          },
          child: RegisterEditVehicleScreen(
            vehicleToEdit: vehicle,
            onFinished: _navigateToList,
            onCancel: _navigateToList,
          ),
        );

      case _ActiveView.vehicleList:
        return AppShell(
          currentNav: activeNav,
          title: 'Vehicles',
          subtitle: 'Overview and real-time registry of corporate fleet assets',
          primaryAction: PrimaryButton(
            label: isMobile ? 'Register' : 'Register Vehicle',
            icon: Icons.add_rounded,
            height: isMobile ? 36 : 42,
            onPressed: _navigateToRegister,
          ),
          onNavSelected: (nav) {
            if (nav == AppShellNav.register) {
              _navigateToRegister();
            } else if (nav == AppShellNav.vehicles) {
              _navigateToList();
            }
          },
          child: VehicleListScreen(
            onRegisterVehicle: _navigateToRegister,
            onEditVehicle: _navigateToEdit,
          ),
        );
    }
  }
}
