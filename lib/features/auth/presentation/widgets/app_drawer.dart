import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/contact_footer.dart';
import '../bloc/auth_bloc.dart';

/// Side drawer for authentication & user profile.
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key, this.onLogoTap});

  /// Called when the app logo in the drawer header is tapped.
  /// Use this to close the drawer and navigate to the Generate tab.
  final VoidCallback? onLogoTap;

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  /// Tracks whether the user triggered a login/register action.
  /// Only close drawer on AuthAuthenticated if this is true.
  bool _wasAuthenticating = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Shared gradient header shown at the top of the drawer in all states.
  /// The [onClose] callback is called when the ✕ button is tapped.
  Widget _buildDrawerAppBar({required VoidCallback onClose}) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.teal, AppColors.darkTeal],
        ),
      ),
      child: Stack(
        children: [
          // Subtle watermark overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.06,
              child: Image.asset(
                'assets/app_logo.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
          ),

          // Close button — top-right inside the header
          Positioned(
            top: topPadding + 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: onClose,
            ),
          ),

          // App info content
          Padding(
            padding: EdgeInsets.fromLTRB(20, topPadding + 16, 56, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // App logo — tap to close drawer & go to Generate
                GestureDetector(
                  onTap: widget.onLogoTap ?? onClose,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/leos-logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Leos QR Generator',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Create, scan & manage QR codes & barcodes',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_isLogin) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    } else {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        return;
      }
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.offWhite.withValues(alpha: 0.95),
            ),
            child: SafeArea(
              top: false,
              child: BlocConsumer<AuthBloc, AuthState>(
                listenWhen: (previous, current) {
                  // Track when we enter a loading state from a login/register
                  if (current is AuthLoading &&
                      previous is! AuthAuthenticated) {
                    _wasAuthenticating = true;
                  }
                  return true;
                },
                listener: (context, state) {
                  if (state is AuthAuthenticated && _wasAuthenticating) {
                    // Only close drawer after a successful login/register action
                    _wasAuthenticating = false;
                    Navigator.pop(context);
                  } else if (state is AuthAuthenticated) {
                    // Already logged in – drawer just opened, don't close
                    _wasAuthenticating = false;
                  } else if (state is AuthPasswordResetEmailSent) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Password reset email sent! Check your inbox.',
                        ),
                        backgroundColor: AppColors.forest,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  } else if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return _buildProfileView(state);
                  }
                  return _buildAuthForm(state);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileView(AuthAuthenticated state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Drawer App Bar ───────────────────────────
        _buildDrawerAppBar(onClose: () => Navigator.pop(context)),

        // ─── Scrollable body ──────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar — tap to open Edit Profile
                GestureDetector(
                  onTap: () => _showEditProfileDialog(state),
                  child: Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: state.user.avatarUrl == null
                            ? AppColors.forestGradient
                            : null,
                        image: state.user.avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(state.user.avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forest.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: state.user.avatarUrl == null
                          ? Center(
                              child: Text(
                                (state.user.displayName?.isNotEmpty == true
                                        ? state.user.displayName!
                                        : state.user.email)
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    state.user.displayName ?? 'User',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    state.user.email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.darkGray),
                  ),
                ),
                const SizedBox(height: 28),

                // Menu Items
                _buildMenuItem(Icons.person_rounded, 'Edit Profile', () {
                  _showEditProfileDialog(state);
                }),
                Divider(
                  height: 32,
                  color: AppColors.charcoal.withValues(alpha: 0.1),
                ),
                _buildMenuItem(
                  Icons.support_agent_rounded,
                  'Support & Feedback',
                  () => _showSupportDialog(),
                ),
              ],
            ),
          ),
        ),

        // ─── Pinned bottom: Contact & Logout ─────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const ContactFooter(),
              const SizedBox(height: 12),
              AppButton(
                label: 'Log Out',
                icon: Icons.logout_rounded,
                variant: AppButtonVariant.outline,
                isExpanded: true,
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(AuthAuthenticated state) {
    final nameCtrl = TextEditingController(text: state.user.displayName ?? '');
    final passCtrl = TextEditingController();
    String? localAvatarPath;
    bool obscurePass = true;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.person_rounded, color: AppColors.forest),
                SizedBox(width: 8),
                Text('Edit Profile'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.lightGray,
                        backgroundImage: localAvatarPath != null
                            ? FileImage(File(localAvatarPath!))
                            : (state.user.avatarUrl != null
                                      ? NetworkImage(state.user.avatarUrl!)
                                      : null)
                                  as ImageProvider?,
                        child:
                            (localAvatarPath == null &&
                                state.user.avatarUrl == null)
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.mediumGray,
                              )
                            : null,
                      ),
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final file = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (file != null) {
                            setState(() => localAvatarPath = file.path);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.forest,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    maxLength: 100,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Enter your name',
                      prefixIcon: const Icon(
                        Icons.badge_rounded,
                        color: AppColors.sage,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passCtrl,
                    maxLength: 100,
                    obscureText: obscurePass,
                    decoration: InputDecoration(
                      labelText: 'New Password (Optional)',
                      hintText: 'Enter new password',
                      prefixIcon: const Icon(
                        Icons.lock_rounded,
                        color: AppColors.sage,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePass
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AppColors.mediumGray,
                        ),
                        onPressed: () =>
                            setState(() => obscurePass = !obscurePass),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Delete Account',
                    icon: Icons.delete_forever_rounded,
                    // backgroundColor: AppColors.error,
                    isExpanded: true,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (confirmCtx) => AlertDialog(
                          title: const Text('Delete Account?'),
                          content: const Text(
                            'Are you sure you want to delete your account? This will permanently delete your data.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(confirmCtx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(confirmCtx);
                                Navigator.pop(ctx);
                                context.read<AuthBloc>().add(
                                  AuthDeleteAccountRequested(),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        setState(() => isSaving = true);
                        context.read<AuthBloc>().add(
                          AuthUpdateProfileRequested(
                            displayName: nameCtrl.text.trim(),
                            newPassword: passCtrl.text.trim(),
                            avatarFilePath: localAvatarPath,
                          ),
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Profile updated!'),
                            backgroundColor: AppColors.forest,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSupportDialog() {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    bool isSubmitting = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.support_agent_rounded, color: AppColors.forest),
                SizedBox(width: 8),
                Text('Support & Feedback'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'We\'d love to hear from you! Submit a bug report, feature request, or general feedback.',
                    style: TextStyle(fontSize: 13, color: AppColors.darkGray),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subjectCtrl,
                    maxLength: 150,
                    decoration: InputDecoration(
                      labelText: 'Subject',
                      hintText: 'e.g., Feature request',
                      prefixIcon: const Icon(
                        Icons.subject_rounded,
                        color: AppColors.sage,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: messageCtrl,
                    maxLines: 4,
                    maxLength: 2000,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      hintText: 'Tell us more...',
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 60),
                        child: Icon(
                          Icons.message_rounded,
                          color: AppColors.sage,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                icon: isSubmitting
                    ? const SizedBox.shrink()
                    : const Icon(Icons.send_rounded, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (subjectCtrl.text.trim().isEmpty ||
                            messageCtrl.text.trim().isEmpty) {
                          return;
                        }
                        setState(() => isSubmitting = true);
                        try {
                          final accessKey =
                              dotenv.env['VITE_WEB3FORMS_ACCESS_KEY'] ?? '';

                          // Sender info — use logged-in user info if available
                          final authState = context.read<AuthBloc>().state;
                          final senderName = authState is AuthAuthenticated
                              ? (authState.user.displayName ?? 'App User')
                              : 'App User';
                          final senderEmail = authState is AuthAuthenticated
                              ? authState.user.email
                              : 'noreply@leosqr.app';

                          final res = await http.post(
                            Uri.parse('https://api.web3forms.com/submit'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              'access_key': accessKey,
                              'subject': '[QR App Feedback]',
                              'from_name': senderName,
                              'email': senderEmail,
                              'message':
                                  'Subject: ${subjectCtrl.text.trim()}\n\nMessage:\n${messageCtrl.text.trim()}',
                            }),
                          );

                          // Web3Forms returns JSON {success: true/false}
                          final body =
                              jsonDecode(res.body) as Map<String, dynamic>;
                          final success = body['success'] == true;

                          if (success && context.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Thank you! Your feedback has been sent.',
                                ),
                                backgroundColor: AppColors.forest,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          } else if (context.mounted) {
                            final msg = body['message'] ?? 'Submission failed.';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $msg'),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to send: ${e.toString()}',
                                ),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => isSubmitting = false);
                          }
                        }
                      },
                label: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.forest),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.charcoal,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.mediumGray,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }

  Widget _buildAuthForm(AuthState state) {
    return Column(
      children: [
        // ─── Drawer App Bar ─────────────────────────────
        _buildDrawerAppBar(onClose: () => Navigator.pop(context)),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      _isLogin ? 'Welcome Back' : 'Create Account',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(color: AppColors.charcoal),
                    ),
                  ),
                  Center(
                    child: Text(
                      _isLogin
                          ? 'Sign in to sync your data'
                          : 'Get started with QR Generator',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkGray,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name (register only)
                  if (!_isLogin) ...[
                    AppTextField(
                      controller: _nameController,
                      label: 'Display Name',
                      hint: 'Choco De Jesus',
                      prefixIcon: Icons.person_rounded,
                      maxLength: 100,
                      validator: (v) => null, // Optional
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email
                  AppTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'you@example.com',
                    prefixIcon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 100,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_rounded,
                    obscureText: _obscurePassword,
                    maxLength: 100,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppColors.mediumGray,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password (register only)
                  if (!_isLogin) ...[
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_rounded,
                      obscureText: true,
                      maxLength: 100,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Forgot Password
                  if (_isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              final resetEmailCtrl = TextEditingController(
                                text: _emailController.text,
                              );
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Row(
                                  children: [
                                    Icon(
                                      Icons.lock_reset_rounded,
                                      color: AppColors.forest,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Reset Password',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Enter your email to receive a password reset link.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: resetEmailCtrl,
                                      maxLength: 100,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: const Icon(
                                          Icons.email_rounded,
                                          color: AppColors.sage,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.forest,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (resetEmailCtrl.text
                                          .trim()
                                          .isNotEmpty) {
                                        context.read<AuthBloc>().add(
                                          AuthForgotPasswordRequested(
                                            email: resetEmailCtrl.text.trim(),
                                          ),
                                        );
                                        Navigator.pop(ctx);
                                      }
                                    },
                                    child: const Text('Send Link'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Submit Button
                  AppButton(
                    label: _isLogin ? 'Log In' : 'Sign Up',
                    icon: _isLogin
                        ? Icons.login_rounded
                        : Icons.person_add_rounded,
                    isLoading: state is AuthLoading,
                    isExpanded: true,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 24),

                  // Toggle login/register
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin
                            ? "Don't have an account? Sign Up"
                            : 'Already have an account? Log In',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const ContactFooter(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
