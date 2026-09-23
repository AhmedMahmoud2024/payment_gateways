import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/checkout_notifier.dart';
import '../../logic/checkout_state.dart';

class CheckoutFeedbackCard extends ConsumerWidget {
  final CheckoutState state;
  final TextEditingController otpController;
  final VoidCallback onReset;

  const CheckoutFeedbackCard({
    super.key,
    required this.state,
    required this.otpController,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = state is CheckoutLoading;

    // استخدام الـ Pattern Matching مع الـ sealed class
    return switch (state) {
      CheckoutInitial() => const SizedBox.shrink(),
      CheckoutLoading() => const SizedBox.shrink(),

      // Destructuring المباشر للقيم جوه الحالة!
      CheckoutFailure(:final errorMessage) => Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
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
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),

      CheckoutSuccess(:final transactionId) => Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
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
              Text('رقم المعاملة: $transactionId'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onReset,
                child: const Text('إجراء عملية جديدة'),
              ),
            ],
          ),
        ),

      CheckoutOTPRequired(:final phoneNumber) => Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
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
                'تم إرسال رمز OTP إلى: $phoneNumber',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: otpController,
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
                        ref.read(checkoutProvider.notifier).submitOTP(otpController.text);
                      },
                child: const Text('تأكيد الرمز'),
              ),
            ],
          ),
        ),

      Checkout3DSRequired(:final redirectUrl) => Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Text('جاري التحويل للتحقق 3DS: $redirectUrl'),
        ),

      CheckoutFawryCodeGenerated(:final referenceNumber, :final expireTime) => Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade400),
          ),
          child: Column(
            children: [
              const Icon(Icons.receipt_long, color: Colors.amber, size: 48),
              const SizedBox(height: 8),
              const Text(
                'كود الدفع عبر فوري',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText(
                referenceNumber,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text('صالح لمدة: $expireTime'),
              const SizedBox(height: 4),
              const Text(
                'يرجى التوجه لأقرب منفذ فوري وسداد المبلغ باستخدام الرقم المرجعي أعلاه.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onReset,
                child: const Text('عملية جديدة'),
              ),
            ],
          ),
        ),
    };
  }
}