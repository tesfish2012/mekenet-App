import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../data/models/broker_models.dart';
import '../providers/broker_providers.dart';
import '_broker_shared.dart';

// ╔══════════════════════════════════════════════════════════╗
// ║  Broker – Profile (6 tabs)                               ║
// ╚══════════════════════════════════════════════════════════╝

class BrokerProfilePage extends ConsumerStatefulWidget {
  const BrokerProfilePage({super.key});

  @override
  ConsumerState<BrokerProfilePage> createState() =>
      _BrokerProfilePageState();
}

class _BrokerProfilePageState extends ConsumerState<BrokerProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(brokerProfileProvider);
    final prefsAsync = ref.watch(brokerNotificationPrefsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _ProfileHero(profileAsync: profileAsync),
            ),
            bottom: TabBar(
              controller: _tabs,
              indicatorColor: AppColors.accent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Banking'),
                Tab(text: 'Agreements'),
                Tab(text: 'Documents'),
                Tab(text: 'KYC'),
                Tab(text: 'Notifications'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            // ── Details tab ─────────────────────────────
            profileAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (p) => p == null
                  ? const EmptyView(
                      title: 'Profile not found',
                      icon: Icons.person_off_rounded)
                  : _DetailsTab(profile: p),
            ),
            // ── Banking tab ─────────────────────────────
            profileAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (p) => p == null
                  ? const EmptyView(
                      title: 'No banking info',
                      icon: Icons.account_balance_rounded)
                  : _BankingTab(profile: p),
            ),
            // ── Agreements tab ───────────────────────────
            Consumer(
              builder: (context, ref, _) {
                final async = ref.watch(brokerAgreementsProvider);
                return async.when(
                  loading: () => const LoadingView(),
                  error: (e, _) => Center(child: Text(e.toString())),
                  data: (list) => list.isEmpty
                      ? const EmptyView(
                          title: 'No agreements',
                          icon: Icons.handshake_rounded)
                      : _AgreementsTab(agreements: list),
                );
              },
            ),
            // ── Documents tab ────────────────────────────
            Consumer(
              builder: (context, ref, _) {
                final async = ref.watch(brokerDocumentsProvider);
                return async.when(
                  loading: () => const LoadingView(),
                  error: (e, _) => Center(child: Text(e.toString())),
                  data: (list) => list.isEmpty
                      ? const EmptyView(
                          title: 'No documents',
                          icon: Icons.folder_open_rounded)
                      : _DocumentsTab(documents: list),
                );
              },
            ),
            // ── KYC tab ──────────────────────────────────
            profileAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (p) => _KycTab(profile: p),
            ),
            // ── Notifications tab ───────────────────────
            prefsAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (prefs) =>
                  _NotificationsTab(initialPrefs: prefs),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Hero ──────────────────────────────────────────

class _ProfileHero extends StatelessWidget {
  final AsyncValue<BrokerProfileModel?> profileAsync;
  const _ProfileHero({required this.profileAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.darkGradient,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 52,
        20,
        52,
      ),
      child: profileAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
        data: (p) {
          if (p == null) return const SizedBox.shrink();
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.accent, width: 2),
                ),
                child: Center(
                  child: Text(
                    p.companyName.isNotEmpty
                        ? p.companyName[0].toUpperCase()
                        : 'B',
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.companyName,
                        style: AppTextStyles.titleLarge
                            .copyWith(color: Colors.white),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(p.userEmail,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white70),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(p.brokerCode,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.accentLight)),
                  ],
                ),
              ),
              StatusChip.policyStatus(p.status),
            ],
          );
        },
      ),
    );
  }
}

// ╔══════════════════════════════════════════════════════════╗
// ║  TAB 1 – Details                                         ║
// ╚══════════════════════════════════════════════════════════╝

class _DetailsTab extends ConsumerStatefulWidget {
  final BrokerProfileModel profile;
  const _DetailsTab({required this.profile});

  @override
  ConsumerState<_DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends ConsumerState<_DetailsTab> {
  bool _editing = false;
  bool _saving = false;

  late final Map<String, TextEditingController> _ctrl;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _ctrl = {
      'phone': TextEditingController(text: p.phone),
      'website': TextEditingController(text: p.website),
      'address': TextEditingController(text: p.address),
      'city': TextEditingController(text: p.city),
      'state': TextEditingController(text: p.state),
      'country': TextEditingController(text: p.country),
      'zipCode': TextEditingController(text: p.zipCode),
    };
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final payload = widget.profile.toUpdateJson()
      ..addAll({
        for (final e in _ctrl.entries) e.key: e.value.text.trim(),
      });
    final ok = await updateBrokerProfile(payload);
    setState(() => _saving = false);
    if (ok) {
      ref.invalidate(brokerProfileProvider);
      setState(() => _editing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Account info (read-only) ─────────────────
        BrokerSectionCard(
          title: 'Account',
          icon: Icons.account_circle_rounded,
          children: [
            BrokerDetailRow(label: 'User ID', value: '${p.userId}'),
            BrokerDetailRow(label: 'Name', value: p.userName),
            BrokerDetailRow(label: 'Email', value: p.userEmail),
          ],
        ),
        const SizedBox(height: 14),

        // ── Broker identity (read-only) ──────────────
        BrokerSectionCard(
          title: 'Broker Identity',
          icon: Icons.badge_rounded,
          children: [
            BrokerDetailRow(label: 'ID', value: '${p.id}'),
            BrokerDetailRow(label: 'Company ID', value: '${p.companyId}'),
            BrokerDetailRow(label: 'Broker Code', value: p.brokerCode),
            BrokerDetailRow(label: 'License No.', value: p.licenseNumber),
            BrokerDetailRow(label: 'License Expiry', value: p.licenseExpiry),
            BrokerDetailRow(label: 'Company Name', value: p.companyName),
            BrokerDetailRow(label: 'Tax Number', value: p.taxNumber),
            BrokerDetailRow(
                label: 'Commission',
                value: '${p.commissionPercent}% (${p.commissionType})'),
          ],
        ),
        const SizedBox(height: 14),

        // ── Contact (editable) ───────────────────────
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.contacts_rounded,
                            size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Text('Contact & Address',
                          style: AppTextStyles.titleSmall),
                    ],
                  ),
                  TextButton(
                    onPressed: () =>
                        setState(() => _editing = !_editing),
                    child: Text(_editing ? 'Cancel' : 'Edit',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
              const SizedBox(height: 10),
              if (_editing) ...[
                ..._ctrl.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppTextField(
                      label: _fieldLabel(e.key),
                      controller: e.value,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AppButton(
                  label: 'Save Changes',
                  isLoading: _saving,
                  onPressed: _save,
                ),
              ] else ...[
                BrokerDetailRow(label: 'Phone', value: p.phone),
                BrokerDetailRow(label: 'Website', value: p.website),
                BrokerDetailRow(label: 'Address', value: p.address),
                BrokerDetailRow(label: 'City', value: p.city),
                BrokerDetailRow(label: 'State', value: p.state),
                BrokerDetailRow(label: 'Country', value: p.country),
                BrokerDetailRow(label: 'Zip Code', value: p.zipCode),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── KYC document ────────────────────────────
        BrokerSectionCard(
          title: 'KYC / License Document',
          icon: Icons.verified_user_rounded,
          children: [
            if (p.kycDocumentPath.isNotEmpty) ...[
              BrokerDetailRow(
                  label: 'File', value: p.kycDocumentPath),
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  final url = Uri.parse(
                      '${AppConstants.fileBaseUrl}/${p.kycDocumentPath}');
                  if (await canLaunchUrl(url)) launchUrl(url);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.open_in_new_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('View KYC Document',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Text('No KYC document uploaded',
                  style: AppTextStyles.bodySmall
                    .copyWith(color: AppTextStyles.textSecondaryColor)),
            ],
          ],
        ),
        const SizedBox(height: 14),

        // ── Status / Rejection ───────────────────────
        BrokerSectionCard(
          title: 'Status',
          icon: Icons.info_outline_rounded,
          children: [
            BrokerDetailRow(label: 'Status', value: p.status,
                valueColor: p.status.toUpperCase() == 'ACTIVE'
                    ? AppColors.success
                    : AppColors.warning),
            BrokerDetailRow(label: 'Notes', value: p.notes),
            BrokerDetailRow(
                label: 'Created', value: p.createdAt.split('T').first),
            BrokerDetailRow(
                label: 'Updated', value: p.updatedAt.split('T').first),
          ],
        ),

        if (p.rejectionReason.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rejection Reason: ${p.rejectionReason}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        ],

        // ── Logout ──────────────────────────────────
        const SizedBox(height: 24),
        AppButton(
          label: 'Logout',
          variant: AppButtonVariant.danger,
          leadingIcon: Icons.logout_rounded,
          onPressed: () => _confirmLogout(context),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(authNotifierProvider.notifier).logout();
    }
  }

  String _fieldLabel(String key) => switch (key) {
        'phone' => 'Phone',
        'website' => 'Website',
        'address' => 'Address',
        'city' => 'City',
        'state' => 'State',
        'country' => 'Country',
        'zipCode' => 'Zip Code',
        _ => key,
      };
}

// ╔══════════════════════════════════════════════════════════╗
// ║  TAB 2 – Banking                                         ║
// ╚══════════════════════════════════════════════════════════╝

class _BankingTab extends StatelessWidget {
  final BrokerProfileModel profile;
  const _BankingTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final p = profile;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BrokerSectionCard(
          title: 'Bank Details',
          icon: Icons.account_balance_rounded,
          children: [
            BrokerDetailRow(label: 'Bank Name', value: p.bankName),
            BrokerDetailRow(label: 'Account No.', value: p.bankAccount),
            BrokerDetailRow(label: 'IBAN', value: p.bankIban),
            BrokerDetailRow(label: 'SWIFT / BIC', value: p.bankSwift),
          ],
        ),
        const SizedBox(height: 16),
        // Commission summary
        BrokerSectionCard(
          title: 'Commission',
          icon: Icons.account_balance_wallet_rounded,
          children: [
            BrokerDetailRow(
                label: 'Rate',
                value: '${p.commissionPercent}%'),
            BrokerDetailRow(label: 'Type', value: p.commissionType),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'To update banking information, contact the insurance company directly.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ╔══════════════════════════════════════════════════════════╗
// ║  TAB 3 – Notification Preferences                        ║
// ╚══════════════════════════════════════════════════════════╝

class _NotificationsTab extends ConsumerStatefulWidget {
  final BrokerNotificationPrefsModel initialPrefs;
  const _NotificationsTab({required this.initialPrefs});

  @override
  ConsumerState<_NotificationsTab> createState() =>
      _NotificationsTabState();
}

class _NotificationsTabState extends ConsumerState<_NotificationsTab> {
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(brokerNotifPrefsNotifierProvider.notifier)
          .setFromApi(widget.initialPrefs);
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await ref
        .read(brokerNotifPrefsNotifierProvider.notifier)
        .save();
    setState(() => _saving = false);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Notification preferences saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(brokerNotifPrefsNotifierProvider);
    final notifier =
        ref.read(brokerNotifPrefsNotifierProvider.notifier);

    final emailPrefs = <Map<String, String>>[
      {'key': 'emailOnCommissionPaid', 'label': 'Commission Paid'},
      {'key': 'emailOnClaimUpdate', 'label': 'Claim Update'},
      {'key': 'emailOnEndorsementUpdate', 'label': 'Endorsement Update'},
      {'key': 'emailOnPolicyRenewal', 'label': 'Policy Renewal'},
    ];
    final pushPrefs = <Map<String, String>>[
      {'key': 'pushOnCommissionPaid', 'label': 'Commission Paid'},
      {'key': 'pushOnClaimUpdate', 'label': 'Claim Update'},
      {'key': 'pushOnEndorsementUpdate', 'label': 'Endorsement Update'},
      {'key': 'pushOnPolicyRenewal', 'label': 'Policy Renewal'},
    ];

    bool prefVal(String key) => switch (key) {
          'emailOnCommissionPaid' => prefs.emailOnCommissionPaid,
          'emailOnClaimUpdate' => prefs.emailOnClaimUpdate,
          'emailOnEndorsementUpdate' => prefs.emailOnEndorsementUpdate,
          'emailOnPolicyRenewal' => prefs.emailOnPolicyRenewal,
          'pushOnCommissionPaid' => prefs.pushOnCommissionPaid,
          'pushOnClaimUpdate' => prefs.pushOnClaimUpdate,
          'pushOnEndorsementUpdate' => prefs.pushOnEndorsementUpdate,
          'pushOnPolicyRenewal' => prefs.pushOnPolicyRenewal,
          _ => false,
        };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Email prefs ──────────────────────────────
        BrokerSectionCard(
          title: 'Email Notifications',
          icon: Icons.email_rounded,
          children: emailPrefs
              .map(
                (e) => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e['label']!, style: AppTextStyles.bodyMedium),
                  value: prefVal(e['key']!),
                  activeColor: AppColors.primary,
                  onChanged: (v) => notifier.toggle(e['key']!, v),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 14),

        // ── Push prefs ───────────────────────────────
        BrokerSectionCard(
          title: 'Push Notifications',
          icon: Icons.notifications_rounded,
          children: pushPrefs
              .map(
                (e) => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e['label']!, style: AppTextStyles.bodyMedium),
                  value: prefVal(e['key']!),
                  activeColor: AppColors.primary,
                  onChanged: (v) => notifier.toggle(e['key']!, v),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),

        AppButton(
          label: 'Save Preferences',
          isLoading: _saving,
          onPressed: _save,
        ),
      ],
    );
  }
}

// ╔══════════════════════════════════════════════════════════╗
// ║  TAB 4 – Agreements                                      ║
// ╚══════════════════════════════════════════════════════════╝

class _AgreementsTab extends StatelessWidget {
  final List<BrokerAgreementModel> agreements;
  const _AgreementsTab({required this.agreements});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agreements.length,
      itemBuilder: (context, i) {
        final item = agreements[i];
        final isActive = item.status.toUpperCase() == 'ACTIVE';
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.successLight
                          : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.handshake_rounded,
                        size: 18,
                        color: isActive
                            ? AppColors.success
                            : AppColors.warning),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.agreementRef,
                            style: AppTextStyles.titleSmall,
                            overflow: TextOverflow.ellipsis),
                        Text(item.brokerName,
                            style: AppTextStyles.caption,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  StatusChip.policyStatus(item.status),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Row(
                children: [
                  BrokerInfoPill(
                      icon: Icons.calendar_today_rounded,
                      label: 'Effective',
                      value: item.effectiveDate),
                  const SizedBox(width: 12),
                  BrokerInfoPill(
                      icon: Icons.event_busy_rounded,
                      label: 'Expires',
                      value: item.expiryDate),
                ],
              ),
              if (item.terms.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(item.terms,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
              if (item.filePath.isNotEmpty) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final url = Uri.parse(
                        '${AppConstants.fileBaseUrl}/${item.filePath}');
                    if (await canLaunchUrl(url)) launchUrl(url);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.download_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('View Document',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 60 * i));
      },
    );
  }
}

// ╔══════════════════════════════════════════════════════════╗
// ║  TAB 5 – Documents                                       ║
// ╚══════════════════════════════════════════════════════════╝

class _DocumentsTab extends StatelessWidget {
  final List<BrokerDocumentModel> documents;
  const _DocumentsTab({required this.documents});

  IconData _icon(String type) => switch (type.toUpperCase()) {
        'AGREEMENT' => Icons.handshake_rounded,
        'ENDORSEMENT' => Icons.edit_document,
        'KYC' => Icons.badge_rounded,
        'LICENSE' => Icons.card_membership_rounded,
        'POLICY' => Icons.shield_rounded,
        _ => Icons.description_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, i) {
        final item = documents[i];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          onTap: item.filePath.isEmpty
              ? null
              : () async {
                  final url = Uri.parse(
                      '${AppConstants.fileBaseUrl}/${item.filePath}');
                  if (await canLaunchUrl(url)) launchUrl(url);
                },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon(item.type),
                    size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.type,
                        style: AppTextStyles.titleSmall,
                        overflow: TextOverflow.ellipsis),
                    if (item.reference.isNotEmpty)
                      Text('Ref: ${item.reference}',
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis),
                    Text(item.createdAt.split('T').first,
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  StatusChip.documentStatus(item.status),
                  if (item.filePath.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    const Icon(Icons.open_in_new_rounded,
                        size: 13, color: AppColors.primary),
                  ],
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 60 * i));
      },
    );
  }
}

// ╔══════════════════════════════════════════════════════════╗
// ║  TAB 6 – KYC                                             ║
// ╚══════════════════════════════════════════════════════════╝

class _KycTab extends ConsumerStatefulWidget {
  final BrokerProfileModel? profile;
  const _KycTab({required this.profile});

  @override
  ConsumerState<_KycTab> createState() => _KycTabState();
}

class _KycTabState extends ConsumerState<_KycTab> {
  bool _uploading = false;
  String? _successMsg;
  String? _errorMsg;

  Future<void> _upload() async {
    // File picker would be used here in a real app.
    // For now show the current KYC path and an upload CTA.
    setState(() {
      _uploading = false;
      _successMsg = null;
      _errorMsg = 'File picker not configured in this environment.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── KYC Status card ──────────────────────────
        BrokerSectionCard(
          title: 'KYC / License Document',
          icon: Icons.verified_user_rounded,
          children: [
            BrokerDetailRow(
                label: 'Broker Status', value: p?.status ?? '—',
                valueColor: (p?.status ?? '').toUpperCase() == 'ACTIVE'
                    ? AppColors.success
                    : AppColors.warning),
            BrokerDetailRow(
                label: 'License No.', value: p?.licenseNumber ?? '—'),
            BrokerDetailRow(
                label: 'License Expiry', value: p?.licenseExpiry ?? '—'),
          ],
        ),
        const SizedBox(height: 16),

        // ── Current KYC file ─────────────────────────
        BrokerSectionCard(
          title: 'Current KYC File',
          icon: Icons.badge_rounded,
          children: [
            if (p != null && p.kycDocumentPath.isNotEmpty) ...[
              BrokerDetailRow(label: 'File Path', value: p.kycDocumentPath),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final url = Uri.parse(
                      '${AppConstants.fileBaseUrl}/${p.kycDocumentPath}');
                  if (await canLaunchUrl(url)) launchUrl(url);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.open_in_new_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('View Current KYC Document',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('No KYC document uploaded yet.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.warning)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // ── Upload new KYC ───────────────────────────
        BrokerSectionCard(
          title: 'Upload / Replace KYC',
          icon: Icons.upload_file_rounded,
          children: [
            Text(
              'Upload a new KYC or license document to replace the current one. '
              'Accepted formats: PDF, PNG, JPG.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 14),
            if (_successMsg != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_successMsg!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.success)),
              ),
            if (_errorMsg != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_errorMsg!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error)),
              ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Choose & Upload File',
              isLoading: _uploading,
              leadingIcon: Icons.upload_rounded,
              onPressed: _upload,
            ),
          ],
        ),

        if (p != null && p.rejectionReason.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rejection Reason: ${p.rejectionReason}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
