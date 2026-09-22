import 'package:meta/meta.dart';

@immutable
sealed class CheckoutState {
  const CheckoutState();
}

// 1. الحالة المبدئية: الشاشة لسه مفرغة
class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

// 2. حالة التحميل: جاري التحدث مع الـ Server وضبط الـ UI للانتظار
class CheckoutLoading extends CheckoutState {
  const CheckoutLoading();
}

// 3. حالة النجاح: العملية تمت وبنرجع رقم الشحنة/المعاملة
class CheckoutSuccess extends CheckoutState {
  final String transactionId;
  const CheckoutSuccess(this.transactionId);
}

// 4. حالة التوجيه لصفحة تأكيد البنك (3DS)
class Checkout3DSRequired extends CheckoutState {
  final String redirectUrl;
  const Checkout3DSRequired(this.redirectUrl);
}

// 5. حالة الفشل: حدث خطأ في الـ Validation أو السيرفر مرفوض
class CheckoutFailure extends CheckoutState {
  final String errorMessage;
  const CheckoutFailure(this.errorMessage);
}
class CheckoutOTPRequired extends CheckoutState {
  final String phoneNumber;
  const CheckoutOTPRequired(this.phoneNumber);
}

class CheckoutFawryCodeGenerated extends CheckoutState{
  final String referenceNumber;
  final String expireTime;

 const CheckoutFawryCodeGenerated({
    required this.referenceNumber,
     required this.expireTime
     });

   @override
   List<Object?> get props=>[referenceNumber, expireTime];
  
}