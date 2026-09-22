import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../providers/claims_provider.dart';

import 'package:file_picker/file_picker.dart';
import '../../data/models/claim_model.dart';

class ClaimDetailPage extends ConsumerWidget {
  final int claimId;
  const ClaimDetailPage({super.key, required this.claimId});

  void _showClaimUploadSheet(BuildContext context, WidgetRef ref, int claimId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ClaimUploadSheet(claimId: claimId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claimAsync = ref.watch(claimByIdProvider(claimId));
    final docsAsync = ref.watch(claimDocumentsProvider(claimId));

    return Scaffold(
      appBar: AppBar(title: Text('claims.claim_details'.tr())),
      body: claimAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (claim) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AppCard(
                gradient: AppColors.cardGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assignment_rounded, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            claim.claimNumber,
                            style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StatusChip.claimStatus(claim.status),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Claim Info
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Claim Information', style: AppTextStyles.titleMedium),
                    const Divider(height: 20),
                    _Row(label: 'claims.claim_amount'.tr(),
                        value: AppFormatter.formatCurrency(claim.claimAmount)),
                    if (claim.approvedAmount != null)
                      _Row(label: 'claims.approved_amount'.tr(),
                          value: AppFormatter.formatCurrency(claim.approvedAmount!)),
                    _Row(label: 'claims.incident_date'.tr(),
                        value: AppFormatter.formatDate(AppFormatter.parseDate(claim.incidentDate))),
                    _Row(label: 'claims.claim_date'.tr(),
                        value: AppFormatter.formatDate(AppFormatter.parseDate(claim.claimDate))),
                    if (claim.policyTitle != null)
                      _Row(label: 'Policy', value: claim.policyTitle!),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Description
              if (claim.description != null) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('claims.description'.tr(), style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      Text(claim.description!, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Admin Notes
              if (claim.adminNotes != null && claim.adminNotes!.isNotEmpty) ...[
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin Notes', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      Text(claim.adminNotes!, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Attached Documents List
              docsAsync.whenData((docs) {
                if (docs.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attached Documents (${docs.length})',
                        style: AppTextStyles.titleMedium),
                    const SizedBox(height: 10),
                    ...docs.map(
                      (doc) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.description_rounded,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc.originalName ?? doc.documentType,
                                    style: AppTextStyles.titleSmall,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        doc.documentType,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.grey500,
                                        ),
                                      ),
                                      if (doc.fileSize != null) ...[
                                        Text(' • ', style: AppTextStyles.bodySmall),
                                        Text(
                                          AppFormatter.formatFileSize(doc.fileSize!),
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.grey500,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            StatusChip.documentStatus(doc.status),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).value ?? const SizedBox.shrink(),

              // Upload documents button
              AppButton(
                label: 'claims.upload_documents'.tr(),
                onPressed: () => _showClaimUploadSheet(context, ref, claim.id),
                variant: AppButtonVariant.primary,
                leadingIcon: Icons.upload_file_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: AppTextStyles.bodyMedium),
          ),
          Expanded(child: Text(value, style: AppTextStyles.titleSmall)),
        ],
      ),
    );
  }
}

// ── Claim Upload Bottom Sheet ──────────────────────────────

class _ClaimUploadSheet extends ConsumerStatefulWidget {
  final int claimId;

  const _ClaimUploadSheet({required this.claimId});

  @override
  ConsumerState<_ClaimUploadSheet> createState() => _ClaimUploadSheetState();
}

class _ClaimUploadSheetState extends ConsumerState<_ClaimUploadSheet> {
  String? _selectedDocType;
  PlatformFile? _selectedFile;

  final List<String> _docTypes = [
    'Damage Photos',
    'Police Report',
    'Medical Report',
    'Repair Estimate',
    'Driver License',
    'Receipt / Invoice',
    'Other Supporting Document',
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _selectedFile = result.files.single);
    }
  }

  Future<void> _upload() async {
    if (_selectedDocType == null || _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select document type and a file')),
      );
      return;
    }
    if (_selectedFile!.bytes == null && _selectedFile!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('File data could not be read. Please choose another file.')),
      );
      return;
    }

    final success = await ref.read(uploadClaimDocumentProvider.notifier).upload(
          claimId: widget.claimId,
          documentType: _selectedDocType!,
          filePath: _selectedFile!.path,
          fileBytes: _selectedFile!.bytes,
          fileName: _selectedFile!.name,
        );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload document. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(uploadClaimDocumentProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upload Claim Document', style: AppTextStyles.titleLarge),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 24),

          // Document Type Dropdown
          Text('Document Type', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedDocType,
            hint: const Text('Select document type'),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
            ),
            items: _docTypes
                .map((t) => DropdownMenuItem(
                      value: t,
                      child:
                          Text(t, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedDocType = v),
          ),
          const SizedBox(height: 16),

          // File Picker Button
          Text('Select Document / Photo', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedFile != null
                      ? AppColors.success
                      : AppColors.lightBorder,
                ),
                borderRadius: BorderRadius.circular(12),
                color: _selectedFile != null
                    ? AppColors.successLight
                    : AppColors.grey50,
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedFile != null
                        ? Icons.check_circle_rounded
                        : Icons.upload_file_rounded,
                    color: _selectedFile != null
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFile?.name ??
                              'Tap to browse files (PDF, JPG, PNG)',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _selectedFile != null
                                ? AppColors.lightTextPrimary
                                : AppColors.lightTextHint,
                            fontWeight: _selectedFile != null
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_selectedFile?.size != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            AppFormatter.formatFileSize(_selectedFile!.size),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.grey500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _pickFile,
                    child: Text(_selectedFile != null ? 'Change' : 'Browse'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Upload Button
          AppButton(
            label: 'Upload Document',
            onPressed: _upload,
            isLoading: uploadState.isLoading,
            leadingIcon: Icons.cloud_upload_rounded,
          ),
        ],
      ),
    );
  }
}

