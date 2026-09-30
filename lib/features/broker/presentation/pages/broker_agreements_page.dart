import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../data/models/broker_models.dart';
import '../providers/broker_providers.dart';
import '_broker_shared.dart';

// ╔══════════════════════════════════════════════════════════╗
// ║  Broker – Agreements List                                ║
// ╚══════════════════════════════════════════════════════════╝

class BrokerAgreementsPage extends ConsumerWidget {
  const BrokerAgreementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(brokerAgreementsProvider);

    return BrokerSubScaffold(
      title: 'Agreements',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => ref.invalidate(brokerAgreementsProvider),
        ),
      ],
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(
          child: Text(e.toString(),
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
        ),
        data: (list) => list.isEmpty
            ? const EmptyView(
                title: 'No agreements found',
                icon: Icons.handshake_rounded)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, i) => _AgreementCard(
                  item: list[i],
                  index: i,
                ),
              ),
      ),
    );
  }
}

// ── Agreement Card (all fields from payload) ──────────────

class _AgreementCard extends StatelessWidget {
  final BrokerAgreementModel item;
  final int index;
  const _AgreementCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final isActive = item.status.toUpperCase() == 'ACTIVE';

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BrokerAgreementDetailPage(item: item),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.successLight
                      : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.handshake_rounded,
                    size: 20,
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
                    const SizedBox(height: 2),
                    Text(item.brokerName,
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              StatusChip.policyStatus(item.status),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // ── Date row ────────────────────────────────
          Row(
            children: [
              BrokerInfoPill(
                  icon: Icons.calendar_today_rounded,
                  label: 'Effective',
                  value: item.effectiveDate),
              const SizedBox(width: 16),
              BrokerInfoPill(
                  icon: Icons.event_busy_rounded,
                  label: 'Expires',
                  value: item.expiryDate),
            ],
          ),

          const SizedBox(height: 8),

          // ── ID row ───────────────────────────────────
          Row(
            children: [
              BrokerInfoPill(
                  icon: Icons.tag_rounded,
                  label: 'ID',
                  value: '${item.id}'),
              const SizedBox(width: 16),
              BrokerInfoPill(
                  icon: Icons.business_rounded,
                  label: 'Company',
                  value: '${item.companyId}'),
              const SizedBox(width: 16),
              BrokerInfoPill(
                  icon: Icons.person_rounded,
                  label: 'Broker ID',
                  value: '${item.brokerId}'),
            ],
          ),

          // ── Terms preview ────────────────────────────
          if (item.terms.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Text(
                item.terms,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          // ── File download ────────────────────────────
          if (item.filePath.isNotEmpty) ...[
            const SizedBox(height: 10),
            _DownloadButton(filePath: item.filePath),
          ],

          // ── Timestamps ───────────────────────────────
          const SizedBox(height: 10),
          Row(
            children: [
              BrokerInfoPill(
                  icon: Icons.access_time_rounded,
                  label: 'Created',
                  value: item.createdAt.split('T').first),
              const SizedBox(width: 16),
              BrokerInfoPill(
                  icon: Icons.update_rounded,
                  label: 'Updated',
                  value: item.updatedAt.split('T').first),
            ],
          ),

          // ── Tap hint ─────────────────────────────────
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('View details',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.primary)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 11, color: AppColors.primary),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 60 * index))
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }
}

// ╔══════════════════════════════════════════════════════════╗
// ║  Broker – Agreement Detail  (agreements/{id})            ║
// ╚══════════════════════════════════════════════════════════╝

class BrokerAgreementDetailPage extends ConsumerWidget {
  final BrokerAgreementModel item;
  const BrokerAgreementDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── App bar ─────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(item.agreementRef,
                  style: AppTextStyles.titleMedium
                      .copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.darkGradient,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: StatusChip.policyStatus(item.status),
                ),
              ),
            ),
            actions: [
              // Refresh detail from API
              Consumer(
                builder: (context, ref, _) => IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () =>
                      ref.invalidate(brokerAgreementDetailProvider(item.id)),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Identity ──────────────────────────
                  _DetailSection(
                    title: 'Agreement Identity',
                    rows: [
                      _Row('Agreement Ref', item.agreementRef),
                      _Row('ID', '${item.id}'),
                      _Row('Status', item.status),
                      _Row('Company ID', '${item.companyId}'),
                      _Row('Broker ID', '${item.brokerId}'),
                      _Row('Broker Name', item.brokerName),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Validity ──────────────────────────
                  _DetailSection(
                    title: 'Validity Period',
                    rows: [
                      _Row('Effective Date', item.effectiveDate),
                      _Row('Expiry Date', item.expiryDate),
                      _Row('Created', item.createdAt),
                      _Row('Updated', item.updatedAt),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Terms ────────────────────────────
                  if (item.terms.isNotEmpty) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Terms & Conditions',
                              style: AppTextStyles.titleSmall),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          Text(item.terms,
                              style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Document ─────────────────────────
                  if (item.filePath.isNotEmpty) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Document',
                              style: AppTextStyles.titleSmall),
                          const SizedBox(height: 10),
                          const Divider(height: 1),
                          const SizedBox(height: 10),
                          _DownloadButton(
                              filePath: item.filePath, large: true),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets local to agreements ───────────────────

class _DownloadButton extends StatelessWidget {
  final String filePath;
  final bool large;
  const _DownloadButton({required this.filePath, this.large = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final url =
            Uri.parse('${AppConstants.fileBaseUrl}/$filePath');
        if (await canLaunchUrl(url)) launchUrl(url);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: large ? 16 : 12, vertical: large ? 12 : 8),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.download_rounded,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('View / Download Document',
                style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<_Row> rows;
  const _DetailSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleSmall),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: AppTextStyles.bodySmall
                .copyWith(color: AppTextStyles.textSecondaryColor)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.bodySmall
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
