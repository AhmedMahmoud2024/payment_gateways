import 'package:payment_gateways/features/checkout/data/models/wallet_input_model.dart';
import 'package:payment_gateways/features/checkout/data/repositories/mock_checkout_repository.dart';

class MockWalletOTPRequired extends MockPaymentResult{
  final String phoneNumber;
  MockWalletOTPRequired(this.phoneNumber);
}
class MockWalletRepository{
  Future<MockPaymentResult> processWalletPayment(WalletInputModel wallet)async{
 await Future.delayed(const Duration(seconds: 2));
 final cleanPhone= wallet.phoneNumber;
 
 if(cleanPhone.endsWith('0000')){
  return MockWalletOTPRequired(cleanPhone);
 }
 return MockSuccess('WAL_${DateTime.now().millisecondsSinceEpoch}');
  }

  Future<MockPaymentResult> verifyOtp(String code)async{
 await Future.delayed(const Duration(seconds: 1));

if(code.trim() =='1234'){
  return MockSuccess('WAL_${DateTime.now().millisecondsSinceEpoch}');
}
return MockFailure('OTP is incorrect,try again');
  }
}
