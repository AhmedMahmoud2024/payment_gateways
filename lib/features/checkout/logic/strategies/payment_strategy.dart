import '../checkout_state.dart';

/// 1. الـ Abstract Strategy Interface
abstract class PaymentStrategy {
  Future<CheckoutState> processPayment(); 
}
abstract class DigitalPaymentStrategy {
    Future<bool> pay(double amount);
}
