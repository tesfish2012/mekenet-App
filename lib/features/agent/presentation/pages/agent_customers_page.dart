import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/connectivity_banner.dart';
import '../../../../shared/widgets/loading_view.dart';

/// Agent-scoped customer management. The backend limits records to customers
/// assigned to the authenticated agent.
class AgentCustomersPage extends ConsumerStatefulWidget {
  const AgentCustomersPage({super.key});

  @override
  ConsumerState<AgentCustomersPage> createState() => _AgentCustomersPageState();
}

class _AgentCustomersPageState extends ConsumerState<AgentCustomersPage> {
  late Future<List<Map<String, dynamic>>> _customersFuture;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _customersFuture = _loadCustomers();
  }

  Future<List<Map<String, dynamic>>> _loadCustomers() async {
    final response = await getIt<Dio>().get(ApiEndpoints.agentCustomers);
    final dynamic body = response.data;
    dynamic payload = body;
    if (body is Map<String, dynamic>) {
      payload = body['data'] ?? body['content'] ?? body;
      if (payload is Map<String, dynamic>) {
        payload = payload['content'] ?? payload['items'] ?? payload['customers'] ?? [];
      }
    }
    if (payload is! List) return <Map<String, dynamic>>[];
    return payload.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> _refresh() async {
    setState(() => _customersFuture = _loadCustomers());
    await _customersFuture;
  }

  String _firstValue(Map<String, dynamic> item, List<String> keys, {String fallback = ''}) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    }
    return fallback;
  }

  String _customerName(Map<String, dynamic> item) {
    final combined = _firstValue(item, ['fullName', 'name', 'customerName', 'displayName']);
    if (combined.isNotEmpty) return combined;
    final first = _firstValue(item, ['firstName', 'firstname']);
    final last = _firstValue(item, ['lastName', 'lastname']);
    final joined = '$first $last'.trim();
    return joined.isEmpty ? 'Customer' : joined;
  }

  void _showCustomerDetails(Map<String, dynamic> customer) {
    final id = int.tryParse(_firstValue(customer, ['id', 'customerId']));
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer ID is missing.')),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, controller) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: FutureBuilder<Response<dynamic>>(
            future: getIt<Dio>().get(ApiEndpoints.agentCustomerDetail(id)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingView());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Unable to load customer details.'),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final responseData = snapshot.data?.data;
              final dynamic payload = responseData is Map
                  ? (responseData['data'] ?? responseData)
                  : responseData;
              final details = payload is Map
                  ? Map<String, dynamic>.from(payload)
                  : customer;
              final insurances = details['insurances'] ?? details['insuranceContracts'] ?? details['policies'];
              final entries = details.entries.where((entry) =>
                  entry.value != null &&
                  entry.value is! Map &&
                  entry.value is! List &&
                  !{'password', 'token'}.contains(entry.key.toLowerCase())).toList();

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.grey400, borderRadius: BorderRadius.circular(4)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_customerName(details),
                            style: AppTextStyles.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      children: [
                        Text('Customer profile', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 8),
                        ...entries.map((entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  entry.key.replaceAllMapped(
                                    RegExp(r'([A-Z])'),
                                    (match) => ' ${match.group(1)}',
                                  ).replaceAll('_', ' '),
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(entry.value.toString(), style: AppTextStyles.bodyMedium),
                              ),
                            ],
                          ),
                        )),
                        if (insurances is List) ...[
                          const SizedBox(height: 16),
                          Text('Assigned insurance', style: AppTextStyles.titleMedium),
                          const SizedBox(height: 8),
                          if (insurances.isEmpty)
                            const Text('No insurance records found.')
                          else
                            ...insurances.map((insurance) {
                              final item = insurance is Map ? insurance : <String, dynamic>{'details': insurance};
                              final label = item['policyName'] ?? item['policyTitle'] ?? item['insuranceNumber'] ?? item['policyNumber'] ?? 'Insurance';
                              final status = item['status'] ?? item['policyStatus'] ?? '';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.lightBorder),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.shield_outlined, color: AppColors.primary),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(label.toString(), style: AppTextStyles.titleSmall)),
                                    Text(status.toString(), style: AppTextStyles.bodySmall),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateCustomerDialog() async {
    final formKey = GlobalKey<FormState>();
    final firstName = TextEditingController();
    final lastName = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    bool submitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add customer'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: firstName,
                    decoration: const InputDecoration(labelText: 'First name'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'First name is required' : null,
                  ),
                  TextFormField(
                    controller: lastName,
                    decoration: const InputDecoration(labelText: 'Last name'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Last name is required' : null,
                  ),
                  TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email (optional)'),
                  ),
                  TextFormField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone number'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: submitting ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => submitting = true);
                try {
                  await getIt<Dio>().post(
                    ApiEndpoints.agentCustomers,
                    data: {
                      'firstName': firstName.text.trim(),
                      'lastName': lastName.text.trim(),
                      if (email.text.trim().isNotEmpty) 'email': email.text.trim(),
                      if (phone.text.trim().isNotEmpty) 'phone': phone.text.trim(),
                    },
                  );
                  if (!mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Customer created successfully')),
                  );
                  await _refresh();
                } on DioException catch (error) {
                  setDialogState(() => submitting = false);
                  final response = error.response?.data;
                  final message = response is Map
                      ? (response['message'] ?? response['error'] ?? 'Unable to create customer').toString()
                      : 'Unable to create customer. Check the required customer fields.';
                  ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text(message)));
                } catch (_) {
                  setDialogState(() => submitting = false);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Unable to create customer. Please try again.')),
                  );
                }
              },
              child: submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );

    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCustomerDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add customer'),
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: ConnectivityBanner()),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.darkGradient,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people_alt_rounded, color: AppColors.accent, size: 24),
                        const SizedBox(width: 10),
                        Text('AGENT PORTAL', style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accent, fontWeight: FontWeight.w800, letterSpacing: 1,
                        )),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Refresh customers',
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('My Customers', style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w800,
                    )),
                    const SizedBox(height: 4),
                    Text('Manage customers assigned to your agency.',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: TextField(
                  onChanged: (value) => setState(() => _search = value.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search name, email or phone',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.lightBorder)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.lightBorder)),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _customersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(padding: EdgeInsets.all(28), child: LoadingView());
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.error),
                          const SizedBox(height: 8),
                          const Text('Could not load agent customers.'),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try again'),
                          ),
                        ],
                      ),
                    );
                  }

                  final all = snapshot.data ?? [];
                  final customers = all.where((item) {
                    final searchable = [
                      _customerName(item),
                      _firstValue(item, ['email', 'emailAddress']),
                      _firstValue(item, ['phone', 'phoneNumber', 'mobile']),
                    ].join(' ').toLowerCase();
                    return searchable.contains(_search);
                  }).toList();

                  if (customers.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                      child: Column(
                        children: [
                          Icon(Icons.people_outline_rounded, size: 54, color: AppColors.grey400),
                          const SizedBox(height: 12),
                          Text(_search.isEmpty ? 'No customers assigned yet' : 'No matching customers',
                            style: AppTextStyles.titleMedium),
                          const SizedBox(height: 6),
                          Text(_search.isEmpty
                              ? 'Create a customer to start managing their insurance.'
                              : 'Try another name, email or phone number.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600)),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                        child: Row(
                          children: [
                            Text('Customers', style: AppTextStyles.titleMedium),
                            const Spacer(),
                            Text('${customers.length} found', style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600)),
                          ],
                        ),
                      ),
                      ...customers.map((item) {
                        final name = _customerName(item);
                        final email = _firstValue(item, ['email', 'emailAddress'], fallback: 'No email provided');
                        final phone = _firstValue(item, ['phone', 'phoneNumber', 'mobile'], fallback: 'No phone provided');
                        final id = _firstValue(item, ['id', 'customerId'], fallback: '—');
                        return InkWell(
                          onTap: () => _showCustomerDetails(item),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.lightBorder),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.025), blurRadius: 10, offset: const Offset(0, 3))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: AppColors.primaryGradient),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                                )),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.titleSmall),
                                    const SizedBox(height: 4),
                                    Text(email, maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600)),
                                    const SizedBox(height: 3),
                                    Text(phone, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(10)),
                                child: Text('#$id', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          ),
                        );
                      }),
                      const SizedBox(height: 100),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
