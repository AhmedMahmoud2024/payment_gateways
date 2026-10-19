import 'package:payment_gateways/features/checkout/logic/checkout_state.dart';
import 'package:payment_gateways/features/checkout/logic/strategies/payment_strategy.dart';

/// 2. استراتيجية الدفع ببطاقة الائتمان (Card Strategy)
class CardPaymentStrategy implements PaymentStrategy {
  final String cardNumber;
  final String expiryDate;
  final String cvc;
  final String cardHolderName;

  CardPaymentStrategy({
    required this.cardNumber,
    required this.expiryDate,
    required this.cvc,
    required this.cardHolderName,
  });

  @override
  Future<CheckoutState> processPayment() async {
    // محاكاة طلب API لبطاقة الائتمان
    await Future.delayed(const Duration(seconds: 2));

    if (cardNumber.replaceAll(' ', '') == '4000000000000002') {
      return const Checkout3DSRequired('https://sandbox.paymob.com/3ds');
    }

    if (cardNumber.replaceAll(' ', '') == '4000000000000001') {
      return const CheckoutFailure('تم رفض البطاقة من القابل (Insufficient Funds)');
    }

    return const CheckoutSuccess('CARD-TXN-99887766');
  }

 
}