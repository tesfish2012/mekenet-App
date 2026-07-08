import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../providers/documents_provider.dart';
import '../../../policies/presentation/providers/policies_provider.dart';
import '../../data/models/document_model.dart';

class DocumentsPage extends ConsumerWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(allDocumentsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('documents.my_documents'.tr())),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(allDocumentsProvider),
        color: AppColors.primary,
        child: docsAsync.when(
          loading: () => const ShimmerList(itemHeight: 80),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(allDocumentsProvider),
          ),
          data: (docs) => docs.isEmpty
              ? EmptyView(
                  title: 'documents.no_documents'.tr(),
                  subtitle: 'Upload documents for your active policies.',
                  icon: Icons.folder_open_outlined,
                  actionLabel: 'documents.upload_document'.tr(),
                  onAction: () => _showUploadSheet(context, ref),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _DocumentCard(
                    doc: docs[index],
                    index: index,
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadSheet(context, ref),
        icon: const Icon(Icons.upload_rounded),
        label: Text('documents.upload_document'.tr()),
      ),
    );
  }

  void _showUploadSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _UploadSheet(),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final InsuranceDocumentModel doc;
  final int index;

  const _DocumentCard({required this.doc, required this.index});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
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
                    Text(doc.documentType, style: AppTextStyles.bodySmall),
                    if (doc.fileSize != null) ...[
                      Text(' • ', style: AppTextStyles.bodySmall),
                      Text(
                        AppFormatter.formatFileSize(doc.fileSize!),
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
                if (doc.insuranceNumber != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Policy: ${doc.insuranceNumber}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusChip.documentStatus(doc.status),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05);
  }
}

// ── Upload Bottom Sheet ───────────────────────────────────

class _UploadSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends ConsumerState<_UploadSheet> {
  int? _selectedInsuranceId;
  String? _selectedDocType;
  PlatformFile? _selectedFile;

  final List<String> _docTypes = [
    'ID Card',
    'Passport',
    'Medical Report',
    'Income Proof',
    'Bank Statement',
    'Photo',
    'Other',
  ];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null) {
      setState(() => _selectedFile = result.files.single);
    }
  }

  Future<void> _upload() async {
    if (_selectedInsuranceId == null ||
        _selectedDocType == null ||
        _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final success = await ref.read(uploadDocumentProvider.notifier).upload(
          insuranceId: _selectedInsuranceId!,
          documentType: _selectedDocType!,
          filePath: _selectedFile!.path!,
          fileName: _selectedFile!.name,
        );

    if (mounted) {
      Navigator.pop(context);
      ref.invalidate(allDocumentsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Document uploaded!' : 'Upload failed'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final insurancesAsync = ref.watch(myInsurancesProvider);
    final uploadState = ref.watch(uploadDocumentProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('documents.upload_document'.tr(),
                  style: AppTextStyles.headlineSmall),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 16),

          // Insurance selector
          Text('Select Policy', style: AppTextStyles.labelLarge),
          const SizedBox(height: 6),
          insurancesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text('Error loading policies'),
            data: (insurances) => DropdownButtonFormField<int>(
              value: _selectedInsuranceId,
              hint: const Text('Choose policy'),
              decoration: const InputDecoration(),
              items: insurances
                  .map((i) => DropdownMenuItem<int>(
                        value: i.id,
                        child: Text(
                          '${i.policyTitle} (${i.insuranceNumber})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedInsuranceId = v),
            ),
          ),
          const SizedBox(height: 16),

          // Document type
          Text('documents.document_type'.tr(), style: AppTextStyles.labelLarge),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedDocType,
            hint: const Text('Choose document type'),
            decoration: const InputDecoration(),
            items: _docTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _selectedDocType = v),
          ),
          const SizedBox(height: 16),

          // File picker
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
                  style: BorderStyle.solid,
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
                        : Icons.attach_file_rounded,
                    color: _selectedFile != null
                        ? AppColors.success
                        : AppColors.grey400,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedFile?.name ?? 'Tap to select file (PDF, JPG, PNG)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _selectedFile != null ? null : AppColors.lightTextHint,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          AppButton(
            label: 'documents.upload_document'.tr(),
            onPressed: _upload,
            isLoading: uploadState.isLoading,
            leadingIcon: Icons.upload_rounded,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
