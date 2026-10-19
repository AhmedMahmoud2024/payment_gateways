
// استراتيجية الدفع بالمحفظة الرقمية
import 'package:payment_gateways/features/checkout/data/repositories/mock_digital_wallet_repository.dart';
import 'package:payment_gateways/features/checkout/logic/strategies/payment_strategy.dart';

class DigitalWalletPaymentStrategy implements DigitalPaymentStrategy {
  final DigitalWalletRepository digitalWalletRepository;

  DigitalWalletPaymentStrategy(this.digitalWalletRepository);

  @override
  Future<bool> pay(double amount) async {
    // 1. جلب الرصيد الحالي
    final wallet = await digitalWalletRepository.getWalletBalance();
    
    // 2. التحقق من كفاية الرصيد
    if (wallet.balance < amount) {
      throw Exception("رصيد المحفظة غير كافي (Insufficient Funds)");
    }

    // 3. خصم المبلغ وتحديث الرصيد
    final newBalance = wallet.balance - amount;
    await digitalWalletRepository.updateWalletBalance(newBalance);
    
    return true; // نجاح العملية
  }


}

