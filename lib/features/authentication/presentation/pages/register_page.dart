import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../data/models/auth_model.dart';
import '../providers/auth_provider.dart';

enum RegisterStep { selectRole, fillDetails }

class RegisterPage extends ConsumerStatefulWidget {
  final bool initialIsBroker;

  const RegisterPage({super.key, this.initialIsBroker = false});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  late RegisterStep _currentStep;
  late bool _isBroker;

  // Common Fields
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // Broker Specific Fields
  final _companyCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Addis Ababa');
  final _countryCtrl = TextEditingController(text: 'Ethiopia');
  final _websiteCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isBroker = widget.initialIsBroker;
    _currentStep = widget.initialIsBroker
        ? RegisterStep.fillDetails
        : RegisterStep.selectRole;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();

    _companyCtrl.dispose();
    _licenseCtrl.dispose();
    _expiryCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _websiteCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.lightTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final y = picked.year.toString().padLeft(4, '0');
      final m = picked.month.toString().padLeft(2, '0');
      final d = picked.day.toString().padLeft(2, '0');
      setState(() {
        _expiryCtrl.text = '$y-$m-$d';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    if (_isBroker) {
      if (_expiryCtrl.text.trim().isEmpty) {
        context.showErrorSnackBar('Please select the broker license expiry date.');
        return;
      }

      final req = BrokerRegisterRequest(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        phone: _phoneCtrl.text.trim(),
        companyName: _companyCtrl.text.trim(),
        licenseNumber: _licenseCtrl.text.trim(),
        licenseExpiry: _expiryCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        country: _countryCtrl.text.trim().isEmpty
            ? 'Ethiopia'
            : _countryCtrl.text.trim(),
        website: _websiteCtrl.text.trim().isEmpty
            ? null
            : _websiteCtrl.text.trim(),
        notes:
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      final success =
          await ref.read(authNotifierProvider.notifier).registerBroker(req);

      if (!mounted) return;

      if (success) {
        _showBrokerApprovalDialog();
      } else {
        final errorMsg = ref.read(authNotifierProvider).errorMessage ??
            'Broker registration failed. Please try again.';
        context.showErrorSnackBar(errorMsg);
      }
    } else {
      // Customer registration
      final success = await ref.read(authNotifierProvider.notifier).register(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            phone: _phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim(),
          );

      if (!mounted) return;

      if (success) {
        final successMsg = ref.read(authNotifierProvider).successMessage ??
            'Registration successful!';
        context.showSuccessSnackBar(successMsg);
        context.go(AppConstants.routeDashboard);
      } else {
        final errorMsg = ref.read(authNotifierProvider).errorMessage ??
            'Registration failed. Please try again.';
        context.showErrorSnackBar(errorMsg);
      }
    }
  }

  void _showBrokerApprovalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: Color(0xFFD97706),
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Application Submitted',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(
                'STATUS: PENDING_APPROVAL',
                style: AppTextStyles.labelSmall.copyWith(
                  color: const Color(0xFF92400E),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Your broker registration has been submitted. Our compliance team will verify your licensing documentation and activate your account. You will receive an email once approved.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Back to Sign In',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go(AppConstants.routeLogin);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack() {
    if (_currentStep == RegisterStep.fillDetails) {
      setState(() {
        _currentStep = RegisterStep.selectRole;
      });
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      authNotifierProvider.select((s) => s.isLoading),
    );

    return PopScope(
      canPop: _currentStep == RegisterStep.selectRole,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _currentStep == RegisterStep.selectRole
                ? 'Join Mekenet'
                : (_isBroker ? 'Broker Registration' : 'Customer Registration'),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _handleBack,
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _currentStep == RegisterStep.selectRole
                ? _buildRoleSelectionView()
                : _buildDetailsFormView(isLoading),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ── STEP 1: Select Role (Customer or Broker) ─────────────────────
  // ════════════════════════════════════════════════════════════════

  Widget _buildRoleSelectionView() {
    return SingleChildScrollView(
      key: const ValueKey('step_select_role'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.lightBorder,
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      AppConstants.logoAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.85, 0.85)),
                const SizedBox(height: 14),
                Text(
                  'Choose Account Type',
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 6),
                Text(
                  'Please select how you want to use Mekenet Insurance to continue.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 150.ms),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Option 1: Individual Customer ──────────────────────
          _AccountTypeCard(
            title: 'Individual Customer',
            subtitle: 'Personal & Family Policyholder',
            description:
                'Buy and manage motor, health, life, and property policies with instant digital card & claims filing.',
            icon: Icons.person_rounded,
            iconColor: const Color(0xFF0284C7),
            iconBg: const Color(0xFFE0F2FE),
            isSelected: !_isBroker,
            tag: 'Instant Access',
            tagColor: const Color(0xFF0284C7),
            features: const [
              'Browse and purchase insurance policies',
              'Digital insurance card with QR code',
              'Online claims submission & tracking',
            ],
            onTap: () => setState(() => _isBroker = false),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: 16),

          // ── Option 2: Insurance Broker ─────────────────────────
          _AccountTypeCard(
            title: 'Insurance Broker',
            subtitle: 'Licensed Insurance Partner',
            description:
                'For licensed brokers and agencies managing client insurance portfolios, quotes, and commission statements.',
            icon: Icons.business_center_rounded,
            iconColor: const Color(0xFFD97706),
            iconBg: const Color(0xFFFEF3C7),
            isSelected: _isBroker,
            tag: 'Partnership',
            tagColor: const Color(0xFFD97706),
            features: const [
              'Manage and service client policies',
              'Broker Dashboard & sales analytics',
              'Commission tracking & statements',
            ],
            onTap: () => setState(() => _isBroker = true),
          ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
          const SizedBox(height: 32),

          // Next Button
          AppButton(
            label: 'Next: Fill Details →',
            onPressed: () {
              setState(() {
                _currentStep = RegisterStep.fillDetails;
              });
            },
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 20),

          // Already have an account link
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: AppTextStyles.bodyMedium,
                ),
                TextButton(
                  onPressed: () => context.pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'auth.sign_in'.tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ── STEP 2: Fill Registration Details ────────────────────────────
  // ════════════════════════════════════════════════════════════════

  Widget _buildDetailsFormView(bool isLoading) {
    return SingleChildScrollView(
      key: const ValueKey('step_fill_details'),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Role Indicator Bar with "Change" button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _isBroker
                    ? const Color(0xFFFEF3C7).withOpacity(0.7)
                    : const Color(0xFFE0F2FE).withOpacity(0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isBroker
                      ? const Color(0xFFF59E0B).withOpacity(0.4)
                      : const Color(0xFF38BDF8).withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isBroker
                        ? Icons.business_center_rounded
                        : Icons.person_rounded,
                    size: 20,
                    color: _isBroker
                        ? const Color(0xFFB45309)
                        : const Color(0xFF0369A1),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REGISTERING AS',
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 9.5,
                            color: _isBroker
                                ? const Color(0xFF92400E)
                                : const Color(0xFF0369A1),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          _isBroker
                              ? 'Insurance Broker'
                              : 'Individual Customer',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _isBroker
                                ? const Color(0xFF78350F)
                                : const Color(0xFF0C4A6E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = RegisterStep.selectRole;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Change',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: _isBroker
                            ? const Color(0xFFB45309)
                            : const Color(0xFF0369A1),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Broker notice banner
            if (_isBroker) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFD97706),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Broker accounts are reviewed and activated by our team upon licensing verification (PENDING_APPROVAL).',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF92400E),
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Section 1: Contact Information
            _SectionTitle(
                title: _isBroker ? '1. Account & Contact Details' : 'Personal Information'),
            const SizedBox(height: 12),

            // Full Name
            AppTextField(
              label: _isBroker
                  ? 'Full Name / Contact Person'
                  : 'auth.full_name'.tr(),
              controller: _nameCtrl,
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) =>
                  Validators.required(v, fieldName: 'Full Name'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),

            // Email
            AppTextField(
              label: _isBroker ? 'Work Email Address' : 'auth.email'.tr(),
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: Validators.email,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),

            // Phone
            AppTextField(
              label: _isBroker
                  ? 'Phone Number (Required)'
                  : '${'auth.phone_number'.tr()} (${'common.optional'.tr()})',
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (v) => _isBroker
                  ? Validators.required(v, fieldName: 'Phone Number')
                  : Validators.phone(v),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),

            // Password
            PasswordField(
              label: 'auth.password'.tr(),
              controller: _passwordCtrl,
              validator: Validators.password,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),

            // Confirm password
            _ConfirmPasswordField(
              controller: _confirmCtrl,
              passwordController: _passwordCtrl,
            ),
            const SizedBox(height: 20),

            // Section 2: Brokerage & Licensing (Broker only)
            if (_isBroker) ...[
              const _SectionTitle(title: '2. Brokerage & Licensing'),
              const SizedBox(height: 12),

              // Company Name
              AppTextField(
                label: 'Company / Brokerage Name',
                controller: _companyCtrl,
                prefixIcon: Icons.business_outlined,
                validator: (v) =>
                    Validators.required(v, fieldName: 'Company Name'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              // License Number
              AppTextField(
                label: 'Insurance Broker License Number',
                controller: _licenseCtrl,
                prefixIcon: Icons.badge_outlined,
                validator: (v) =>
                    Validators.required(v, fieldName: 'License Number'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              // License Expiry Date (Picker)
              AppTextField(
                label: 'License Expiry Date (YYYY-MM-DD)',
                controller: _expiryCtrl,
                prefixIcon: Icons.calendar_today_outlined,
                suffix: const Icon(Icons.arrow_drop_down),
                readOnly: true,
                onTap: _pickExpiryDate,
                validator: (v) => Validators.required(v,
                    fieldName: 'License Expiry Date'),
              ),
              const SizedBox(height: 20),

              // Section 3: Location & Details (Broker only)
              const _SectionTitle(title: '3. Location & Notes'),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'City',
                      controller: _cityCtrl,
                      prefixIcon: Icons.location_city_outlined,
                      validator: (v) =>
                          Validators.required(v, fieldName: 'City'),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Country',
                      controller: _countryCtrl,
                      prefixIcon: Icons.flag_outlined,
                      validator: (v) =>
                          Validators.required(v, fieldName: 'Country'),
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Website
              AppTextField(
                label: 'Company Website (Optional)',
                controller: _websiteCtrl,
                prefixIcon: Icons.language_outlined,
                hint: 'https://example.com',
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              // Notes
              AppTextField(
                label: 'Notes / Remarks (Optional)',
                controller: _notesCtrl,
                prefixIcon: Icons.note_alt_outlined,
                hint: 'Brief background, insurance categories handled...',
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
            ],

            const SizedBox(height: 12),

            // Submit Button
            AppButton(
              label: _isBroker
                  ? 'Submit Broker Application'
                  : 'auth.sign_up'.tr(),
              onPressed: _submit,
              isLoading: isLoading,
            ),
            const SizedBox(height: 16),

            // Back button text
            Center(
              child: TextButton.icon(
                onPressed: _handleBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Back to Account Type Selection'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ── Account Type Card Component ──────────────────────────────────
// ════════════════════════════════════════════════════════════════

class _AccountTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isSelected;
  final String tag;
  final Color tagColor;
  final List<String> features;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.isSelected,
    required this.tag,
    required this.tagColor,
    required this.features,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Icon + Title + Selection Indicator
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: tagColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: tagColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Radio indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.lightTextSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            // Bullets
            ...features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        f,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.labelLarge.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Confirm-password field that reactively re-validates when the
/// primary password field changes.
class _ConfirmPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final TextEditingController passwordController;

  const _ConfirmPasswordField({
    required this.controller,
    required this.passwordController,
  });

  @override
  State<_ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<_ConfirmPasswordField> {
  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() => setState(() {});

  @override
  void dispose() {
    widget.passwordController.removeListener(_onPasswordChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PasswordField(
      label: 'auth.confirm_password'.tr(),
      controller: widget.controller,
      textInputAction: TextInputAction.done,
      validator: (v) => Validators.confirmPassword(
        v,
        widget.passwordController.text,
      ),
    );
  }
}
