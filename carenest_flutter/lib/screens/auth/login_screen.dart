// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _usernameFocus = FocusNode();
  bool _loading = false;
  bool _obscure = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _usernameFocus.requestFocus());
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _username.dispose();
    _password.dispose();
    _usernameFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final error = await context
        .read<AuthService>()
        .login(_username.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      context.go('/');
    }
  }

  void _openForgotPassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ForgotPasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const CareNestLogo(large: false),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _form,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome back',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Sign in to continue',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textPrimary.withValues(alpha: 0.6))),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _username,
                          focusNode: _usernameFocus,
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixIcon:
                                Icon(Icons.person_outline_rounded, size: 20),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Username is required'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _login(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                size: 20),
                            suffixIcon: IconButton(
                              tooltip:
                                  _obscure ? 'Show password' : 'Hide password',
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: _obscure
                                    ? AppTheme.textSecondary
                                    : AppTheme.primary,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Password is required'
                              : null,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _openForgotPassword,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 0),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Forgot password?',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loading ? null : _login,
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Sign In'),
                        ),
                      ]),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text("Don't have an account? ",
                      style: TextStyle(
                          color: AppTheme.textPrimary.withValues(alpha: 0.6),
                          fontSize: 14)),
                  GestureDetector(
                    onTap: () => context.push('/signup'),
                    child: const Text('Sign Up',
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Only Administrators and Caregivers\ncan access this system.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textPrimary.withValues(alpha: 0.4),
                      height: 1.5),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Forgot Password bottom sheet — 2-step ────────────────────
// Step 1: Enter email → verify against DB
// Step 2: Enter new password → update DB
class _ForgotPasswordSheet extends StatefulWidget {
  const _ForgotPasswordSheet();
  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  // Step 1 controllers
  final _emailCtrl = TextEditingController();

  // Step 2 controllers
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _step2Form = GlobalKey<FormState>();

  // Reset token data from server
  String? _resetToken;
  String? _role;
  int? _userId;

  // UI state
  int _step = 1; // 1 = enter email, 2 = enter new password, 3 = success
  bool _loading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  /// Step 1: Send email to backend for verification
  Future<void> _verifyEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiService.post('/forgot-password/verify', {
        'email': email,
      });
      final data = res.data as Map<String, dynamic>;
      if (data['found'] == true) {
        setState(() {
          _resetToken = data['reset_token'] as String;
          _role = data['role'] as String;
          _userId = data['user_id'] as int;
          _step = 2;
          _loading = false;
        });
      } else {
        setState(() {
          _error = data['message'] ?? 'Email not found.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'No account found with that email address.';
        _loading = false;
      });
    }
  }

  /// Step 2: Send new password + reset token to backend
  Future<void> _resetPassword() async {
    if (!_step2Form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiService.post('/forgot-password/reset', {
        'email': _emailCtrl.text.trim(),
        'role': _role,
        'user_id': _userId,
        'reset_token': _resetToken,
        'new_password': _newPassCtrl.text,
        'new_password_confirmation': _confirmCtrl.text,
      });
      setState(() {
        _step = 3;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to reset password. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),

        const Icon(Icons.lock_reset_rounded, size: 36, color: AppTheme.primary),
        const SizedBox(height: 10),
        Text(
          _step == 1
              ? 'Reset Password'
              : _step == 2
                  ? 'Set New Password'
                  : 'Password Updated',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 6),

        // ── STEP 1: Email input ───────────────────────
        if (_step == 1) ...[
          Text(
            'Enter the email address linked to your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary.withValues(alpha: 0.6),
                height: 1.5),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _verifyEmail(),
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppTheme.danger, size: 16),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(_error!,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.danger))),
              ]),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _verifyEmail,
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Verify Email'),
          ),
        ],

        // ── STEP 2: New password ──────────────────────
        if (_step == 2) ...[
          Text(
            'Create a new password for\n${_emailCtrl.text.trim()}',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary.withValues(alpha: 0.6),
                height: 1.5),
          ),
          const SizedBox(height: 20),
          Form(
            key: _step2Form,
            child: Column(children: [
              TextFormField(
                controller: _newPassCtrl,
                obscureText: _obscureNew,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: _obscureNew
                          ? AppTheme.textSecondary
                          : AppTheme.primary,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 8) return 'At least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _resetPassword(),
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: _obscureConfirm
                          ? AppTheme.textSecondary
                          : AppTheme.primary,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v != _newPassCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ]),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppTheme.danger, size: 16),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(_error!,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.danger))),
              ]),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loading ? null : _resetPassword,
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Update Password'),
          ),
        ],

        // ── STEP 3: Success ───────────────────────────
        if (_step == 3) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
            ),
            child: const Row(children: [
              Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.success, 
                  size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your password has been updated successfully. '
                  'You can now sign in with your new password.',
                  style: TextStyle(
                      fontSize: 13, 
                      color: AppTheme.success, 
                      height: 1.4),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Login'),
          ),
        ],
      ]),
    );
  }
}
