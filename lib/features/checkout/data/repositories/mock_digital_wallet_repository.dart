import 'package:payment_gateways/features/checkout/data/models/digtial_wallet_input_model.dart';

abstract class DigitalWalletRepository{
Future<DigitalWalletInputModel> getWalletBalance();
Future<void> updateWalletBalance(double newBalance);
}

class MockDigitalWalletRepository implements DigitalWalletRepository{
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
  
}