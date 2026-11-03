
// 1. Provider للـ Biometric Service
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:payment_gateways/features/checkout/data/models/transaction_model.dart';
import 'package:payment_gateways/features/checkout/data/repositories/biometric_local_data_source.dart';
import 'package:payment_gateways/features/checkout/data/repositories/digital_wallet_local_data_source.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_notifier.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_state.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricServiceImpl();
});

// 2. Provider للـ Hive Box المفتوح
final transactionBoxProvider = Provider<Box<TransactionModel>>((ref) {
  return Hive.box<TransactionModel>('digital_wallet_transactions');
});

// 3. Provider للـ Local Data Source (اللي بنسألم عليه)
final walletLocalDataSourceProvider = Provider<DigitalWalletLocalDataSource>((ref) {
  final box = ref.read(transactionBoxProvider);
  return DigitalWalletLocalDataSourceImpl(box);
});

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  final localDataSource = ref.read(walletLocalDataSourceProvider);
 final biometricService = ref.watch(biometricServiceProvider); 
  return CheckoutNotifier(localDataSource, biometricService);
});
