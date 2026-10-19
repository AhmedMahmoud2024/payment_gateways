// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_notifier.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_state.dart';

import 'package:payment_gateways/features/checkout/logic/forms/otp_form_controller.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/checkout_feedback_card.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/forms/card_payment_form.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/forms/digital_wallet_payment_form.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/forms/fawry_payment_form.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/forms/wallet_payment_form.dart';

// 🚀 استيراد شاشة أو فورم المحفظة الرقمية الداخلية الجديدة التي أنشأناها


class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

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

            const SizedBox(height: 16),

            // TabBar لتنقل بين طرق الدفع (تم زيادة الـ length إلى 4 لإضافة المحفظة الرقمية)
            DefaultTabController(
              length: 4, // 👈 تم التعديل لإضافة التبويبة الرابعة
              child: Column(
                children: [
                  const TabBar(
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    isScrollable: true, // ميزة إضافية لضمان عدم ازدحام الشاشة لو الأجهزة صغيرة
                    tabs: [
                      Tab(icon: Icon(Icons.credit_card), text: 'بطاقة'),
                      Tab(icon: Icon(Icons.account_balance_wallet), text: 'محفظة'),
                      Tab(icon: Icon(Icons.receipt), text: 'فوري'),
                      Tab(icon: Icon(Icons.account_balance), text: 'رصيد المحفظة'), // 👈 التبويبة الجديدة
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 380, // زيادة طفيفة لاحتواء حقل المبلغ وزر الدفع الجديد
                    child: TabBarView(
                      children: [
                        CardCheckoutForm(isLoading: isLoading),
                        WalletCheckoutForm(isLoading: isLoading),
                        FawryCheckoutForm(isLoading: isLoading),
                         DigitalWalletPaymentForm(), // 👈 الـ Form الخاصة بالـ Digital Wallet Strategy
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

/*
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_notifier.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_state.dart';

import 'package:payment_gateways/features/checkout/logic/forms/otp_form_controller.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/checkout_feedback_card.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/forms/card_payment_form.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/forms/fawry_payment_form.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/forms/wallet_payment_form.dart';


class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

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
*/