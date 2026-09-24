import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_notifier.dart';
import 'package:payment_gateways/features/checkout/logic/forms/checkout_form_controllers.dart';
import 'package:payment_gateways/features/checkout/logic/strategies/payment_strategy.dart';
import 'package:payment_gateways/features/checkout/logic/validators/payment_validator.dart';


class CardCheckoutForm extends ConsumerWidget {
  final bool isLoading;

  const CardCheckoutForm({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // جلب الـ Controllers والـ FormKey مباشرة من الـ Provider
    final cardForm = ref.watch(cardFormProvider);

    return Form(
      key: cardForm.formKey,
      child: Column(
        children: [
          TextFormField(
            controller: cardForm.cardNumber,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'رقم البطاقة',
              prefixIcon: Icon(Icons.credit_card),
              border: OutlineInputBorder(),
            ),
            validator: PaymentValidators.validateCardNumber,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: cardForm.expiryDate,
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الانتهاء (MM/YY)',
                    border: OutlineInputBorder(),
                  ),
                  validator: PaymentValidators.validateExpiryDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: cardForm.cvc,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'CVC',
                    border: OutlineInputBorder(),
                  ),
                  validator: PaymentValidators.validateCVC,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (cardForm.formKey.currentState!.validate()) {
                        // تنفيذ الدفع باستخدام الـ Strategy!
                        ref.read(checkoutProvider.notifier).executePayment(
                              CardPaymentStrategy(
                                cardNumber: cardForm.cardNumber.text,
                                expiryDate: cardForm.expiryDate.text,
                                cvc: cardForm.cvc.text,
                                cardHolderName: cardForm.cardHolderName.text,
                              ),
                            );
                      }
                    },
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('دفع الآن عبر البطاقة'),
            ),
          ),
        ],
      ),
    );
  }
}