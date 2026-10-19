
import 'package:payment_gateways/features/checkout/logic/checkout_state.dart';
import 'package:payment_gateways/features/checkout/logic/strategies/payment_strategy.dart';

/// 3. استراتيجية الدفع بالمحفظة الإلكترونية (Wallet Strategy)
class WalletPaymentStrategy implements PaymentStrategy {
  final String phoneNumber;

  WalletPaymentStrategy({required this.phoneNumber});

  @override
  Future<CheckoutState> processPayment() async {
    // محاكاة طلب API للمحفظة
    await Future.delayed(const Duration(seconds: 2));

    if (phoneNumber == '01000000000') {
      return const CheckoutFailure('رقم المحفظة غير مسجل أو لا يحتوي على رصيد كافٍ');
    }

    return CheckoutOTPRequired(phoneNumber);
  }
}
