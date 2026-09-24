import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_notifier.dart';
import 'package:payment_gateways/features/checkout/logic/forms/checkout_form_controllers.dart';
import 'package:payment_gateways/features/checkout/logic/strategies/payment_strategy.dart';
import 'package:payment_gateways/features/checkout/logic/validators/payment_validator.dart';


class WalletCheckoutForm extends ConsumerWidget {
  final bool isLoading;

  const WalletCheckoutForm({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // جلب الكنترولرز الخاصة بالمحفظة من الـ AutoDispose Provider
    final walletForm = ref.watch(walletFormProvider);

    return Form(
      key: walletForm.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            onPressed: isLoading
                ? null
                : () {
                    if (walletForm.formKey.currentState!.validate()) {
                      // تنفيذ الدفع باستراتيجية المحفظة الإلكترونية
                      ref.read(checkoutProvider.notifier).executePayment(
                            WalletPaymentStrategy(
                              phoneNumber: walletForm.phone.text,
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
                : const Text('طلب كود التأكيد (OTP)'),
          ),
        ],
      ),
    );
  }
}