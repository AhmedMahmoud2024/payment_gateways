
import 'dart:math';

import 'package:payment_gateways/features/checkout/data/models/card_input_model.dart';

abstract class MockPaymentResult{}

class MockSuccess extends MockPaymentResult{
  final String transactionId;
  MockSuccess(this.transactionId);
}

class Mock3DRequired extends MockPaymentResult{
  final String redirectUrl;

  Mock3DRequired(this.redirectUrl);
  
}

class MockFailure extends MockPaymentResult{
  final String errorMessage;
  MockFailure(this.errorMessage);
}
class MockCheckoutRepository{
 Future<MockPaymentResult>  processCardPayment(CardInputModel card)async{
 await Future.delayed(const Duration(seconds: 2));
 final rawNumber=card.rawCardNumber;
 if(rawNumber.endsWith('1111')){
  final randomTxId= 'TXN_${Random().nextInt(899999)+100000}';
  return MockSuccess(randomTxId);

 }else if(rawNumber.endsWith('2222')){
  return Mock3DRequired('https://example.com/3dsecure');
 }else{
  return MockFailure('Payment failed. Please try again.');
 }
  }
}
 