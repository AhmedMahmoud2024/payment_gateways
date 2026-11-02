import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import 'package:payment_gateways/features/checkout/data/models/erp_journal_entry_model.dart';
import 'package:payment_gateways/features/checkout/data/models/transaction_model.dart';
import 'package:payment_gateways/features/checkout/data/repositories/digital_wallet_local_data_source.dart';
import 'package:payment_gateways/features/checkout/data/repositories/mock_erp_integration_repository.dart';
import 'package:payment_gateways/features/checkout/logic/strategies/digital_wallet_strategy.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/forms/digital_wallet_payment_form.dart';
import 'checkout_state.dart';
import 'strategies/payment_strategy.dart';

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final DigitalWalletLocalDataSource _localDataSource;
  CheckoutNotifier(this._localDataSource) : super(const CheckoutInitial());
  final TextEditingController amountController = TextEditingController();
  final TextEditingController transferAmountController = TextEditingController();

    @override
  void dispose() {
    amountController.dispose();
    transferAmountController.dispose();
    super.dispose();
  }
  /// الميثود بقت بتستقبل أي PaymentStrategy وتنادي عليه مباشرة
  Future<void> executePayment(PaymentStrategy strategy) async {
    state = const CheckoutLoading();
    try {
      final resultState = await strategy.processPayment();
      state = resultState;
    } catch (e) {
      state = CheckoutFailure('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  ///  الميثود الجديدة الخاصة بالـ Digital Wallet (المحفظة الرقمية ذات الرصيد الفعلي)
  Future<void> executeDigitalWalletPayment(DigitalWalletPaymentStrategy walletStrategy, double amount) async {
    state = const CheckoutLoading();
    try {
      // 1. تنفيذ عملية الدفع والخصم من المحفظة
      final isSuccess = await walletStrategy.pay(amount);
      
      if (isSuccess) {
        // 2. لو نجحت، بنحدث الحالة لنجاح المعاملة مع إرجاع كود أو رقم مرجعي وهمي
        state = const CheckoutSuccess('WALLET-TXN-SUCCESS');
        await syncWithErpAfterSuccess('WALLET-TXN-SUCCESS', amount);                
      }
    } catch (e) {
      // 3. لو حصل خطأ (زي رصيد غير كافي)، بيظهر في الـ State كفشل
      state = CheckoutFailure(e.toString().replaceAll("Exception: ", ""));
    }
  }
// داخل executeDigitalWalletPayment أو بعد نجاح أي عملية دفع:
Future<void> syncWithErpAfterSuccess(String transactionId, double amount) async {
  final erpRepo = MockErpIntegrationRepository();
  
  final entry = ErpJournalEntryModel(
    entryId: "ERP-JE-${DateTime.now().millisecondsSinceEpoch}",
    transactionId: transactionId,
    amount: amount , // double.tryParse(amountController.text.trim()) ?? 0.0,
    debitAccount: "Digital Wallet Asset",
    creditAccount: "Sales Revenue",
    timestamp: DateTime.now(),
  );

  await erpRepo.postJournalEntry(entry);

  try{
final transactionModel = TransactionModel(
    id: transactionId,
    amount: amount,
    type: "digital_wallet",
    timestamp: DateTime.now().toIso8601String(),
  );

  await _localDataSource.cacheTransaction(transactionModel
);
  }catch(e){
    print("Error caching transaction: ${e.toString()}");
  }
}
  /// ميثود تأكيد الـ OTP
  Future<void> submitOTP(String otp) async {
    state = const CheckoutLoading();
    await Future.delayed(const Duration(seconds: 1));

    if (otp == '1234') {
      state = const CheckoutSuccess('WALLET-TXN-55443322');
      syncWithErpAfterSuccess('WALLET-TXN-55443322', double.tryParse(amountController.text.trim()) ?? 0.0);   
    } else {
      state = const CheckoutFailure('رمز OTP غير صحيح، حاول مجدداً.');
    }
  }

  void reset() {
    state = const CheckoutInitial();
  }
} 


// 1. Provider للـ Hive Box المفتوح
final transactionBoxProvider = Provider<Box<TransactionModel>>((ref) {
  return Hive.box<TransactionModel>('digital_wallet_transactions');
});

// 2. Provider للـ Local Data Source (اللي بنسألم عليه)
final walletLocalDataSourceProvider = Provider<DigitalWalletLocalDataSource>((ref) {
  final box = ref.read(transactionBoxProvider);
  return DigitalWalletLocalDataSourceImpl(box);
});

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  final localDataSource = ref.read(walletLocalDataSourceProvider);

  return CheckoutNotifier(localDataSource);
});
