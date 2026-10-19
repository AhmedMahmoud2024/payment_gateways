import 'package:flutter_riverpod/legacy.dart';
import 'package:payment_gateways/features/checkout/logic/strategies/digital_wallet_strategy.dart';
import 'checkout_state.dart';
import 'strategies/payment_strategy.dart';

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier() : super(const CheckoutInitial());

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
      }
    } catch (e) {
      // 3. لو حصل خطأ (زي رصيد غير كافي)، بيظهر في الـ State كفشل
      state = CheckoutFailure(e.toString().replaceAll("Exception: ", ""));
    }
  }

  /// ميثود تأكيد الـ OTP
  Future<void> submitOTP(String otp) async {
    state = const CheckoutLoading();
    await Future.delayed(const Duration(seconds: 1));

    if (otp == '1234') {
      state = const CheckoutSuccess('WALLET-TXN-55443322');
    } else {
      state = const CheckoutFailure('رمز OTP غير صحيح، حاول مجدداً.');
    }
  }

  void reset() {
    state = const CheckoutInitial();
  }
} 
final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier();
});
