import 'package:flutter_riverpod/legacy.dart';
import 'package:payment_gateways/features/checkout/data/models/card_input_model.dart';
import 'package:payment_gateways/features/checkout/data/repositories/mock_checkout_repository.dart';
import 'package:payment_gateways/features/checkout/data/utils/card_validator.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final checkoutProvider = StateNotifierProvider<CheckoutNotifier,CheckoutState>((ref){
return CheckoutNotifier(MockCheckoutRepository());
});

class CheckoutNotifier extends StateNotifier<CheckoutState>{
  final MockCheckoutRepository _repository;  
  CheckoutNotifier(this._repository):super(const CheckoutInitial());

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
    final result = await _repository.processCardPayment(card);
  if(result is MockSuccess){
    state = CheckoutSuccess(result.transactionId);
  }else if(result is Mock3DSRequired){
   state = Checkout3DSRequired(result.redirectUrl);

  }else if(result is MockFailure){
    state = CheckoutFailure(result.errorMessage);

  }
  }catch(e){
 state = const CheckoutFailure('Payment failed!,please try again');
  }
 void reset(){
    state = const CheckoutInitial();
 }
  }
  
}