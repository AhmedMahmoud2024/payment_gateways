import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_notifier.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_state.dart';
import 'package:payment_gateways/features/checkout/logic/forms/checkout_form_controllers.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/checkout_feedback_card.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/forms/card_payment_form.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/forms/fawry_payment_form.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/forms/wallet_payment_form.dart';


class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(checkoutProvider);
    final isLoading = state is CheckoutLoading;
    final otpController = ref.watch(otpControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام عملية الدفع'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // كارت إظهار النتيجة أو الحالات الحالية (OTP, Success, Error)
            CheckoutFeedbackCard(
              state: state,
              otpController: otpController,
              onReset: () => ref.read(checkoutProvider.notifier).reset(),
            ),

            // TabBar لتنقل بين طرق الدفع
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.credit_card), text: 'بطاقة'),
                      Tab(icon: Icon(Icons.account_balance_wallet), text: 'محفظة'),
                      Tab(icon: Icon(Icons.receipt), text: 'فوري'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 350,
                    child: TabBarView(
                      children: [
                        CardCheckoutForm(isLoading: isLoading),
                        WalletCheckoutForm(isLoading: isLoading),
                        FawryCheckoutForm(isLoading: isLoading),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}