import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_notifier.dart';
import 'package:payment_gateways/features/checkout/logic/forms/checkout_form_controllers.dart';
import 'package:payment_gateways/features/checkout/logic/strategies/payment_strategy.dart';
import 'package:payment_gateways/features/checkout/logic/validators/payment_validator.dart';


class FawryCheckoutForm extends ConsumerWidget {
  final bool isLoading;

  const FawryCheckoutForm({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // جلب الكنترولرز والـ FormKey الخاص بفوري من الـ Provider
    final fawryForm = ref.watch(fawryFormProvider);

    return Form(
      key: fawryForm.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'سيتم إرسال كود الدفع المرجعي إلى رقم الهاتف والبريد الإلكتروني المدخلين لتسديد المبلغ عبر أي منفذ فوري.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: fawryForm.phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              hintText: '010xxxxxxx',
              prefixIcon: Icon(Icons.phone_android),
              border: OutlineInputBorder(),
            ),
            validator: PaymentValidators.validatePhoneNumber,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: fawryForm.email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              hintText: 'example@domain.com',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: PaymentValidators.validateEmail,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    if (fawryForm.formKey.currentState!.validate()) {
                      // تنفيذ الدفع باستراتيجية فوري مع بيانات التليفون والإيميل
                      ref.read(checkoutProvider.notifier).executePayment(
                            FawryPaymentStrategy(
                              phoneNumber: fawryForm.phone.text,
                              email: fawryForm.email.text,
                            ),
                          );
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('إصدار كود الدفع عبر فوري'),
          ),
        ],
      ),
    );
  }
}