import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/card_input_model.dart';
import '../../data/models/fawry_input_model.dart';
import '../../data/models/wallet_input_model.dart';
import '../../logic/checkout_notifier.dart';
import '../../logic/checkout_state.dart';
import '../widgets/checkout_feedback_card.dart';
import '../widgets/forms/card_payment_form.dart';
import '../widgets/forms/fawry_payment_form.dart';
import '../widgets/forms/wallet_payment_form.dart';
import '../widgets/payment_method_selector.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  PaymentMethodType _selectedMethod = PaymentMethodType.card;

  // Controllers البطاقة
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  // Controllers المحفظة والـ OTP
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  // Controllers فوري
  final _fawryPhoneController = TextEditingController();
  final _fawryEmailController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _fawryPhoneController.dispose();
    _fawryEmailController.dispose();
    super.dispose();
  }

  void _submitPayment() {
    FocusScope.of(context).unfocus();

    if (_selectedMethod == PaymentMethodType.card) {
      ref.read(checkoutProvider.notifier).payWithCard(
            CardInputModel(
              cardNumber: _cardNumberController.text,
              expiryDate: _expiryController.text,
              cvv: _cvvController.text,
              cardHolderName: _nameController.text,
            ),
          );
    } else if (_selectedMethod == PaymentMethodType.wallet) {
      ref.read(checkoutProvider.notifier).payWithWallet(
            WalletInputModel(phoneNumber: _phoneController.text),
          );
    } else if (_selectedMethod == PaymentMethodType.fawry) {
      ref.read(checkoutProvider.notifier).payWithFawry(
            FawryInputModel(
              phoneNumber: _fawryPhoneController.text,
              email: _fawryEmailController.text,
            ),
          );
    }
  }

  void _clearAllInputs() {
    _cardNumberController.clear();
    _expiryController.clear();
    _cvvController.clear();
    _nameController.clear();
    _phoneController.clear();
    _otpController.clear();
    _fawryPhoneController.clear();
    _fawryEmailController.clear();
    ref.read(checkoutProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutProvider);
    final isLoading = state is CheckoutLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('بوابة الدفع الإلكتروني'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Selector
                  PaymentMethodSelector(
                    selectedMethod: _selectedMethod,
                    onMethodChanged: (method) {
                      setState(() {
                        _selectedMethod = method;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // 2. Feedback Card (Result Status)
                  CheckoutFeedbackCard(
                    state: state,
                    otpController: _otpController,
                    onReset: _clearAllInputs,
                  ),

                  // 3. Dynamic Form rendering
                  if (_selectedMethod == PaymentMethodType.card)
                    CardPaymentForm(
                      cardNumberController: _cardNumberController,
                      expiryController: _expiryController,
                      cvvController: _cvvController,
                      nameController: _nameController,
                      isLoading: isLoading,
                    )
                  else if (_selectedMethod == PaymentMethodType.wallet)
                    WalletPaymentForm(
                      phoneController: _phoneController,
                      isLoading: isLoading,
                    )
                  else if (_selectedMethod == PaymentMethodType.fawry)
                    FawryPaymentForm(
                      phoneController: _fawryPhoneController,
                      emailController: _fawryEmailController,
                      isLoading: isLoading,
                    ),

                  const SizedBox(height: 24),

                  // 4. Action Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _submitPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _selectedMethod == PaymentMethodType.card
                                ? 'ادفع الآن'
                                : _selectedMethod == PaymentMethodType.wallet
                                    ? 'تأكيد ودفع بالمحفظة'
                                    : 'إصدار كود فوري',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}