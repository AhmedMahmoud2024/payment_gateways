import 'package:payment_gateways/features/checkout/logic/checkout_state.dart';
import 'package:payment_gateways/features/checkout/logic/strategies/payment_strategy.dart';

/// استراتيجية الدفع عبر فوري (Fawry Strategy)
class FawryPaymentStrategy implements PaymentStrategy {
  final String phoneNumber;
  final String email;

  FawryPaymentStrategy({
    required this.phoneNumber,
    required this.email,
  });

  @override
  Future<CheckoutState> processPayment() async {
    // محاكاة طلب API لفوري مع التليفون والإيميل
    await Future.delayed(const Duration(seconds: 2));

    return const CheckoutFawryCodeGenerated(
      referenceNumber: '984512367',
      expireTime: '72 ساعة',
    );
  }
}
