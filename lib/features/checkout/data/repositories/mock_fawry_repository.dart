import 'package:payment_gateways/features/checkout/data/models/fawry_input_model.dart';
import 'package:payment_gateways/features/checkout/data/repositories/mock_checkout_repository.dart';

class MockFawryCodeGenerated extends MockPaymentResult {
final String referenceNumber;
final String expireTimel;

  MockFawryCodeGenerated({
    required this.referenceNumber,
     required this.expireTimel
     });

}

class MockFawryRepository{
 Future<MockPaymentResult> generateFawryCode(FawryInputModel input)async{
  await Future.delayed(const Duration(seconds: 2));
  if(input.cleanEmail.contains('fail')){
    return MockFailure('Failed to generate Fawry code, please try again');
  }
  final refNumber = (1000000 + (DateTime.now().millisecondsSinceEpoch % 8999999999)).toString();
  return MockFawryCodeGenerated(referenceNumber: refNumber, expireTimel: '6 hours');
  }
  }