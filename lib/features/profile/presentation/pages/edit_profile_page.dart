import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../providers/profile_provider.dart';
import '../../data/models/profile_model.dart';
import '../../../../core/utils/date_formatter.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String? _gender;
  String? _maritalStatus;
  String? _bloodGroup;
  DateTime? _dob;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _addressCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _initFromProfile(CustomerProfileModel profile) {
    if (_initialized) return;
    _nameCtrl.text = profile.name;
    _phoneCtrl.text = profile.phone ?? '';
    _cityCtrl.text = profile.city ?? '';
    _stateCtrl.text = profile.state ?? '';
    _countryCtrl.text = profile.country ?? '';
    _addressCtrl.text = profile.address ?? '';
    _heightCtrl.text = profile.height?.toString() ?? '';
    _weightCtrl.text = profile.weight?.toString() ?? '';
    _gender = profile.gender;
    _maritalStatus = profile.maritalStatus;
    _bloodGroup = profile.bloodGroup;
    _dob = AppFormatter.parseDate(profile.dob);
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final req = UpdateProfileRequest(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      dob: _dob != null ? AppFormatter.toApiDate(_dob!) : null,
      gender: _gender,
      maritalStatus: _maritalStatus,
      bloodGroup: _bloodGroup,
      height: double.tryParse(_heightCtrl.text),
      weight: double.tryParse(_weightCtrl.text),
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim().isEmpty ? null : _stateCtrl.text.trim(),
      country: _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
      address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
    );

    final success = await ref.read(updateProfileProvider.notifier).update(req);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'profile.update_success'.tr()
              : 'common.error'.tr()),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);
    final updateState = ref.watch(updateProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text('profile.edit_profile'.tr())),
      body: profileAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) {
          _initFromProfile(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('profile.personal_info'.tr()),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'common.name'.tr(),
                    controller: _nameCtrl,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'auth.phone_number'.tr(),
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 16),

                  // DOB
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('profile.date_of_birth'.tr(),
                          style: AppTextStyles.labelLarge),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _dob ??
                                DateTime.now()
                                    .subtract(const Duration(days: 365 * 25)),
                            firstDate: DateTime(1920),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) setState(() => _dob = d);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightBorder),
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.grey50,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 18, color: AppColors.grey400),
                              const SizedBox(width: 10),
                              Text(
                                _dob != null
                                    ? AppFormatter.formatDate(_dob)
                                    : 'Select date of birth',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: _dob != null
                                      ? null
                                      : AppColors.lightTextHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  _DropdownField<String>(
                    label: 'profile.gender'.tr(),
                    value: _gender,
                    items: const ['Male', 'Female', 'Other'],
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                  const SizedBox(height: 16),

                  // Marital Status
                  _DropdownField<String>(
                    label: 'profile.marital_status'.tr(),
                    value: _maritalStatus,
                    items: const ['Single', 'Married', 'Divorced', 'Widowed'],
                    onChanged: (v) => setState(() => _maritalStatus = v),
                  ),
                  const SizedBox(height: 16),

                  // Blood Group
                  _DropdownField<String>(
                    label: 'profile.blood_group'.tr(),
                    value: _bloodGroup,
                    items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
                    onChanged: (v) => setState(() => _bloodGroup = v),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'profile.height'.tr() + ' (cm)',
                          controller: _heightCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'profile.weight'.tr() + ' (kg)',
                          controller: _weightCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}'))
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _SectionTitle('Address'),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'City',
                    controller: _cityCtrl,
                    prefixIcon: Icons.location_city_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'State / Region',
                    controller: _stateCtrl,
                    prefixIcon: Icons.map_outlined,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Country',
                    controller: _countryCtrl,
                    prefixIcon: Icons.flag_outlined,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'common.address'.tr(),
                    controller: _addressCtrl,
                    maxLines: 3,
                    prefixIcon: Icons.home_outlined,
                  ),
                  const SizedBox(height: 32),

                  AppButton(
                    label: 'common.save'.tr(),
                    onPressed: _save,
                    isLoading: updateState.isLoading,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleMedium),
        const SizedBox(height: 4),
        const Divider(height: 1),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;

  const _DropdownField({
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelLarge),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          hint: Text('Select $label'),
          decoration: const InputDecoration(),
          items: items
              .map((e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(e.toString()),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
