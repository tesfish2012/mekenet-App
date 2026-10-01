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
  Future<void> submit()async{
    final insuranceId=int.tryParse(id.text.trim());if(insuranceId==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Enter the insurance ID first')));return;}
    final request=TextEditingController();bool saving=false;
    await showDialog(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,set)=>AlertDialog(title:const Text('Submit endorsement'),content:TextField(controller:request,maxLines:4,decoration:const InputDecoration(labelText:'Requested change')),actions:[
      TextButton(onPressed:saving?null:()=>Navigator.pop(ctx),child:const Text('Cancel')),
      FilledButton(onPressed:saving?null:()async{if(request.text.trim().isEmpty)return;set(()=>saving=true);try{await getIt<Dio>().post(ApiEndpoints.agentEndorsements,data:{'insuranceId':insuranceId,'request':request.text.trim()});if(mounted)Navigator.pop(ctx);await load();if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Endorsement submitted')));}catch(_){set(()=>saving=false);}},child:saving?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Text('Submit'))
    ])));request.dispose();
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
      SliverList(delegate:SliverChildBuilderDelegate((context,i){final e=items[i];return Card(margin:const EdgeInsets.symmetric(horizontal:16,vertical:5),child:ListTile(leading:const CircleAvatar(child:Icon(Icons.edit_document)),title:Text(value(e,['type','endorsementType','title'],'Endorsement')),subtitle:Text(value(e,['description','request','reason'],'Mid-term change')),trailing:Text(value(e,['status'],'Pending'),style:AppTextStyles.labelSmall.copyWith(color:AppColors.primary)));},childCount:items.length)),
      const SliverToBoxAdapter(child:SizedBox(height:100))
    ]));
}
