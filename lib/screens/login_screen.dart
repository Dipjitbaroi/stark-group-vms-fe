import 'package:flutter/material.dart';
import '../services/api_exception.dart';
import '../state/vms_state.dart';
import '../theme/app_colors.dart';
import '../widgets/labeled_form_field.dart';
import '../widgets/primary_button.dart';

/// Stark Group VMS Login Screen.
///
/// Features:
/// - Centered White (`#FFFFFF`) card on Soft Gray (`#F5F7FA`) background
/// - Stark Group VMS branding in Deep Blue (`#1F4E79`)
/// - Clean Email/Username and Password fields with labels positioned above inputs
/// - Inline validation messages in Red (`#D32F2F`)
/// - Corporate Blue (`#5B9BD5`) primary Sign In button
/// - Demo credentials quick-fill helper for instant evaluation
class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _generalError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    setState(() {
      _generalError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final vmsState = VmsScope.of(context);
    try {
      await vmsState.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      widget.onLoginSuccess();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _generalError = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _generalError = 'Failed to connect to backend server. Please verify the service is running.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGray,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon & Header
                    Center(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.deepBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          color: AppColors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Stark Group VMS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepBlue,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Vehicle Management System Portal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.charcoalSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Inline General Error Banner if present
                    if (_generalError != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _generalError!,
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

                    // Email / Username field with top label in Charcoal
                    LabeledFormField(
                      label: 'Email or Username',
                      isRequired: true,
                      controller: _emailController,
                      hintText: 'Enter your email or username',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.charcoalSecondary,
                        size: 20,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email or username is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Password field with top label in Charcoal
                    LabeledFormField(
                      label: 'Password',
                      isRequired: true,
                      controller: _passwordController,
                      hintText: 'Enter your account password',
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.charcoalSecondary,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.charcoalSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 4) {
                          return 'Password must be at least 4 characters';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _handleSignIn(),
                    ),
                    const SizedBox(height: 26),

                    // Primary Sign In Button in Corporate Blue (#5B9BD5)
                    PrimaryButton(
                      label: 'Sign In to VMS',
                      isLoading: _isLoading,
                      height: 44,
                      onPressed: _handleSignIn,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
