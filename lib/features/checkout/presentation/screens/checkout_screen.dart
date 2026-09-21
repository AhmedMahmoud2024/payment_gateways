import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_gateways/features/checkout/data/models/card_input_model.dart';
import 'package:payment_gateways/features/checkout/data/models/wallet_input_model.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_notifier.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_state.dart';
import 'package:payment_gateways/features/checkout/presentation/screens/3ds_screen.dart';

// ==========================================
// 1. INPUT FORMATTER (تاريخ الانتهاء MM/YY)
// ==========================================
class CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;

    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}


enum PaymentMethodType { card, wallet }

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  PaymentMethodType _selectedMethod = PaymentMethodType.card;

  // Controllers للكارت
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  // Controllers للمحفظة والـ OTP
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _submitPayment() {
    FocusScope.of(context).unfocus();

    if (_selectedMethod == PaymentMethodType.card) {
      final cardInput = CardInputModel(
        cardNumber: _cardNumberController.text,
        expiryDate: _expiryController.text,
        cvv: _cvvController.text,
        cardHolderName: _nameController.text,
      );
      ref.read(checkoutProvider.notifier).payWithCard(cardInput);
    } else {
      final walletInput = WalletInputModel(
        phoneNumber: _phoneController.text,
      );
      ref.read(checkoutProvider.notifier).payWithWallet(walletInput);
    }
  }

  void _clearAllInputs() {
    _cardNumberController.clear();
    _expiryController.clear();
    _cvvController.clear();
    _nameController.clear();
    _phoneController.clear();
    _otpController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutProvider);
    final isLoading = state is CheckoutLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('بوابة الدفع'),
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
                  // 1. Selector Tabs
                  SegmentedButton<PaymentMethodType>(
                    segments: const [
                      ButtonSegment(
                        value: PaymentMethodType.card,
                        label: Text('بطاقة ائتمان'),
                        icon: Icon(Icons.credit_card),
                      ),
                      ButtonSegment(
                        value: PaymentMethodType.wallet,
                        label: Text('محفظة إلكترونية'),
                        icon: Icon(Icons.account_balance_wallet),
                      ),
                    ],
                    selected: {_selectedMethod},
                    onSelectionChanged: (Set<PaymentMethodType> selection) {
                      setState(() {
                        _selectedMethod = selection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // 2. Feedback Containers (Errors / Success / OTP)
                  if (state is CheckoutFailure) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (state is CheckoutSuccess) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
                          const SizedBox(height: 8),
                          const Text(
                            'تمت العملية بنجاح!',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          const SizedBox(height: 4),
                          Text('رقم المعاملة: ${state.transactionId}'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              _clearAllInputs();
                              ref.read(checkoutProvider.notifier).reset();
                            },
                            child: const Text('إجراء عملية جديدة'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (state is CheckoutOTPRequired) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.phonelink_ring, color: Colors.blue, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            'تم إرسال رمز OTP إلى: ${state.phoneNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            decoration: const InputDecoration(
                              labelText: 'رمز OTP (أدخل 1234)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    ref.read(checkoutProvider.notifier).submitOTP(_otpController.text);
                                  },
                            child: const Text('تأكيد الرمز'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 3. Conditional Form Fields
                  if (_selectedMethod == PaymentMethodType.card) ...[
                    TextField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      maxLength: 19,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'رقم البطاقة',
                        hintText: '4242 4242 4242 1111',
                        prefixIcon: Icon(Icons.credit_card),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _expiryController,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            enabled: !isLoading,
                            decoration: const InputDecoration(
                              labelText: 'تاريخ الانتهاء',
                              hintText: '12/28',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _cvvController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: true,
                            enabled: !isLoading,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              hintText: '123',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'اسم صاحب البطاقة',
                        hintText: 'Ahmed Mahmoud',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'رقم المحفظة الإلكترونية',
                        hintText: '01012345678 (تنتهي بـ 0000 لطلب OTP)',
                        prefixIcon: Icon(Icons.phone_android),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 4. Submit Button
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
                            _selectedMethod == PaymentMethodType.card ? 'ادفع الآن' : 'تأكيد ودفع بالمحفظة',
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