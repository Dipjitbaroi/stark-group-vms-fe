import 'package:flutter/material.dart';

/// Centralized Stark Group VMS Design System Color Tokens.
///
/// Design Principle: Use color strictly to communicate hierarchy, actions,
/// and status—never as arbitrary decoration. Clarity over ornamentation.
class AppColors {
  AppColors._();

  // --- CORE TOKENS (Strict Stark Group VMS Palette) ---

  /// Deep Blue (`#1F4E79`): Navigation sidebar, page headings, and strong structural headers.
  static const Color deepBlue = Color(0xFF1F4E79);

  /// Deep Blue Darker (`#173B5C`): Sidebar active background or hover state.
  static const Color deepBlueDark = Color(0xFF173B5C);

  /// Corporate Blue (`#5B9BD5`): Primary action buttons (e.g., "Register Vehicle"),
  /// active highlights, and focus rings.
  static const Color corporateBlue = Color(0xFF5B9BD5);

  /// Corporate Blue Hover (`#4A8BC4`): Slightly darker for accessible contrast on hover.
  static const Color corporateBlueHover = Color(0xFF4A8BC4);

  /// Corporate Blue Pressed (`#3A77AE`): Pressed / active interaction state.
  static const Color corporateBluePressed = Color(0xFF3A77AE);

  /// Corporate Blue Light (`#EBF3FB`): Soft background tint for selected navigation items.
  static const Color corporateBlueTint = Color(0xFFEBF3FB);

  /// Soft Gray (`#F5F7FA`): Main page/workspace background.
  static const Color softGray = Color(0xFFF5F7FA);

  /// White (`#FFFFFF`): Elevated/bordered surfaces for cards, forms, login container,
  /// and data tables with subtle 1px borders.
  static const Color white = Color(0xFFFFFFFF);

  /// Charcoal (`#1F2937`): Primary body text, table cell values, and form labels.
  static const Color charcoal = Color(0xFF1F2937);

  /// Charcoal Secondary (`#4B5563`): Secondary text, subtitles, table headers, breadcrumbs.
  static const Color charcoalSecondary = Color(0xFF4B5563);

  /// Charcoal Muted (`#9CA3AF`): Placeholder hints, disabled states, divider lines.
  static const Color charcoalMuted = Color(0xFF9CA3AF);

  /// Green (`#2E7D32`): Active / Success status badges ONLY.
  static const Color green = Color(0xFF2E7D32);

  /// Soft Green Background (`#E8F5E9`): Pill background for Active status badges ONLY.
  static const Color greenBackground = Color(0xFFE8F5E9);

  /// Red (`#D32F2F`): Delete actions and form/validation error states ONLY.
  static const Color red = Color(0xFFD32F2F);

  /// Soft Red Background (`#FDE8E8` / `#FFEBEE`): Container for Delete button and error banners ONLY.
  static const Color redBackground = Color(0xFFFDE8E8);

  /// Red Border (`#FCA5A5`): Border for soft-red Delete button and error states.
  static const Color redBorder = Color(0xFFFCA5A5);

  /// Subtle Border (`#E5E7EB`): Standard 1px border for cards, inputs, and tables.
  static const Color border = Color(0xFFE5E7EB);

  /// Subtle Border Darker (`#D1D5DB`): Input hover or active border.
  static const Color borderDark = Color(0xFFD1D5DB);

  // --- NEUTRAL STATUS BADGE (for Inactive status, strictly preserving Green for Active only) ---

  /// Neutral Status Text & Dot (`#6B7280`): For Inactive status badges.
  static const Color neutralStatusText = Color(0xFF6B7280);

  /// Neutral Status Background (`#F3F4F6`): For Inactive status badges.
  static const Color neutralStatusBackground = Color(0xFFF3F4F6);
}
