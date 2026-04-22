import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _contactNumber = TextEditingController();

  String _role = 'Administrator';
  bool _loading = false;
  bool _obscure = true;
  bool _obscure2 = true;
  int _step = 0;

  // Real-time password strength
  double get _passwordStrength {
    final p = _password.text;
    if (p.isEmpty) return 0;
    double s = 0;
    if (p.length >= 8) s += 0.25;
    if (p.contains(RegExp(r'[A-Z]'))) s += 0.25;
    if (p.contains(RegExp(r'[0-9]'))) s += 0.25;
    if (p.contains(RegExp(r'[!@#\$&*~_\-]'))) s += 0.25;
    return s;
  }

  Color get _strengthColor {
    final s = _passwordStrength;
    if (s <= 0.25) return AppTheme.danger;
    if (s <= 0.50) return AppTheme.warning;
    if (s <= 0.75) return const Color(0xFF3B82F6);
    return AppTheme.success;
  }

  String get _strengthLabel {
    final s = _passwordStrength;
    if (s <= 0.25) return 'Weak';
    if (s <= 0.50) return 'Fair';
    if (s <= 0.75) return 'Good';
    return 'Strong ✓';
  }

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _password.addListener(() => setState(() {})); // live strength update
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _contactNumber.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0) {
      _animate(() => _step = 1);
    } else if (_step == 1 && _role == 'Caregiver') {
      if (!_form.currentState!.validate()) return;
      _animate(() => _step = 2);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_step == 0) {
      context.pop();
      return;
    }
    _animate(() => _step -= 1);
  }

  void _animate(VoidCallback change) {
    _animCtrl.reset();
    setState(change);
    _animCtrl.forward();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    final error = await context.read<AuthService>().register(
          username: _username.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          passwordConfirmation: _confirmPassword.text,
          role: _role,
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          contactNumber: _contactNumber.text.trim(),
        );
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

  int get _totalSteps => _role == 'Caregiver' ? 3 : 2;

  @override
  Widget build(BuildContext context) {
    final stepTitles = ['Choose your role', 'Account details', 'Personal info'];

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: _prevStep,
        ),
        title: Text(
          stepTitles[_step],
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Step indicator — thicker active bar ──────────
              _StepIndicator(current: _step, total: _totalSteps),
              const SizedBox(height: 28),

              // ── STEP 0: Role selection ───────────────────────
              if (_step == 0) ...[
                const Text('Who are you?',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 6),
                Text('Select your role to get started.',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary.withValues(alpha: 0.6))),
                const SizedBox(height: 24),

                // Both cards have equal visual weight when unselected
                _RoleCard(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Administrator',
                  subtitle: 'Manage staff, residents, and the full system.',
                  color: AppTheme.primary,
                  selected: _role == 'Administrator',
                  onTap: () => setState(() => _role = 'Administrator'),
                ),
                const SizedBox(height: 12),
                _RoleCard(
                  icon: Icons.medical_services_rounded,
                  title: 'Caregiver',
                  subtitle: 'Log vitals, medications, and monitor residents.',
                  color: AppTheme.accent,
                  selected: _role == 'Caregiver',
                  onTap: () => setState(() => _role = 'Caregiver'),
                ),
              ],

              // ── STEP 1: Account credentials ──────────────────
              if (_step == 1) ...[
                Text('Creating a $_role account',
                    style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary.withValues(alpha: 0.6))),
                const SizedBox(height: 20),
                Form(
                  key: _form,
                  child: Column(children: [
                    _Field(
                      controller: _username,
                      label: 'Username',
                      icon: Icons.person_outline_rounded,
                      action: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      controller: _email,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      type: TextInputType.emailAddress,
                      action: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Required';
                        } 
                        if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.\w{2,}$')
                            .hasMatch(v)) {
                              return 'Enter a valid email';
                            }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Password with real-time strength meter
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon:
                            const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          tooltip: _obscure ? 'Show' : 'Hide',
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: _obscure
                                ? AppTheme.textSecondary
                                : AppTheme.primary,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 8) {
                          return 'At least 8 characters required';
                        }
                        return null;
                      },
                    ),

                    // Strength meter — only shows when typing
                    if (_password.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _passwordStrength,
                              minHeight: 4,
                              backgroundColor: AppTheme.border,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_strengthColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _strengthLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _strengthColor,
                          ),
                        ),
                      ]),
                    ],
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _confirmPassword,
                      obscureText: _obscure2,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon:
                            const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: (_confirmPassword.text.isNotEmpty &&
                                _confirmPassword.text == _password.text)
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppTheme.success, size: 20)
                            : IconButton(
                                tooltip: _obscure2 ? 'Show' : 'Hide',
                                icon: Icon(
                                  _obscure2
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: _obscure2
                                      ? AppTheme.textSecondary
                                      : AppTheme.primary,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure2 = !_obscure2),
                              ),
                      ),
                      onChanged: (_) => setState(() {}), // refresh checkmark
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v != _password.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ]),
                ),
              ],

              // ── STEP 2: Caregiver personal info ─────────────
              if (_step == 2) ...[
                Text('These details appear on your profile.',
                    style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary.withValues(alpha: 0.6))),
                const SizedBox(height: 20),
                Form(
                  key: _form,
                  child: Column(children: [
                    _Field(
                      controller: _firstName,
                      label: 'First Name',
                      icon: Icons.badge_outlined,
                      action: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      controller: _lastName,
                      label: 'Last Name',
                      icon: Icons.badge_outlined,
                      action: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      controller: _contactNumber,
                      label: 'Contact Number',
                      icon: Icons.phone_outlined,
                      type: TextInputType.phone,
                      action: TextInputAction.done,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ]),
                ),
              ],

              const SizedBox(height: 32),

              // Primary CTA
              ElevatedButton(
                onPressed: _loading ? null : _nextStep,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        _step == 0
                            ? 'Continue'
                            : (_step == 1 && _role == 'Caregiver')
                                ? 'Next'
                                : 'Create Account',
                      ),
              ),
              // No "Back to Login" button — the ← arrow in AppBar handles it
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Thicker step indicator with animated active bar ───────────
class _StepIndicator extends StatelessWidget {
  final int current, total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) => Row(
        children: List.generate(total, (i) {
          final active = i <= current;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              height: active ? 6 : 4, // active bar is thicker
              decoration: BoxDecoration(
                color: active ? AppTheme.primary : AppTheme.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      );
}

// ── Role card — equal visual weight for both options ──────────
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        // entire card is the touch target
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // subtle tint when selected; plain white when not — equal weight
            color: selected ? color.withValues(alpha: 0.06) : AppTheme.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : AppTheme.border,
              width: 1.5,
            ),
          ),
          child: Row(children: [
            // Icon container — same size regardless of selection
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.15)
                    : AppTheme.bgPage, // neutral background when unselected
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? color.withValues(alpha: 0.3) : AppTheme.border,
                ),
              ),
              child: Icon(icon,
                  size: 22, color: selected ? color : AppTheme.textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: selected ? color : AppTheme.textPrimary,
                      )),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        // same opacity for both so neither looks disabled
                        color: AppTheme.textPrimary.withValues(alpha: 0.55),
                      )),
                ])),
            // Checkmark only on selected
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? Icon(Icons.check_circle_rounded,
                      key: const ValueKey('check'), color: color, size: 20)
                  : const SizedBox(width: 20, key: ValueKey('empty')),
            ),
          ]),
        ),
      );
}

// ── Reusable form field ───────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType type;
  final TextInputAction action;
  final String? Function(String?) validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.type = TextInputType.text,
    required this.action,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        keyboardType: type,
        textInputAction: action,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
        ),
        validator: validator,
      );
}
