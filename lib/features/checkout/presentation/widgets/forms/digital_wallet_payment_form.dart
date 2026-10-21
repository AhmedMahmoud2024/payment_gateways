import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_notifier.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_state.dart';
import 'package:payment_gateways/features/checkout/presentation/widgets/forms/wallet_payment_form.dart';

// تعريف الـ Providers المحلية للمحفظة والتحقق من الرصيد
final availableBalanceProvider = StateProvider<double>((ref) => 1500.0); // الرصيد الافتراضي
final isCheckingBalanceProvider = StateProvider<bool>((ref) => false);

class DigitalWalletPaymentForm extends ConsumerStatefulWidget {
  final TabController? tabController; // للاستخدام في الانتقال بين الـ Tabs

  const DigitalWalletPaymentForm({super.key, this.tabController});

  @override
  ConsumerState<DigitalWalletPaymentForm> createState() => _DigitalWalletPaymentFormState();
}

class _DigitalWalletPaymentFormState extends ConsumerState<DigitalWalletPaymentForm> {
  // حقول التحكم للإدخال
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _transferAmountController = TextEditingController();
  
  // حالة ظهور حقل التحويل
  bool isTransferMode = false;

  @override
  void dispose() {
    _amountController.dispose();
    _transferAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = ref.watch(availableBalanceProvider);
    final isChecking = ref.watch(isCheckingBalanceProvider);
     final state = ref.watch(checkoutProvider);
         final isLoading = state is CheckoutLoading;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'الدفع من رصيد المحفظة الداخلية',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 1️⃣ أولاً: زر معرفة الرصيد المتاح
          ElevatedButton.icon(
            onPressed: () {
              ref.read(isCheckingBalanceProvider.notifier).state = true;
              Future.delayed(const Duration(milliseconds: 500), () {
                ref.read(isCheckingBalanceProvider.notifier).state = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('الرصيد المتاح حالياً: $balance EGP'),
                    backgroundColor: Colors.green,
                  ),
                );
              });
            },
            icon: const Icon(Icons.account_balance_wallet),
            label: Text(isChecking ? 'جاري الاستعلام...' : 'اضغط لمعرفة الرصيد المتاح'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 20),

          // 2️⃣ ثانياً: زر وبوابات "تحويل رصيد" والشروط
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                isTransferMode = !isTransferMode;
              });
            },
            icon: const Icon(Icons.send_to_mobile),
            label: const Text('تحويل رصيد'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          if (isTransferMode) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _transferAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'أدخل مبلغ التحويل',
                hintText: 'يجب ألا يتجاوز $balance EGP',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.money),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final enteredAmount = double.tryParse(_transferAmountController.text) ?? 0.0;
                
                if (enteredAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح للتحويل'), backgroundColor: Colors.red),
                  );
                } else if (enteredAmount > balance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('عذراً، المبلغ المطلوب أكبر من الرصيد المتاح بالمحفظة!'), backgroundColor: Colors.red),
                  );
                } else {
                  // الانتقال للـ Tab الخاص بـ "محفظة" (رقم المحفظة و OTP) لو الـ TabController موجود
                 Navigator.push(
                  context,MaterialPageRoute(builder: ((context) =>  WalletCheckoutForm(isLoading: isLoading))
                 ));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
              child: const Text('الانتقال لإدخال رقم المحفظة وتأكيد OTP'),
            ),
          ],

          const Divider(height: 40, thickness: 1),

          // 3️⃣ ثالثاً: زر السحب المباشر وإتمام الدفع (الخدمة الأساسية)
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'المبلغ المراد سحبه/دفعه',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.payment),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(_amountController.text) ?? 0.0;
              if (amount <= 0 || amount > balance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تأكد من إدخال مبلغ صالح ضمن رصيدك المتاح'), backgroundColor: Colors.red),
                );
              } else {
                // تنفيذ عملية الدفع المباشر والخصم والترحيل للـ ERP
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('جاري سحب مبلغ $amount EGP وإتمام الدفع...'), backgroundColor: Colors.blue),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('سحب وإتمام الدفع', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
