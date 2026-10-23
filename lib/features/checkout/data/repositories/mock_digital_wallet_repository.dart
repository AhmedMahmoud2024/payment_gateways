import 'package:payment_gateways/features/checkout/data/models/digtial_wallet_input_model.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_state.dart';
import 'package:payment_gateways/features/checkout/logic/strategies/payment_strategy.dart';

abstract class DigitalWalletRepository{
Future<DigitalWalletInputModel> getWalletBalance();
Future<void> updateWalletBalance(double newBalance);
}

class MockDigitalWalletRepository implements PaymentStrategy, DigitalWalletRepository{
  double _balance= 1500.0;
 
  @override
  Future<DigitalWalletInputModel> getWalletBalance() async{
    await Future.delayed(const Duration(milliseconds: 300));
    return DigitalWalletInputModel(balance: _balance);
  }

  @override
  Future<void> updateWalletBalance(double newBalance) async {
        await Future.delayed(const Duration(milliseconds: 300));
       _balance = newBalance;   
  }

  @override
  Future<CheckoutState> processPayment() {
    // TODO: implement processPayment
    throw UnimplementedError();
  }
  
}