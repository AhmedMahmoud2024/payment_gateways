import 'package:flutter_riverpod/legacy.dart';
import 'package:payment_gateways/features/checkout/data/models/card_input_model.dart';
import 'package:payment_gateways/features/checkout/data/models/fawry_input_model.dart';
import 'package:payment_gateways/features/checkout/data/models/wallet_input_model.dart';
import 'package:payment_gateways/features/checkout/data/repositories/mock_checkout_repository.dart';
import 'package:payment_gateways/features/checkout/data/repositories/mock_fawry_repository.dart';
import 'package:payment_gateways/features/checkout/data/repositories/mock_wallet_repository.dart';
import 'package:payment_gateways/features/checkout/data/utils/card_validator.dart';
import 'package:payment_gateways/features/checkout/data/utils/fawry_validator.dart';
import 'package:payment_gateways/features/checkout/data/utils/wallet_validator.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentMwthodType{card,wallet,fawry}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier,CheckoutState>((ref){
return CheckoutNotifier(
  MockCheckoutRepository(),
  MockWalletRepository(),
  MockFawryRepository()
  );
});

class CheckoutNotifier extends StateNotifier<CheckoutState>{
  final MockCheckoutRepository _cardRepository;  
    final MockWalletRepository _walletRepository; 
    final MockFawryRepository _fawryRepository; 
  CheckoutNotifier(
    this._cardRepository,
  this._walletRepository,
  this._fawryRepository
  ):super(const CheckoutInitial());

Future<void> payWithFawry(FawryInputModel input)async{
 if(!FawryValidator.isValidEmail(input.email)){
 state = const CheckoutFailure('Invalid email address,please check it again');
 return;
 }
 if(!FawryValidator.isValidPhone(input.phoneNumber)){
 state = const CheckoutFailure('Invalid phone number,please check it again');
 return;
 }
 state = const CheckoutLoading();
try{
 final result = await _fawryRepository.generateFawryCode(input);
 _handleResult(result);
}catch(_){

 state = const CheckoutFailure('Unexpected Error while generating Fawry code ,please try again');
}
}

Future<void> payWithWallet(WalletInputModel wallet)async{
 if(!WalletValidator.isValidEgyptianPhone(wallet.phoneNumber)){
 state = CheckoutFailure('Number must start with 01');
 return;
 }
 state = const CheckoutLoading();
 try{
   final result = await _walletRepository.processWalletPayment(wallet);
   _handleResult(result);
 }catch(e){
 state = CheckoutFailure('Unexpected Error Has occured');
 }
}
void _handleResult(MockPaymentResult result) {
    if (result is MockSuccess) {
      state = CheckoutSuccess(result.transactionId);
    } else if (result is Mock3DSRequired) {
      state = Checkout3DSRequired(result.redirectUrl);
    } else if (result is MockWalletOTPRequired) {
      state = CheckoutOTPRequired(result.phoneNumber); // ✅ تصحيح الاسم هنا
    } else if (result is MockFawryCodeGenerated) {
      state = CheckoutFawryCodeGenerated(
        referenceNumber: result.referenceNumber,
        expireTime: result.expireTime
      );
    }else if (result is MockFailure) {
      state = CheckoutFailure(result.errorMessage);
    }
  }

Future<void> submitOTP( String code)async{
if(code.trim().isEmpty){
  state = const CheckoutFailure('Please enter the otp code');
  return;
}
state= const CheckoutLoading();
 try{
   final result = await _walletRepository.verifyOtp(code);
   _handleResult(result);
 }catch(e){
 state = CheckoutFailure('Unexpected Error Has occured');
 }

}

 Future<void> payWithCard(CardInputModel card)async{
if(!CardValidator.isValidCardNumber(card.cardNumber)){
    state=const CheckoutFailure('Invaild card number!,please check it again');
  return;
}
if(!CardValidator.isValidExpiryDate(card.expiryDate)){
    state = const CheckoutFailure('Invalid expiry date!,please check it again');
   return;
}
if(!CardValidator.isValidCVV(card.cvv)){
    state = const CheckoutFailure('Invalid cvv!,please check it again');
   return;
  }
  
  if(card.cardHolderName.trim().isEmpty){
    state = const CheckoutFailure('Invalid cardholder name!,please enter your name again');
   return;
  }
  state = const CheckoutLoading();
  try{
    final result = await _cardRepository.processCardPayment(card);
    _handleResult(result);
 /*
  if(result is MockSuccess){
    state = CheckoutSuccess(result.transactionId);
  }else if(result is Mock3DSRequired){
   state = Checkout3DSRequired(result.redirectUrl);

  }else if(result is MockFailure){
    state = CheckoutFailure(result.errorMessage);

  }
  */
  }catch(e){
 state = const CheckoutFailure('Payment failed!,please try again');
  }
 
  }
  
  void reset(){
    state = const CheckoutInitial();
 }

 // استكمال عملية الـ 3DS بعد العودة من الـ WebView
void complete3DSPayment({required bool isApproved}) {
  if (isApproved) {
    state = CheckoutSuccess('TXN_3DS_${DateTime.now().millisecondsSinceEpoch}');
  } else {
    state = const CheckoutFailure('تم إلغاء العملية أو فشل التحقق المالي (3DS).');
  }
}
}