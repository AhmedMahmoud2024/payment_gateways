import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_notifier.dart';
import 'package:payment_gateways/features/checkout/logic/forms/wallet_form_controller.dart';
import 'package:payment_gateways/features/checkout/logic/strategies/wallet_payment_strategy.dart';
import 'package:payment_gateways/features/checkout/logic/validators/payment_validator.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/forms/digital_wallet_payment_form.dart';

class WalletCheckoutForm extends ConsumerStatefulWidget {
  final bool isLoading;
 final double transferAmount;
  const WalletCheckoutForm({super.key, required this.isLoading, required this.transferAmount});

  @override
  ConsumerState<WalletCheckoutForm> createState() => _WalletCheckoutFormState();
}

class _WalletCheckoutFormState extends ConsumerState<WalletCheckoutForm> {
  bool isOtpSent = false;
  final TextEditingController otpController = TextEditingController();

  int _start = 30;
  bool _isExpired = false;

  final String senderMainPhone = "010****1234";

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && isOtpSent) {
        if (_start > 0) {
          setState(() {
            _start--;
          });
          _startTimer();
        } else {
          setState(() {
            _isExpired = true;
          });
        }
      }
    });
  }

  void _resendOtp() {
    setState(() {
      _start = 30;
      _isExpired = false;
      otpController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال رمز OTP جديد بنجاح!'), backgroundColor: Colors.blue),
    );
    _startTimer();
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // 1️⃣ المرحلة الأولى: إدخال رقم المحفظة (المستفيد)
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: widget.isLoading
                      ? null 
                      : () {
                          if (walletForm.formKey.currentState!.validate()) {
                            setState(() {
                              isOtpSent = true;
                            });
                            _startTimer();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('تم إرسال رمز OTP إلى رقمك الأساسي ($senderMainPhone)'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('طلب كود التأكيد (OTP)', style: TextStyle(fontSize: 16)),
                ),
              ] 
              // 2️⃣ المرحلة الثانية: إدخال الـ OTP عبر مربعات مصممة يدوياً بداخل Material
              else ...[
                Text(
                  'تم إرسال رمز OTP إلى رقمك الأساسي ($senderMainPhone) لتحويل المبلغ إلى: $recipientPhone',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // 📦 مربعات إدخال الـ OTP اليدوية الآمنة
                Material(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      return Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            counterText: "",
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.green, width: 2),
                            ),
                          ),
                          onChanged: (value) async {
                            if (value.isNotEmpty) {
                              otpController.text += value;
                              if (index < 3) {
                                FocusScope.of(context).nextFocus();
                              } else {
                                // اكتملت الـ 4 أرقام
                                if (_isExpired) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('عذراً، انتهت صلاحية الكود. يرجى طلب رمز جديد!'), backgroundColor: Colors.red),
                                  );
                                  return;
                                }

                                if (otpController.text == "1234") {
                         /*
                                  // تنفيذ الدفع والـ ERP التلقائي
                                  await ref.read(checkoutProvider.notifier).executePayment(
                                        WalletPaymentStrategy(
                                          phoneNumber: recipientPhone,
                                        ),
                                      );
*/
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم التحويل بنجاح! 🚀 وتم ترحيل القيود للـ ERP أوتوماتيكياً'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 4),
                                    ),
                                  );
                                   ref.read(availableBalanceProvider.notifier).state -= widget.transferAmount;
                                 //    ref.read(checkoutProvider.notifier).submitOTP(otpController.text);
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('كود الـ OTP غير صحيح! (جرب 1234)'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  otpController.clear();
                                }
                              }
                            }
                          },
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),

                // ⏱️ العداد وزر إعادة الإرسال
                Center(
                  child: _isExpired
                      ? TextButton.icon(
                          onPressed: _resendOtp,
                          icon: const Icon(Icons.refresh, color: Colors.blue),
                          label: const Text('إعادة إرسال الرمز', style: TextStyle(color: Colors.blue)),
                        )
                      : Text(
                          'تنتهي صلاحية الكود خلال: $_start ثانية',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}