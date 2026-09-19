import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payment_gateways/features/checkout/data/models/card_input_model.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_notifier.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_state.dart';
import 'package:payment_gateways/features/checkout/presentation/screens/3ds_screen.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/card_input_formatter.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
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
    final cardInput = CardInputModel(
      cardNumber: _cardNumberController.text,
      expiryDate: _expiryController.text,
      cvv: _cvvController.text,
      cardHolderName: _nameController.text,
    );

    // استدعاء الميثود في الـ Notifier
    ref.read(checkoutProvider.notifier).payWithCard(cardInput);
  }

  @override
  Widget build(BuildContext context) {
    // 1. مراقبة التغيرات لعرض الـ SnackBars أو التنقلات (Side Effects)
    ref.listen<CheckoutState>(checkoutProvider, (previous, next) async{
      if (next is CheckoutFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } else if (next is CheckoutSuccess) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('تمت العملية بنجاح! 🎉'),
            content: Text('رقم المعاملة: ${next.transactionId}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(checkoutProvider.notifier).reset();
                },
                child: const Text('موافق'),
              ),
            ],
          ),
        );
      } else if (next is Checkout3DSRequired) {
        // هنا نفتح WebView للتأكيد المالي
       final bool? isApproved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (ctx) => ThreeDSWebViewPage(redirectUrl: next.redirectUrl),
      ),
    );

    // إرسال نتيجة الـ WebView للـ Notifier لتحديث الـ State
    if (mounted) {
      ref.read(checkoutProvider.notifier).complete3DSPayment(
            isApproved: isApproved ?? false,
          );
    }
  
      }
    });

    // 2. قراءة الحالة الحالية لتشكيل الـ UI
    final state = ref.watch(checkoutProvider);
    final isLoading = state is CheckoutLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('شاشة الدفع - Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // حقل رقم الكارت
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                maxLength: 19,
                decoration: const InputDecoration(
                  labelText: 'رقم البطاقة',
                  hintText: 'xxxx xxxx xxxx xxxx',
                  prefixIcon: Icon(Icons.credit_card),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // حقل تاريخ الانتهاء
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
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
                  // حقل الـ CVV
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
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

              // حقل اسم صاحب الكارت
              TextField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: 'اسم صاحب البطاقة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // زر الدفع
              ElevatedButton(
                onPressed: isLoading ? null : _submitPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'ادفع الآن',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}