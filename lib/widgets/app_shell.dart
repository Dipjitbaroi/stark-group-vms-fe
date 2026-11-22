import 'package:flutter/material.dart';
import '../state/vms_state.dart';
import '../theme/app_colors.dart';

/// Navigation items supported by the AppShell.
enum AppShellNav {
  vehicles,
  register,
}

/// The core layout shell for Stark Group VMS.
///
/// Features:
/// - Persistent left-side navigation bar in Deep Blue (`#1F4E79`) with VMS branding
/// - Clean Soft Gray (`#F5F7FA`) workspace on the right
/// - Automatic drawer collapse on tablet/mobile (< 900px)
/// - Standardized top page header with top-left title and top-right primary action
/// - Clean responsive layout with zero overflows
class AppShell extends StatelessWidget {
  final AppShellNav currentNav;
  final String title;
  final String? subtitle;
  final Widget? primaryAction;
  final Widget child;
  final ValueChanged<AppShellNav>? onNavSelected;

  const AppShell({
    super.key,
    required this.currentNav,
    required this.title,
    this.subtitle,
    this.primaryAction,
    required this.child,
    this.onNavSelected,
  });

  static const double _breakpointTablet = 900;
  static const double _sidebarWidth = 260;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < _breakpointTablet;

    return Scaffold(
      backgroundColor: AppColors.softGray,
      // On compact viewports, provide a drawer with identical Deep Blue branding
      drawer: isCompact ? _buildDrawer(context) : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Persistent Sidebar on Desktop
          if (!isCompact)
            SizedBox(
              width: _sidebarWidth,
              child: _buildSidebarContent(context, isDrawer: false),
            ),
          // Main Workspace
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStandardHeader(context, showMenuButton: isCompact),
                Expanded(
                  child: Container(
                    color: AppColors.softGray,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Drawer for compact viewports (< 900px)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.deepBlue,
      child: SafeArea(
        child: _buildSidebarContent(context, isDrawer: true),
      ),
    );
  }

  /// Unified sidebar / drawer content in #1F4E79 Deep Blue
  Widget _buildSidebarContent(BuildContext context, {required bool isDrawer}) {
    final vmsState = VmsScope.of(context);

    return Container(
      color: AppColors.deepBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- Brand Header ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VMS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Vehicle Management',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFD6E4F0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFF2C6396),
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 16),

          // --- Navigation Items ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    'MAIN NAVIGATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFA5C2DE),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                _buildNavItem(
                  context: context,
                  nav: AppShellNav.vehicles,
                  label: 'Vehicles',
                  icon: Icons.directions_car_rounded,
                  count: vmsState.totalCount,
                  isDrawer: isDrawer,
                ),
                const SizedBox(height: 4),
                _buildNavItem(
                  context: context,
                  nav: AppShellNav.register,
                  label: 'Register Vehicle',
                  icon: Icons.add_circle_outline_rounded,
                  isDrawer: isDrawer,
                ),
              ],
            ),
          ),

          const Spacer(),

          // --- Bottom User Profile & Sign Out ---
          const Divider(
            color: Color(0xFF2C6396),
            height: 1,
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E6A9E),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fleet Admin',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            vmsState.currentUser.isNotEmpty
                                ? vmsState.currentUser
                                : 'manager@stark.com',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFD6E4F0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    if (isDrawer) Navigator.of(context).pop();
                    vmsState.logout();
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 15,
                    color: Color(0xFFE2EBF4),
                  ),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE2EBF4),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Color(0xFF3872A4), width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Individual Navigation Button in Sidebar
  Widget _buildNavItem({
    required BuildContext context,
    required AppShellNav nav,
    required String label,
    required IconData icon,
    int? count,
    required bool isDrawer,
  }) {
    final bool isSelected = currentNav == nav;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          if (isDrawer) {
            Navigator.of(context).pop();
          }
          if (onNavSelected != null) {
            onNavSelected!(nav);
          }
        },
        borderRadius: BorderRadius.circular(8),
        hoverColor: const Color(0xFF28608F),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF173B5C) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? const Border(
                    left: BorderSide(color: AppColors.corporateBlue, width: 3),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppColors.white : const Color(0xFFD6E4F0),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.white : const Color(0xFFE5EEF7),
                  ),
                ),
              ),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.corporateBlue : const Color(0xFF28608F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Standard Page Header displayed in the workspace
  /// Left: Page title in Deep Blue (#1F4E79)
  /// Right: Primary action button (Register Vehicle or custom)
  Widget _buildStandardHeader(BuildContext context, {required bool showMenuButton}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (showMenuButton) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.deepBlue),
              tooltip: 'Open Menu',
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
            const SizedBox(width: 10),
          ],
          // Top Left Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepBlue,
                    letterSpacing: -0.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.charcoalSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Top Right Action
          if (primaryAction != null) ...[
            const SizedBox(width: 16),
            primaryAction!,
          ],
        ],
      ),
    );
  }
}
