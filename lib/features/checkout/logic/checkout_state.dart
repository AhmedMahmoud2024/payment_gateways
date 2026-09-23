
import 'package:equatable/equatable.dart';

sealed class CheckoutState extends Equatable{
  const CheckoutState();
  @override
  List<Object?> get props=>[];
}

// 1. الحالة المبدئية: الشاشة لسه مفرغة
final class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

// 2. حالة التحميل: جاري التحدث مع الـ Server وضبط الـ UI للانتظار
final class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

// 3. حالة النجاح: العملية تمت وبنرجع رقم الشحنة/المعاملة
final class CheckoutSuccess extends CheckoutState {
  final String transactionId;
  const CheckoutSuccess(this.transactionId);
  @override
  List<Object?> get props => [transactionId];
}

// 4. حالة التوجيه لصفحة تأكيد البنك (3DS)
final class Checkout3DSRequired extends CheckoutState {
  final String redirectUrl;
  const Checkout3DSRequired(this.redirectUrl);
@override
  List<Object?> get props => [redirectUrl];
}

// 5. حالة الفشل: حدث خطأ في الـ Validation أو السيرفر مرفوض
final class CheckoutFailure extends CheckoutState {
  final String errorMessage;
  const CheckoutFailure(this.errorMessage);
 @override
  List<Object?> get props => [errorMessage];
}
final class CheckoutOTPRequired extends CheckoutState {
  final String phoneNumber;
  const CheckoutOTPRequired(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

final class CheckoutFawryCodeGenerated extends CheckoutState{
  final String referenceNumber;
  final String expireTime;

 const CheckoutFawryCodeGenerated({
    required this.referenceNumber,
     required this.expireTime
     });

   @override
   List<Object?> get props=>[referenceNumber, expireTime];
  
}