import 'package:meta/meta.dart';

@immutable
sealed class CheckoutState{
  const CheckoutState();
}
class CheckoutInitial extends CheckoutState{
  const CheckoutInitial();
}
class CheckoutLoading extends CheckoutState{
  const CheckoutLoading();
}
class CheckoutSuccess extends CheckoutState{
 final String transactionId;
  const CheckoutSuccess(this.transactionId);
}
class Checkout3DSRequired extends CheckoutState{
 final String redirectUrl;
  const Checkout3DSRequired(this.redirectUrl);
}
class CheckoutFailure extends CheckoutState{
 final String errorMessage;
  const CheckoutFailure(this.errorMessage);
}
