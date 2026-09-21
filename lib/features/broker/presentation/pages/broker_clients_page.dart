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
// ║  Broker – Corporate Clients List                         ║
// ╚══════════════════════════════════════════════════════════╝

class BrokerClientsPage extends ConsumerStatefulWidget {
  const BrokerClientsPage({super.key});

  @override
  ConsumerState<BrokerClientsPage> createState() =>
      _BrokerClientsPageState();
}

class _BrokerClientsPageState extends ConsumerState<BrokerClientsPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(brokerClientsProvider);

    return BrokerSubScaffold(
      title: 'Corporate Clients',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => ref.invalidate(brokerClientsProvider),
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: AppTextField(
              label: 'Search by name or email…',
              prefixIcon: Icons.search_rounded,
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: async.when(
              loading: () => const LoadingView(),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (list) {
                final filtered = list.where((c) {
                  final q = _search.toLowerCase();
                  return q.isEmpty ||
                      c.corporateName.toLowerCase().contains(q) ||
                      c.corporateEmail.toLowerCase().contains(q);
                }).toList();

                if (filtered.isEmpty) {
                  return const EmptyView(
                      title: 'No clients found',
                      icon: Icons.people_alt_rounded);
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) =>
                      _ClientCard(item: filtered[i], index: i),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Client Card (all payload fields) ─────────────────────

class _ClientCard extends StatelessWidget {
  final BrokerClientModel item;
  final int index;
  const _ClientCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      onTap: () => _showDetail(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar ───────────────────────────────────
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: AppColors.primaryGradient),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                item.corporateName.isNotEmpty
                    ? item.corporateName[0].toUpperCase()
                    : '?',
                style: AppTextStyles.titleLarge
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // ── Info ─────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.corporateName,
                          style: AppTextStyles.titleSmall,
                          overflow: TextOverflow.ellipsis),
                    ),
                    StatusChip.policyStatus(item.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.corporateEmail,
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                // ── Corporate + broker IDs ────────────
                Row(
                  children: [
                    BrokerInfoPill(
                        icon: Icons.business_rounded,
                        label: 'Corp ID',
                        value: '${item.corporateId}'),
                    const SizedBox(width: 12),
                    BrokerInfoPill(
                        icon: Icons.person_rounded,
                        label: 'Broker ID',
                        value: '${item.brokerId}'),
                  ],
                ),
                const SizedBox(height: 4),
                // ── Corporate status + link status ────
                Row(
                  children: [
                    BrokerInfoPill(
                        icon: Icons.domain_rounded,
                        label: 'Corp Status',
                        value: item.corporateStatus),
                    const SizedBox(width: 12),
                    BrokerInfoPill(
                        icon: Icons.link_rounded,
                        label: 'Link',
                        value: item.status),
                  ],
                ),
                // ── Notes ────────────────────────────
                if (item.notes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(item.notes,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                // ── Created ───────────────────────────
                const SizedBox(height: 4),
                BrokerInfoPill(
                    icon: Icons.access_time_rounded,
                    label: 'Since',
                    value: item.createdAt.split('T').first),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 60 * index))
        .slideX(begin: 0.05, curve: Curves.easeOut);
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClientDetailSheet(item: item),
    );
  }
}

// ── Client Detail Sheet ───────────────────────────────────

class _ClientDetailSheet extends StatelessWidget {
  final BrokerClientModel item;
  const _ClientDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.92,
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
                children: [
                  Expanded(
                    child: Text(item.corporateName,
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
                    title: 'Corporate Details',
                    icon: Icons.business_rounded,
                    children: [
                      BrokerDetailRow(label: 'Link ID', value: '${item.id}'),
                      BrokerDetailRow(label: 'Broker ID', value: '${item.brokerId}'),
                      BrokerDetailRow(label: 'Corporate ID', value: '${item.corporateId}'),
                      BrokerDetailRow(label: 'Corporate Name', value: item.corporateName),
                      BrokerDetailRow(label: 'Corporate Email', value: item.corporateEmail),
                      BrokerDetailRow(label: 'Corporate Status', value: item.corporateStatus),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BrokerSectionCard(
                    title: 'Link Info',
                    icon: Icons.link_rounded,
                    children: [
                      BrokerDetailRow(label: 'Link Status', value: item.status),
                      BrokerDetailRow(label: 'Created At', value: item.createdAt),
                      if (item.notes.isNotEmpty)
                        BrokerDetailRow(label: 'Notes', value: item.notes),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
