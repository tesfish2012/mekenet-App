import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/connectivity_banner.dart';

class AgentEndorsementsPage extends StatefulWidget {
  const AgentEndorsementsPage({super.key});
  @override State<AgentEndorsementsPage> createState()=>_AgentEndorsementsPageState();
}
class _AgentEndorsementsPageState extends State<AgentEndorsementsPage>{
  final id=TextEditingController(); List<Map<String,dynamic>> items=[]; bool loading=false;
  String value(Map<String,dynamic> m,List<String> keys,String fallback){for(final k in keys){final v=m[k];if(v!=null&&v.toString().trim().isNotEmpty)return v.toString();}return fallback;}
  Future<void> load()async{
    final insuranceId=int.tryParse(id.text.trim());if(insuranceId==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Enter a valid insurance ID')));return;}
    setState(()=>loading=true);
    try{final r=await getIt<Dio>().get(ApiEndpoints.agentEndorsementsForInsurance(insuranceId));dynamic d=r.data;if(d is Map)d=d['data']??d['content']??d['items']??d['endorsements']??[];setState(()=>items=d is List?d.whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList():[]);}catch(_){if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Unable to load endorsements')));}finally{if(mounted)setState(()=>loading=false);}
  }
  Future<void> submit() async {
    final insuranceId = int.tryParse(id.text.trim());
    if (insuranceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the insurance ID first')),
      );
      return;
    }

    final request = TextEditingController();
    final newSumAssured = TextEditingController(text: '0');
    final newPremium = TextEditingController(text: '0');
    final description = TextEditingController();
    final adminNotes = TextEditingController();
    String endorsementType = 'SUM_INSURED_CHANGE';
    DateTime effectiveDate = DateTime.now();

    String dateOnly(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: const Text('Submit endorsement'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: endorsementType,
                    decoration: const InputDecoration(labelText: 'Endorsement Type'),
                    items: const [
                      DropdownMenuItem(
                        value: 'SUM_INSURED_CHANGE',
                        child: Text('Sum Insured Change'),
                      ),
                      DropdownMenuItem(
                        value: 'PREMIUM_CHANGE',
                        child: Text('Premium Change'),
                      ),
                      DropdownMenuItem(
                        value: 'OTHER',
                        child: Text('Other'),
                      ),
                    ],
                    onChanged: (v) => setDialogState(() {
                      endorsementType = v ?? 'SUM_INSURED_CHANGE';
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newSumAssured,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'New Sum Assured',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newPremium,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'New Premium',
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: effectiveDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() => effectiveDate = picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Effective Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(dateOnly(effectiveDate)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: request,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Change Request / Description',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: description,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: adminNotes,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Admin Notes',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    final payload = {
                      'insuranceId': insuranceId,
                      'requestedById': 0,
                      'endorsementType': endorsementType,
                      'newSumAssured': double.tryParse(newSumAssured.text.trim()) ?? 0,
                      'newPremium': double.tryParse(newPremium.text.trim()) ?? 0,
                      'effectiveDate': dateOnly(effectiveDate),
                      'description': description.text.trim().isNotEmpty
                          ? description.text.trim()
                          : request.text.trim(),
                      'adminNotes': adminNotes.text.trim(),
                    };

                    await getIt<Dio>().post(
                      ApiEndpoints.agentEndorsements,
                      data: payload,
                    );

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop(true);
                    }
                  } catch (_) {
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Unable to submit endorsement'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      );

      if (mounted) {
        await load();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endorsement submitted')),
        );
      }
    } finally {
      request.dispose();
      newSumAssured.dispose();
      newPremium.dispose();
      description.dispose();
      adminNotes.dispose();
    }
  }
  @override void dispose(){id.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(
    floatingActionButton:FloatingActionButton.extended(onPressed:submit,backgroundColor:AppColors.primary,foregroundColor:Colors.white,icon:const Icon(Icons.edit_document),label:const Text('New endorsement')),
    body:CustomScrollView(slivers:[
      const SliverToBoxAdapter(child:ConnectivityBanner()),
      SliverToBoxAdapter(child:Container(padding:EdgeInsets.fromLTRB(20,MediaQuery.of(context).padding.top+20,20,24),decoration:const BoxDecoration(gradient:LinearGradient(colors:AppColors.darkGradient),borderRadius:BorderRadius.vertical(bottom:Radius.circular(24))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('AGENT PORTAL',style:TextStyle(color:AppColors.accent,fontWeight:FontWeight.w800,letterSpacing:1)),const SizedBox(height:6),
        Text('Endorsements',style:AppTextStyles.headlineMedium.copyWith(color:Colors.white,fontWeight:FontWeight.w800)),const SizedBox(height:4),
        Text('Submit and review mid-term changes.',style:AppTextStyles.bodySmall.copyWith(color:Colors.white70))
      ]))),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.all(16),child:TextField(controller:id,keyboardType:TextInputType.number,decoration:InputDecoration(labelText:'Insurance ID',prefixIcon:const Icon(Icons.shield_outlined),suffixIcon:IconButton(onPressed:loading?null:load,icon:const Icon(Icons.search)))))),
      if(loading)const SliverToBoxAdapter(child:LinearProgressIndicator()),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final e = items[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.edit_document)),
                title: Text(value(e, ['type', 'endorsementType', 'title'], 'Endorsement')),
                subtitle: Text(value(e, ['description', 'request', 'reason'], 'Mid-term change')),
                trailing: Text(
                  value(e, ['status'], 'Pending'),
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                ),
              ),
            );
          },
          childCount: items.length,
        ),
      ),
      const SliverToBoxAdapter(child:SizedBox(height:100))
    ]));
}
