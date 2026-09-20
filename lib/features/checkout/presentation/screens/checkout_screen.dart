import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_gateways/features/checkout/data/models/card_input_model.dart';
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

// ==========================================
// 2. CHECKOUT PAGE (MAIN UI)
// ==========================================
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submitPayment() {
    // إخفاء أي لوحة مفاتيح أو فوكس
    FocusScope.of(context).unfocus();

    final cardInput = CardInputModel(
      cardNumber: _cardNumberController.text,
      expiryDate: _expiryController.text,
      cvv: _cvvController.text,
      cardHolderName: _nameController.text,
    );

    ref.read(checkoutProvider.notifier).payWithCard(cardInput);
  }

  void _clearForm() {
    _cardNumberController.clear();
    _expiryController.clear();
    _cvvController.clear();
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutProvider);
    final isLoading = state is CheckoutLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('شاشة الدفع - Checkout'),
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
                  const Icon(
                    Icons.payment,
                    size: 64,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 20),

                  // عرض رسالة الخطأ لو الـ State فشلت
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

                  // عرض كارت النجاح لو العملية نجحت
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
                            'تمت العملية بنجاح! 🎉',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          const SizedBox(height: 4),
                          Text('رقم المعاملة: ${state.transactionId}'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              _clearForm();
                              ref.read(checkoutProvider.notifier).reset();
                            },
                            child: const Text('إجراء عملية جديدة'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // عرض زر التحويل للـ 3DS لو مطلوبة
                  if (state is Checkout3DSRequired) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.security, color: Colors.orange, size: 48),
                          const SizedBox(height: 8),
                          const Text(
                            'مطلوب تأكيد البنك (3D Secure)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                            onPressed: () async {
                              final bool? isApproved = await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (ctx) => ThreeDSWebViewPage(redirectUrl: state.redirectUrl),
                                ),
                              );
                              if (mounted) {
                                ref.read(checkoutProvider.notifier).complete3DSPayment(
                                      isApproved: isApproved ?? false,
                                    );
                              }
                            },
                            child: const Text('افتح صفحة التأكيد الآن'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 1. حقل رقم الكارت
                  TextField(
                    controller: _cardNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 19,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'رقم البطاقة',
                      hintText: '4242 4242 4242 2222',
                      prefixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. حقول تاريخ الانتهاء والـ CVV
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _expiryController,
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          enabled: !isLoading,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CardExpiryInputFormatter(),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'تاريخ الانتهاء',
                            hintText: 'MM/YY',
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

                  // 3. حقل اسم صاحب الكارت
                  TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'اسم صاحب البطاقة',
                      hintText: 'Ahmed Mahmoud',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. زر الدفع
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
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'ادفع الآن',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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