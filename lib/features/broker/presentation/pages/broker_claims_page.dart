import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../data/models/broker_models.dart';
import '../providers/broker_providers.dart';
import '_broker_shared.dart';

// ╔══════════════════════════════════════════════════════════╗
// ║  Broker – Claims List                                    ║
// ╚══════════════════════════════════════════════════════════╝

class BrokerClaimsPage extends ConsumerStatefulWidget {
  const BrokerClaimsPage({super.key});

  @override
  ConsumerState<BrokerClaimsPage> createState() =>
      _BrokerClaimsPageState();
}

class _BrokerClaimsPageState extends ConsumerState<BrokerClaimsPage> {
  String _search = '';
  String _filter = 'ALL';
  static const _filters = [
    'ALL',
    'SUBMITTED',
    'UNDER_REVIEW',
    'APPROVED',
    'REJECTED',
    'PAID',
  ];

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(brokerClaimsProvider);

    return BrokerSubScaffold(
      title: 'Claims',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => ref.invalidate(brokerClaimsProvider),
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                AppTextField(
                  label: 'Search claimant, claim # or insurance #…',
                  prefixIcon: Icons.search_rounded,
                  onChanged: (v) => setState(() => _search = v),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(f.replaceAll('_', ' ')),
                              selected: _filter == f,
                              onSelected: (_) =>
                                  setState(() => _filter = f),
                              selectedColor: AppColors.primaryContainer,
                              labelStyle:
                                  AppTextStyles.labelSmall.copyWith(
                                color: _filter == f
                                    ? AppColors.primary
                                    : null,
                                fontWeight: _filter == f
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: async.when(
              loading: () => const LoadingView(),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (list) {
                final filtered = list.where((c) {
                  final matchStatus = _filter == 'ALL' ||
                      c.status.toUpperCase() == _filter;
                  final q = _search.toLowerCase();
                  final matchSearch = q.isEmpty ||
                      c.claimantName.toLowerCase().contains(q) ||
                      c.claimNumber.toLowerCase().contains(q) ||
                      c.insuranceNumber.toLowerCase().contains(q);
                  return matchStatus && matchSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyView(
                      title: 'No claims found',
                      icon: Icons.assignment_rounded);
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) =>
                      _ClaimCard(item: filtered[i], index: i),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Claim Card (all payload fields) ──────────────────────

class _ClaimCard extends StatelessWidget {
  final BrokerClaimModel item;
  final int index;
  const _ClaimCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final sColor = brokerClaimStatusColor(item.status);
    final sBg = brokerClaimStatusBg(item.status);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      onTap: () => _showDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: sBg,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.assignment_rounded,
                    size: 20, color: sColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.claimantName,
                        style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      '${item.claimNumber}  •  ${item.insuranceNumber}',
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusChip.claimStatus(item.status),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // ── Amounts ──────────────────────────────────
          Row(
            children: [
              BrokerInfoPill(
                  icon: Icons.monetization_on_rounded,
                  label: 'Claimed',
                  value: brokerFmtCurrency(item.claimAmount)),
              const SizedBox(width: 12),
              BrokerInfoPill(
                  icon: Icons.check_circle_rounded,
                  label: 'Approved',
                  value: brokerFmtCurrency(item.approvedAmount)),
            ],
          ),
          const SizedBox(height: 6),

          // ── Dates ────────────────────────────────────
          Row(
            children: [
              BrokerInfoPill(
                  icon: Icons.today_rounded,
                  label: 'Incident',
                  value: item.incidentDate),
              const SizedBox(width: 12),
              BrokerInfoPill(
                  icon: Icons.date_range_rounded,
                  label: 'Filed',
                  value: item.claimDate),
            ],
          ),
          const SizedBox(height: 6),

          // ── Reserve + Severity ────────────────────────
          Row(
            children: [
              BrokerInfoPill(
                  icon: Icons.savings_rounded,
                  label: 'Reserve',
                  value: brokerFmtCurrency(item.currentReserve)),
              const SizedBox(width: 12),
              if (item.severity.isNotEmpty)
                BrokerInfoPill(
                    icon: Icons.warning_amber_rounded,
                    label: 'Severity',
                    value: item.severity),
            ],
          ),

          // ── Assigned to ───────────────────────────────
          if (item.assignedToName.isNotEmpty) ...[
            const SizedBox(height: 6),
            BrokerInfoPill(
                icon: Icons.manage_accounts_rounded,
                label: 'Assigned',
                value: item.assignedToName),
          ],

          // ── Reason ───────────────────────────────────
          if (item.reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(item.reason,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],

          // ── Admin Notes ──────────────────────────────
          if (item.adminNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 13, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Admin: ${item.adminNotes}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 50 * index))
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClaimDetailSheet(item: item),
    );
  }
}

// ── Claim Detail Sheet ────────────────────────────────────

class _ClaimDetailSheet extends StatelessWidget {
  final BrokerClaimModel item;
  const _ClaimDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(item.claimNumber,
                        style: AppTextStyles.titleLarge,
                        overflow: TextOverflow.ellipsis),
                  ),
                  StatusChip.claimStatus(item.status),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                children: [
                  BrokerSectionCard(
                    title: 'Claim Identity',
                    icon: Icons.assignment_rounded,
                    children: [
                      BrokerDetailRow(label: 'Claim #', value: item.claimNumber),
                      BrokerDetailRow(label: 'Insurance ID', value: '${item.insuranceId}'),
                      BrokerDetailRow(label: 'Insurance #', value: item.insuranceNumber),
                      BrokerDetailRow(label: 'Claimant ID', value: '${item.claimantId}'),
                      BrokerDetailRow(label: 'Claimant', value: item.claimantName),
                      BrokerDetailRow(label: 'Status', value: item.status,
                          valueColor: brokerClaimStatusColor(item.status)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BrokerSectionCard(
                    title: 'Financials',
                    icon: Icons.monetization_on_rounded,
                    children: [
                      BrokerDetailRow(label: 'Claim Amount', value: brokerFmtCurrency(item.claimAmount)),
                      BrokerDetailRow(label: 'Approved Amount', value: brokerFmtCurrency(item.approvedAmount)),
                      BrokerDetailRow(label: 'Current Reserve', value: brokerFmtCurrency(item.currentReserve)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BrokerSectionCard(
                    title: 'Incident & Filing',
                    icon: Icons.date_range_rounded,
                    children: [
                      BrokerDetailRow(label: 'Incident Date', value: item.incidentDate),
                      BrokerDetailRow(label: 'Claim Date', value: item.claimDate),
                      BrokerDetailRow(label: 'Created At', value: item.createdAt),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BrokerSectionCard(
                    title: 'Triage & Assignment',
                    icon: Icons.manage_accounts_rounded,
                    children: [
                      BrokerDetailRow(label: 'Severity', value: item.severity),
                      BrokerDetailRow(label: 'Triage Notes', value: item.triageNotes),
                      BrokerDetailRow(label: 'Assigned To ID', value: '${item.assignedToId}'),
                      BrokerDetailRow(label: 'Assigned To', value: item.assignedToName),
                    ],
                  ),
                  if (item.reason.isNotEmpty || item.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    BrokerSectionCard(
                      title: 'Details',
                      icon: Icons.notes_rounded,
                      children: [
                        if (item.reason.isNotEmpty)
                          BrokerDetailRow(label: 'Reason', value: item.reason),
                        if (item.description.isNotEmpty)
                          BrokerDetailRow(label: 'Description', value: item.description),
                      ],
                    ),
                  ],
                  if (item.adminNotes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    BrokerSectionCard(
                      title: 'Admin Notes',
                      icon: Icons.admin_panel_settings_rounded,
                      children: [
                        Text(item.adminNotes, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
