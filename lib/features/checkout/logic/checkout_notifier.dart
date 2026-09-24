import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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