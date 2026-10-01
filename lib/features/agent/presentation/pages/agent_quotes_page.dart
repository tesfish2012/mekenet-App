import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/connectivity_banner.dart';
import '../../../../shared/widgets/loading_view.dart';

class AgentQuotesPage extends StatefulWidget {
  const AgentQuotesPage({super.key});
  @override State<AgentQuotesPage> createState() => _AgentQuotesPageState();
}

class _AgentQuotesPageState extends State<AgentQuotesPage> {
  late Future<List<Map<String, dynamic>>> future;
  String search = '';

  @override
  void initState() {
    super.initState();
    future = load();
  }

  String value(Map<String, dynamic> m, List<String> keys, String fallback) {
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return fallback;
  }

  Future<List<Map<String, dynamic>>> load() async {
    final r = await getIt<Dio>().get(ApiEndpoints.agentQuotes);
    dynamic d = r.data;
    if (d is Map) {
      d = d['data'] ?? [];
      if (d is Map) d = d['content'] ?? [];
    }
    if (d is! List) return [];
    return d.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  String money(dynamic amount) {
    final n = amount is num ? amount : num.tryParse(amount?.toString() ?? '');
    return n == null ? '—' : n.toStringAsFixed(2);
  }

  String dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<List<Map<String, dynamic>>> loadDurations() async {
    final r = await getIt<Dio>().get(ApiEndpoints.agentPolicyDurations);
    dynamic d = r.data;
    if (d is Map) d = d['data'] ?? [];
    if (d is Map) d = d['content'] ?? [];
    if (d is! List) return [];
    return d.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<DateTime?> _pickDate(DateTime initialDate) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> requestQuote() async {
    final policyId = TextEditingController();
    final sumAssured = TextEditingController();
    final lifeName = TextEditingController();
    final dob = TextEditingController();
    final beneficiary = TextEditingController();
    final beneficiaryRelationship = TextEditingController();
    final propertyAddress = TextEditingController();
    final cargoDescription = TextEditingController();
    final cargoOrigin = TextEditingController();
    final cargoDestination = TextEditingController();
    final destinationCountry = TextEditingController();
    final preExisting = TextEditingController();
    final dependants = TextEditingController(text: '0');
    final travellers = TextEditingController(text: '1');
    final floorArea = TextEditingController();
    final yearBuilt = TextEditingController();
    final departureDate = TextEditingController();
    final returnDate = TextEditingController();
    final extraData = TextEditingController();

    String lineOfBusiness = 'MICRO';
    String paymentFrequency = 'ANNUAL';
    int policyTermMonths = 12;
    String gender = 'M';
    String smokerStatus = 'NO';
    final occupationClass = TextEditingController(text: 'A');
    String healthPlanTier = 'STANDARD';
    String constructionType = 'CONCRETE';
    String occupancyType = 'OFFICE';
    bool hasFireProtection = true;
    String transportMode = 'ROAD';
    String packingType = 'PALLETS';
    String tripType = 'SINGLE';
    bool engagesHazardousActivity = false;
    final hazardousDescription = TextEditingController();
    bool saving = false;
    DateTime selectedDob = DateTime(1990, 1, 1);
    DateTime selectedDeparture = DateTime.now();
    DateTime selectedReturn = DateTime.now().add(const Duration(days: 1));

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, set) => AlertDialog(
            title: const Text('Request premium quote'),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: policyId, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Policy ID *')),
                    TextField(controller: lifeName, decoration: const InputDecoration(labelText: 'Life assured name *')),
                    InkWell(
                      onTap: saving ? null : () async {
                        final picked = await _pickDate(selectedDob);
                        if (picked != null) {
                          set(() {
                            selectedDob = picked;
                            dob.text = _formatDate(picked);
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date of birth',
                          suffixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(
                          dob.text.isEmpty ? 'Select date' : dob.text,
                        ),
                      ),
                    ),
                    TextField(controller: sumAssured, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sum assured *')),
                    Row(children: [
                      Expanded(child: DropdownButtonFormField<String>(value: lineOfBusiness, decoration: const InputDecoration(labelText: 'Line of business'), items: const [
                        DropdownMenuItem(value: 'MICRO', child: Text('Micro')),
                        DropdownMenuItem(value: 'LIFE', child: Text('Life')),
                        DropdownMenuItem(value: 'HEALTH', child: Text('Health')),
                        DropdownMenuItem(value: 'PROPERTY', child: Text('Property')),
                        DropdownMenuItem(value: 'MARINE', child: Text('Marine')),
                        DropdownMenuItem(value: 'TRAVEL', child: Text('Travel')),
                      ], onChanged: (v) => set(() => lineOfBusiness = v ?? lineOfBusiness))),
                      const SizedBox(width: 10),
                      Expanded(child: DropdownButtonFormField<String>(value: paymentFrequency, decoration: const InputDecoration(labelText: 'Payment frequency'), items: const [
                        DropdownMenuItem(value: 'ANNUAL', child: Text('Annual')),
                        DropdownMenuItem(value: 'MONTHLY', child: Text('Monthly')),
                        DropdownMenuItem(value: 'QUARTERLY', child: Text('Quarterly')),
                      ], onChanged: (v) => set(() => paymentFrequency = v ?? paymentFrequency))),
                    ]),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: policyTermMonths,
                      decoration: const InputDecoration(labelText: 'Policy term'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1 month')),
                        DropdownMenuItem(value: 3, child: Text('3 months')),
                        DropdownMenuItem(value: 6, child: Text('6 months')),
                        DropdownMenuItem(value: 12, child: Text('12 months')),
                        DropdownMenuItem(value: 24, child: Text('24 months')),
                        DropdownMenuItem(value: 36, child: Text('36 months')),
                      ],
                      onChanged: (v) => set(() => policyTermMonths = v ?? policyTermMonths),
                    ),
                    Row(children: [
                      Expanded(child: DropdownButtonFormField<String>(value: gender, decoration: const InputDecoration(labelText: 'Gender'), items: const [
                        DropdownMenuItem(value: 'M', child: Text('Male')),
                        DropdownMenuItem(value: 'F', child: Text('Female')),
                      ], onChanged: (v) => set(() => gender = v ?? gender))),
                      const SizedBox(width: 10),
                      Expanded(child: DropdownButtonFormField<String>(value: smokerStatus, decoration: const InputDecoration(labelText: 'Smoker'), items: const [
                        DropdownMenuItem(value: 'NO', child: Text('No')),
                        DropdownMenuItem(value: 'YES', child: Text('Yes')),
                      ], onChanged: (v) => set(() => smokerStatus = v ?? smokerStatus))),
                    ]),
                    TextField(controller: occupationClass, decoration: const InputDecoration(labelText: 'Occupation class')),
                    TextField(controller: beneficiary, decoration: const InputDecoration(labelText: 'Beneficiary name')),
                    TextField(controller: beneficiaryRelationship, decoration: const InputDecoration(labelText: 'Beneficiary relationship')),
                    TextField(controller: preExisting, decoration: const InputDecoration(labelText: 'Pre-existing conditions')),
                    TextField(controller: dependants, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dependants count')),
                    DropdownButtonFormField<String>(value: healthPlanTier, decoration: const InputDecoration(labelText: 'Health plan tier'), items: const [
                      DropdownMenuItem(value: 'STANDARD', child: Text('Standard')),
                      DropdownMenuItem(value: 'PREMIUM', child: Text('Premium')),
                    ], onChanged: (v) => set(() => healthPlanTier = v ?? healthPlanTier)),
                    const Divider(height: 24),
                    TextField(controller: propertyAddress, decoration: const InputDecoration(labelText: 'Property address')),
                    TextField(controller: floorArea, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Floor area sqm')),
                    TextField(controller: yearBuilt, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Year built')),
                    Row(children: [
                      Expanded(child: DropdownButtonFormField<String>(value: constructionType, decoration: const InputDecoration(labelText: 'Construction'), items: const [
                        DropdownMenuItem(value: 'CONCRETE', child: Text('Concrete')),
                        DropdownMenuItem(value: 'STEEL', child: Text('Steel')),
                        DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                      ], onChanged: (v) => set(() => constructionType = v ?? constructionType))),
                      const SizedBox(width: 10),
                      Expanded(child: DropdownButtonFormField<String>(value: occupancyType, decoration: const InputDecoration(labelText: 'Occupancy'), items: const [
                        DropdownMenuItem(value: 'OFFICE', child: Text('Office')),
                        DropdownMenuItem(value: 'RESIDENTIAL', child: Text('Residential')),
                        DropdownMenuItem(value: 'WAREHOUSE', child: Text('Warehouse')),
                      ], onChanged: (v) => set(() => occupancyType = v ?? occupancyType))),
                    ]),
                    SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Fire protection'), value: hasFireProtection, onChanged: (v) => set(() => hasFireProtection = v)),
                    TextField(controller: cargoDescription, decoration: const InputDecoration(labelText: 'Cargo description')),
                    TextField(controller: cargoOrigin, decoration: const InputDecoration(labelText: 'Cargo origin')),
                    TextField(controller: cargoDestination, decoration: const InputDecoration(labelText: 'Cargo destination')),
                    Row(children: [
                      Expanded(child: DropdownButtonFormField<String>(value: transportMode, decoration: const InputDecoration(labelText: 'Transport'), items: const [
                        DropdownMenuItem(value: 'ROAD', child: Text('Road')),
                        DropdownMenuItem(value: 'AIR', child: Text('Air')),
                        DropdownMenuItem(value: 'SEA', child: Text('Sea')),
                      ], onChanged: (v) => set(() => transportMode = v ?? transportMode))),
                      const SizedBox(width: 10),
                      Expanded(child: DropdownButtonFormField<String>(value: packingType, decoration: const InputDecoration(labelText: 'Packing'), items: const [
                        DropdownMenuItem(value: 'PALLETS', child: Text('Pallets')),
                        DropdownMenuItem(value: 'BOXES', child: Text('Boxes')),
                      ], onChanged: (v) => set(() => packingType = v ?? packingType))),
                    ]),
                    TextField(controller: destinationCountry, decoration: const InputDecoration(labelText: 'Destination country')),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: saving ? null : () async {
                              final picked = await _pickDate(selectedDeparture);
                              if (picked != null) {
                                set(() {
                                  selectedDeparture = picked;
                                  departureDate.text = _formatDate(picked);
                                  if (selectedReturn.isBefore(picked)) {
                                    selectedReturn = picked.add(const Duration(days: 1));
                                    returnDate.text = _formatDate(selectedReturn);
                                  }
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Departure date',
                                suffixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                              child: Text(
                                departureDate.text.isEmpty ? 'Select date' : departureDate.text,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: saving ? null : () async {
                              final picked = await _pickDate(
                                selectedReturn.isBefore(selectedDeparture)
                                    ? selectedDeparture.add(const Duration(days: 1))
                                    : selectedReturn,
                              );
                              if (picked != null) {
                                if (picked.isBefore(selectedDeparture)) {
                                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                                    const SnackBar(content: Text('Return date must be after departure date.')),
                                  );
                                  return;
                                }
                                set(() {
                                  selectedReturn = picked;
                                  returnDate.text = _formatDate(picked);
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Return date',
                                suffixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                              child: Text(
                                returnDate.text.isEmpty ? 'Select date' : returnDate.text,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(children: [
                      Expanded(child: DropdownButtonFormField<String>(value: tripType, decoration: const InputDecoration(labelText: 'Trip type'), items: const [
                        DropdownMenuItem(value: 'SINGLE', child: Text('Single')),
                        DropdownMenuItem(value: 'MULTI', child: Text('Multi')),
                      ], onChanged: (v) => set(() => tripType = v ?? tripType))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: travellers, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Travellers'))),
                    ]),
                    SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Hazardous activity'), value: engagesHazardousActivity, onChanged: (v) => set(() => engagesHazardousActivity = v)),
                    if (engagesHazardousActivity) TextField(controller: hazardousDescription, decoration: const InputDecoration(labelText: 'Hazardous activity description')),
                    TextField(controller: extraData, maxLines: 3, decoration: const InputDecoration(labelText: 'Extra data JSON')),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: saving ? null : () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              FilledButton(
                onPressed: saving ? null : () async {
                  final pid = int.tryParse(policyId.text.trim());
                  final sa = double.tryParse(sumAssured.text.trim());
                  if (pid == null || sa == null || lifeName.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Policy ID, life assured name and sum assured are required.')));
                    return;
                  }
                  set(() => saving = true);
                  final now = DateTime.now();
                  final start = dob.text.trim().isEmpty ? '1990-01-01' : dob.text.trim();
                  try {
                    await getIt<Dio>().post(ApiEndpoints.agentQuotes, data: {
                      'policyId': pid,
                      'lineOfBusiness': lineOfBusiness,
                      'paymentFrequency': paymentFrequency,
                      'policyTermMonths': policyTermMonths,
                      'startDate': dateOnly(now),
                      'sumAssured': sa,
                      'lifeAssuredName': lifeName.text.trim(),
                      'dateOfBirth': start,
                      'gender': gender,
                      'smokerStatus': smokerStatus,
                      'occupationClass': occupationClass.text.trim(),
                      'beneficiaryName': beneficiary.text.trim(),
                      'beneficiaryRelationship': beneficiaryRelationship.text.trim(),
                      'preExistingConditions': preExisting.text.trim(),
                      'dependantsCount': int.tryParse(dependants.text.trim()) ?? 0,
                      'healthPlanTier': healthPlanTier,
                      'dependantsJson': '',
                      'propertyAddress': propertyAddress.text.trim(),
                      'constructionType': constructionType,
                      'occupancyType': occupancyType,
                      'floorAreaSqm': double.tryParse(floorArea.text.trim()) ?? 0,
                      'yearBuilt': int.tryParse(yearBuilt.text.trim()) ?? 0,
                      'hasFireProtection': hasFireProtection,
                      'selectedPerilsJson': '',
                      'cargoDescription': cargoDescription.text.trim(),
                      'cargoOrigin': cargoOrigin.text.trim(),
                      'cargoDestination': cargoDestination.text.trim(),
                      'transportMode': transportMode,
                      'packingType': packingType,
                      'destinationCountry': destinationCountry.text.trim(),
                      'departureDate': departureDate.text.trim().isEmpty ? null : departureDate.text.trim(),
                      'returnDate': returnDate.text.trim().isEmpty ? null : returnDate.text.trim(),
                      'tripType': tripType,
                      'travellersCount': int.tryParse(travellers.text.trim()) ?? 1,
                      'engagesHazardousActivity': engagesHazardousActivity,
                      'hazardousActivityDescription': hazardousDescription.text.trim(),
                      'extraDataJson': extraData.text.trim(),
                    });
                    if (!mounted) return;
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Quote request submitted')));
                    setState(() => future = load());
                  } on DioException catch (e) {
                    set(() => saving = false);
                    final body = e.response?.data;
                    final msg = body is Map ? (body['message'] ?? body['error'] ?? 'Unable to submit quote').toString() : 'Unable to submit quote';
                    ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text(msg)));
                  }
                },
                child: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit'),
              ),
            ],
          ),
        ),
      );
    } finally {
      for (final c in [policyId,sumAssured,lifeName,dob,beneficiary,beneficiaryRelationship,propertyAddress,cargoDescription,cargoOrigin,cargoDestination,destinationCountry,preExisting,dependants,travellers,floorArea,yearBuilt,departureDate,returnDate,extraData,hazardousDescription,occupationClass]) c.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: requestQuote,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.request_quote_rounded),
        label: const Text('Request quote'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => future = load());
          await future;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: ConnectivityBanner()),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 20,
                  20,
                  24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.darkGradient),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AGENT PORTAL',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'My Quotes',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Request and track premium quotes.',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (v) => setState(() => search = v.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search quotes',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(28),
                      child: LoadingView(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => future = load()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    );
                  }

                  final allQuotes = snapshot.data ?? [];
                  final filteredQuotes = allQuotes.where((q) {
                    final searchable = [
                      value(q, ['quoteNumber'], 'Quote'),
                      value(q, ['customerName'], 'Customer'),
                      value(q, ['status'], 'DRAFT'),
                      value(q, ['policyTitle', 'policyTypeName'], ''),
                    ].join(' ').toLowerCase();

                    return searchable.contains(search);
                  }).toList();

                  if (filteredQuotes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: Text('No quotes found')),
                    );
                  }

                  return Column(
                    children: [
                      for (final q in filteredQuotes)
                        Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                value(q, ['policyTypeEmoji'], '📄'),
                              ),
                            ),
                            title: Text(
                              value(q, ['quoteNumber'], 'Quote'),
                            ),
                            subtitle: Text(
                              '${value(q, ['customerName'], 'Customer')} • '
                              '${value(q, ['policyTitle', 'policyTypeName'], 'Policy')}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  value(q, ['status'], 'DRAFT'),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  money(q['totalAmount']),
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
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
