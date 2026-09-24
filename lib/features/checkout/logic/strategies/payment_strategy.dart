import '../checkout_state.dart';

/// 1. الـ Abstract Strategy Interface
abstract class PaymentStrategy {
  Future<CheckoutState> processPayment();
}

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