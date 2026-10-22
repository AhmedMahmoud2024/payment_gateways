import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_notifier.dart';
import 'package:payment_gateways/features/checkout/logic/forms/wallet_form_controller.dart';
import 'package:payment_gateways/features/checkout/logic/strategies/wallet_payment_strategy.dart';
import 'package:payment_gateways/features/checkout/logic/validators/payment_validator.dart';

class WalletCheckoutForm extends ConsumerStatefulWidget {
  final bool isLoading;

  const WalletCheckoutForm({super.key, required this.isLoading});

  @override
  ConsumerState<WalletCheckoutForm> createState() => _WalletCheckoutFormState();
}

class _WalletCheckoutFormState extends ConsumerState<WalletCheckoutForm> {
  // متغير للتحكم في إظهار حقل الـ OTP في نفس الصفحة فوراً
  bool isOtpSent = false;
  final TextEditingController otpController = TextEditingController();

  // رقم صاحب الحساب الأساسي للأمان (المرسل)
  final String senderMainPhone = "010****1234";

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // جلب الكنترولرز الخاصة بالمحفظة من الـ AutoDispose Provider القديم
    final walletForm = ref.watch(walletFormProvider);
    final recipientPhone = walletForm.phone.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الدفع عبر المحفظة الرقمية'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: walletForm.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1️⃣ المرحلة الأولى: إدخال رقم المحفظة للمستفيد
              if (!isOtpSent) ...[
                TextFormField(
                  controller: walletForm.phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم المحفظة (فودافون كاش / أورنج / إتصالك)',
                    hintText: '010xxxxxxx',
                    prefixIcon: Icon(Icons.phone_android),
                    border: OutlineInputBorder(),
                  ),
                  validator: PaymentValidators.validatePhoneNumber,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: widget.isLoading
                      ? null 
                      : () {
                          if (walletForm.formKey.currentState!.validate()) {
                            // التحديث اللحظي للـ State لإظهار حقل الـ OTP في نفس الشاشة
                            setState(() {
                              isOtpSent = true;
                            });

                            // استدعاء الاستراتيجية القديمة لتنفيذ الدفع
                            ref.read(checkoutProvider.notifier).executePayment(
                                  WalletPaymentStrategy(
                                    phoneNumber: recipientPhone,
                                  ),
                                );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم إرسال رمز OTP إلى رقمك الأساسي ($senderMainPhone)'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                        },
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('طلب كود التأكيد (OTP)'),
                ),
              ] 
              // 2️⃣ المرحلة الثانية: ظهور حقل الـ OTP وزر التأكيد وإتمام الدفع في نفس الصفحة مباشرة
              else ...[
                Text(
                  'تم إرسال رمز OTP إلى رقمك الأساسي ($senderMainPhone) لتحويل المبلغ إلى: $recipientPhone',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'أدخل رمز الـ OTP (مثال: 1234)',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: widget.isLoading ? null : () async {
                    if (otpController.text.trim() == "1234") {
                    ref.read(checkoutProvider.notifier).submitOTP(otpController.text);
                      // ✅ نجاح العملية وترحيل القيود للـ ERP فوراً دون أي تكرار
                  
                      Navigator.pop(context); // العودة للشاشة الرئيسية
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('كود الـ OTP غير صحيح! (جرب 1234)'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('تأكيد الرمز وإتمام الدفع'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}