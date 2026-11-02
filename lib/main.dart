import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:payment_gateways/features/checkout/data/models/transaction_model.dart';
import 'package:payment_gateways/features/checkout/presentation/screens/checkout_screen.dart';

void main() async{
 WidgetsFlutterBinding.ensureInitialized();
 await Hive.initFlutter();
 Hive.registerAdapter(TransactionModelAdapter());
 await Hive.openBox<TransactionModel>('digital_wallet_transactions');
 
 runApp(
const ProviderScope (
  
    child: MyApp()
     
   )
 );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:  const CheckoutScreen()
    );
  }
}
