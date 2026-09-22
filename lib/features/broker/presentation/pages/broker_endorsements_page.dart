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
import '../../data/models/broker_models.dart';
import '../providers/broker_providers.dart';
import '_broker_shared.dart';

// ╔══════════════════════════════════════════════════════════╗
// ║  Broker – Endorsements                                   ║
// ╚══════════════════════════════════════════════════════════╝

class BrokerEndorsementsPage extends ConsumerStatefulWidget {
  const BrokerEndorsementsPage({super.key});

  @override
  ConsumerState<BrokerEndorsementsPage> createState() =>
      _BrokerEndorsementsPageState();
}

class _BrokerEndorsementsPageState
    extends ConsumerState<BrokerEndorsementsPage> {
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(brokerEndorsementsProvider);

    return BrokerSubScaffold(
      title: 'Endorsements',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => ref.invalidate(brokerEndorsementsProvider),
        ),
      ],
      fab: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Request'),
        onPressed: () => setState(() => _showForm = true),
      ),
      body: Stack(
        children: [
          async.when(
            loading: () => const LoadingView(),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (list) => list.isEmpty
                ? const EmptyView(
                    title: 'No endorsement requests yet',
                    icon: Icons.edit_document)
                : ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 16, 16, 90),
                    itemCount: list.length,
                    itemBuilder: (context, i) =>
                        _EndorsementCard(item: list[i], index: i),
                  ),
          ),
          if (_showForm)
            _EndorsementFormSheet(
              onClose: () => setState(() => _showForm = false),
              onSubmitted: () {
                setState(() => _showForm = false);
                ref.invalidate(brokerEndorsementsProvider);
              },
            ),
        ],
      ),
    );
  }
}

// ── Endorsement Card (all payload fields) ────────────────

class _EndorsementCard extends StatelessWidget {
  final BrokerEndorsementModel item;
  final int index;
  const _EndorsementCard({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
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
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_document,
                    size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.requestType,
                        style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      'Insurance #${item.insuranceId}',
                      style: AppTextStyles.caption,
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

          // ── IDs ──────────────────────────────────────
          Row(
            children: [
              BrokerInfoPill(
                  icon: Icons.tag_rounded,
                  label: 'ID',
                  value: '${item.id}'),
              const SizedBox(width: 12),
              BrokerInfoPill(
                  icon: Icons.person_rounded,
                  label: 'Broker ID',
                  value: '${item.brokerId}'),
            ],
          ),
          const SizedBox(height: 6),

          // ── Timestamps ───────────────────────────────
          Row(
            children: [
              BrokerInfoPill(
                  icon: Icons.access_time_rounded,
                  label: 'Filed',
                  value: item.createdAt.split('T').first),
              const SizedBox(width: 12),
              BrokerInfoPill(
                  icon: Icons.update_rounded,
                  label: 'Updated',
                  value: item.updatedAt.split('T').first),
            ],
          ),

          // ── Description ───────────────────────────────
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(item.description,
                style: AppTextStyles.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ],

          // ── Admin Notes ──────────────────────────────
          if (item.adminNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.primary),
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

          // ── File ─────────────────────────────────────
          if (item.filePath.isNotEmpty) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () async {
                final url = Uri.parse(
                    '${AppConstants.fileBaseUrl}/${item.filePath}');
                if (await canLaunchUrl(url)) launchUrl(url);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.attach_file_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('View attached file',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 60 * index))
        .slideY(begin: 0.1, curve: Curves.easeOut);
  }
}

// ── Endorsement submission form ───────────────────────────

class _EndorsementFormSheet extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onSubmitted;
  const _EndorsementFormSheet(
      {required this.onClose, required this.onSubmitted});

  @override
  ConsumerState<_EndorsementFormSheet> createState() =>
      _EndorsementFormSheetState();
}

class _EndorsementFormSheetState
    extends ConsumerState<_EndorsementFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _insuranceIdCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _requestType = 'AMENDMENT';
  bool _loading = false;

  static const _types = [
    'AMENDMENT',
    'CANCELLATION',
    'REINSTATEMENT',
    'EXTENSION',
    'OTHER',
  ];

  @override
  void dispose() {
    _insuranceIdCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await submitBrokerEndorsement(
      BrokerEndorsementRequest(
        insuranceId: int.tryParse(_insuranceIdCtrl.text.trim()) ?? 0,
        requestType: _requestType,
        description: _descCtrl.text.trim(),
        filePath: '',
      ),
    );
    setState(() => _loading = false);
    if (ok) widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: AppColors.grey300,
                              borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('New Endorsement Request',
                              style: AppTextStyles.titleLarge),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: widget.onClose,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Insurance ID (from payload: insuranceId)
                      AppTextField(
                        label: 'Insurance ID *',
                        controller: _insuranceIdCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      // Request Type (from payload: requestType)
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _requestType,
                        decoration: InputDecoration(
                          labelText: 'Request Type *',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        items: _types
                            .map((t) => DropdownMenuItem(
                                value: t, child: Text(t)))
                            .toList(),
                        onChanged: (v) => setState(
                            () => _requestType = v ?? _requestType),
                      ),
                      const SizedBox(height: 12),

                      // Description (from payload: description)
                      AppTextField(
                        label: 'Description *',
                        controller: _descCtrl,
                        maxLines: 3,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      AppButton(
                        label: 'Submit Endorsement',
                        isLoading: _loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
