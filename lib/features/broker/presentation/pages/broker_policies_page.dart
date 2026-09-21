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
// ║  Broker – Policies List                                  ║
// ╚══════════════════════════════════════════════════════════╝

class BrokerPoliciesPage extends ConsumerStatefulWidget {
  const BrokerPoliciesPage({super.key});

  @override
  ConsumerState<BrokerPoliciesPage> createState() =>
      _BrokerPoliciesPageState();
}

class _BrokerPoliciesPageState extends ConsumerState<BrokerPoliciesPage> {
  String _search = '';
  String _filter = 'ALL';
  static const _filters = ['ALL', 'ACTIVE', 'PENDING', 'EXPIRED', 'CANCELLED'];

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(brokerPoliciesProvider);

    return BrokerSubScaffold(
      title: 'Policies',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => ref.invalidate(brokerPoliciesProvider),
        ),
      ],
      body: Column(
        children: [
          // ── Search + filter ─────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                AppTextField(
                  label: 'Search client, policy title or number…',
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
                              label: Text(f),
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
          // ── List ────────────────────────────────────
          Expanded(
            child: async.when(
              loading: () => const LoadingView(),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (list) {
                final filtered = list.where((p) {
                  final matchStatus = _filter == 'ALL' ||
                      p.status.toUpperCase() == _filter;
                  final q = _search.toLowerCase();
                  final matchSearch = q.isEmpty ||
                      p.customerName.toLowerCase().contains(q) ||
                      p.policyTitle.toLowerCase().contains(q) ||
                      p.insuranceNumber.toLowerCase().contains(q) ||
                      p.policyCode.toLowerCase().contains(q);
                  return matchStatus && matchSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyView(
                      title: 'No policies found',
                      icon: Icons.shield_rounded);
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) =>
                      _PolicyCard(item: filtered[i], index: i),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Policy Card (all payload fields) ─────────────────────

class _PolicyCard extends StatelessWidget {
  final BrokerPolicyModel item;
  final int index;
  const _PolicyCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final statusColor = brokerPolicyStatusColor(item.status);
    final statusBg = brokerPolicyStatusBg(item.status);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      onTap: () => _showDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shield_rounded,
                    size: 20, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.customerName,
                        style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      item.policyTitle,
                      style: AppTextStyles.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${item.policyTypeName}'
                      '${item.policySubTypeName.isNotEmpty ? " › ${item.policySubTypeName}" : ""}',
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusChip.policyStatus(item.status),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // ── Numbers ──────────────────────────────────
          Row(
            children: [
              BrokerInfoPill(
                  icon: Icons.numbers_rounded,
                  label: 'Ins#',
                  value: item.insuranceNumber),
              const SizedBox(width: 12),
              BrokerInfoPill(
                  icon: Icons.code_rounded,
                  label: 'Code',
                  value: item.policyCode),
            ],
          ),
          const SizedBox(height: 6),

          // ── Financials ───────────────────────────────
          Row(
            children: [
              BrokerInfoPill(
                  icon: Icons.payments_rounded,
                  label: 'Premium',
                  value: brokerFmtCurrency(item.premiumAmount)),
              const SizedBox(width: 12),
              BrokerInfoPill(
                  icon: Icons.security_rounded,
                  label: 'Sum Assured',
                  value: brokerFmtCurrency(item.sumAssured)),
            ],
          ),
          const SizedBox(height: 6),

          // ── Dates ────────────────────────────────────
          Row(
            children: [
              BrokerInfoPill(
                  icon: Icons.calendar_today_rounded,
                  label: 'Start',
                  value: item.startDate),
              const SizedBox(width: 12),
              BrokerInfoPill(
                  icon: Icons.event_busy_rounded,
                  label: 'End',
                  value: item.endDate),
            ],
          ),

          // ── Agent + Commission ────────────────────────
          if (item.agentName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_rounded,
                    size: 13, color: AppColors.grey500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Agent: ${item.agentName}  '
                    '(${brokerFmtCurrency(item.agentCommission)})',
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _CommissionChip(status: item.commissionStatus),
              ],
            ),
          ],

          // ── Notes ────────────────────────────────────
          if (item.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Text(
                item.notes,
                style: AppTextStyles.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          // ── Created ──────────────────────────────────
          const SizedBox(height: 6),
          BrokerInfoPill(
              icon: Icons.access_time_rounded,
              label: 'Created',
              value: item.createdAt.split('T').first),
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
      builder: (_) => _PolicyDetailSheet(item: item),
    );
  }
}

// ── Policy Detail Sheet ───────────────────────────────────

class _PolicyDetailSheet extends StatelessWidget {
  final BrokerPolicyModel item;
  const _PolicyDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(item.policyTitle,
                        style: AppTextStyles.titleLarge,
                        overflow: TextOverflow.ellipsis),
                  ),
                  StatusChip.policyStatus(item.status),
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
                    title: 'Policy Identity',
                    icon: Icons.shield_rounded,
                    children: [
                      BrokerDetailRow(label: 'Insurance #', value: item.insuranceNumber),
                      BrokerDetailRow(label: 'Policy Code', value: item.policyCode),
                      BrokerDetailRow(label: 'Policy Title', value: item.policyTitle),
                      BrokerDetailRow(label: 'Type', value: item.policyTypeName),
                      BrokerDetailRow(label: 'Sub-Type', value: item.policySubTypeName),
                      BrokerDetailRow(label: 'Customer ID', value: '${item.customerId}'),
                      BrokerDetailRow(label: 'Customer', value: item.customerName),
                      BrokerDetailRow(label: 'Status', value: item.status,
                          valueColor: brokerPolicyStatusColor(item.status)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BrokerSectionCard(
                    title: 'Financials',
                    icon: Icons.payments_rounded,
                    children: [
                      BrokerDetailRow(label: 'Premium', value: brokerFmtCurrency(item.premiumAmount)),
                      BrokerDetailRow(label: 'Sum Assured', value: brokerFmtCurrency(item.sumAssured)),
                      BrokerDetailRow(label: 'Agent Commission', value: brokerFmtCurrency(item.agentCommission)),
                      BrokerDetailRow(label: 'Commission Status', value: item.commissionStatus),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BrokerSectionCard(
                    title: 'Agent',
                    icon: Icons.person_rounded,
                    children: [
                      BrokerDetailRow(label: 'Agent ID', value: '${item.agentId}'),
                      BrokerDetailRow(label: 'Agent Name', value: item.agentName),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BrokerSectionCard(
                    title: 'Duration',
                    icon: Icons.date_range_rounded,
                    children: [
                      BrokerDetailRow(label: 'Start Date', value: item.startDate),
                      BrokerDetailRow(label: 'End Date', value: item.endDate),
                      BrokerDetailRow(label: 'Created At', value: item.createdAt),
                    ],
                  ),
                  if (item.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    BrokerSectionCard(
                      title: 'Notes',
                      icon: Icons.notes_rounded,
                      children: [
                        Text(item.notes, style: AppTextStyles.bodyMedium),
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

// ── Commission chip ───────────────────────────────────────

class _CommissionChip extends StatelessWidget {
  final String status;
  const _CommissionChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final paid = status.toUpperCase() == 'PAID';
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: paid ? AppColors.successLight : AppColors.warningLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Comm: $status',
        style: AppTextStyles.caption.copyWith(
          color: paid ? AppColors.success : AppColors.warning,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
