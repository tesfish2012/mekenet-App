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
  late Future<List<Map<String,dynamic>>> future;
  String search = '';
  @override void initState(){super.initState(); future=load();}
  String value(Map<String,dynamic> m,List<String> keys,String fallback){
    for(final k in keys){final v=m[k];if(v!=null&&v.toString().trim().isNotEmpty)return v.toString();}
    return fallback;
  }
  Future<List<Map<String,dynamic>>> load() async {
    final r=await getIt<Dio>().get(ApiEndpoints.agentQuotes); dynamic d=r.data;
    if(d is Map)d=d['data']??d['content']??d['items']??d['quotes']??[];
    if(d is! List)return [];
    return d.whereType<Map>().map((e)=>Map<String,dynamic>.from(e)).toList();
  }
  Future<void> requestQuote() async {
    final type=TextEditingController(), details=TextEditingController();
    bool saving=false;
    await showDialog(context:context,builder:(ctx)=>StatefulBuilder(builder:(ctx,set)=>AlertDialog(
      title:const Text('Request premium quote'),
      content:Column(mainAxisSize:MainAxisSize.min,children:[
        TextField(controller:type,decoration:const InputDecoration(labelText:'Policy type')),
        TextField(controller:details,maxLines:3,decoration:const InputDecoration(labelText:'Customer / risk details')),
      ]),
      actions:[
        TextButton(onPressed:saving?null:()=>Navigator.pop(ctx),child:const Text('Cancel')),
        FilledButton(onPressed:saving?null:() async {
          if(type.text.trim().isEmpty)return;
          set(()=>saving=true);
          try{
            await getIt<Dio>().post(ApiEndpoints.agentQuotes,data:{'policyType':type.text.trim(),'description':details.text.trim()});
            if(mounted)Navigator.pop(ctx);
            if(mounted){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Quote request submitted')));setState(()=>future=load());}
          }catch(_){set(()=>saving=false);if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Unable to submit quote')));}
        },child:saving?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)):const Text('Submit')),
      ],
    )));
    type.dispose();details.dispose();
  }
  @override Widget build(BuildContext context)=>Scaffold(
    floatingActionButton:FloatingActionButton.extended(onPressed:requestQuote,backgroundColor:AppColors.primary,foregroundColor:Colors.white,icon:const Icon(Icons.request_quote_rounded),label:const Text('Request quote')),
    body:RefreshIndicator(onRefresh:()async=>setState(()=>future=load()),child:CustomScrollView(physics:const AlwaysScrollableScrollPhysics(),slivers:[
      const SliverToBoxAdapter(child:ConnectivityBanner()),
      SliverToBoxAdapter(child:Container(padding:EdgeInsets.fromLTRB(20,MediaQuery.of(context).padding.top+20,20,24),decoration:const BoxDecoration(gradient:LinearGradient(colors:AppColors.darkGradient),borderRadius:BorderRadius.vertical(bottom:Radius.circular(24))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('AGENT PORTAL',style:TextStyle(color:AppColors.accent,fontWeight:FontWeight.w800,letterSpacing:1)),const SizedBox(height:6),
        Text('My Quotes',style:AppTextStyles.headlineMedium.copyWith(color:Colors.white,fontWeight:FontWeight.w800)),const SizedBox(height:4),
        Text('Request and track premium quotes.',style:AppTextStyles.bodySmall.copyWith(color:Colors.white70)),
      ]))),
      SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.all(16),child:TextField(onChanged:(v)=>setState(()=>search=v.toLowerCase()),decoration:InputDecoration(hintText:'Search quotes',prefixIcon:const Icon(Icons.search),filled:true,border:OutlineInputBorder(borderRadius:BorderRadius.circular(16)))))),
      SliverToBoxAdapter(child:FutureBuilder<List<Map<String,dynamic>>>(future:future,builder:(context,s){
        if(s.connectionState==ConnectionState.waiting)return const Padding(padding:EdgeInsets.all(28),child:LoadingView());
        if(s.hasError)return Padding(padding:const EdgeInsets.all(24),child:OutlinedButton.icon(onPressed:()=>setState(()=>future=load()),icon:const Icon(Icons.refresh),label:const Text('Try again')));
        final list=(s.data??[]).where((q)=>[value(q,['quoteNumber','quoteNo','id'],'Quote'),value(q,['customerName','customer','name'],'Customer'),value(q,['status'],'Pending'),value(q,['policyType','policyTypeName'],'')].join(' ').toLowerCase().contains(search)).toList();
        if(list.isEmpty)return const Padding(padding:EdgeInsets.all(40),child:Center(child:Text('No quotes found')));
        return Column(children:list.map((q)=>Card(margin:const EdgeInsets.symmetric(horizontal:16,vertical:6),child:ListTile(
          leading:const CircleAvatar(child:Icon(Icons.description_outlined)),
          title:Text(value(q,['quoteNumber','quoteNo','id'],'Quote')),
          subtitle:Text(value(q,['customerName','customer','name'],'Customer')+' • '+value(q,['policyType','policyTypeName'],'Policy')),
          trailing:Text(value(q,['status'],'Pending'),style:AppTextStyles.labelSmall.copyWith(color:AppColors.primary,fontWeight:FontWeight.w700)),
        )).toList()..add(const SizedBox(height:100)));
      })),
    ])));
}
