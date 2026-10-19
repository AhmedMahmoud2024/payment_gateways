import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:payment_gateways/features/checkout/data/repositories/mock_digital_wallet_repository.dart';
import 'package:payment_gateways/features/checkout/logic/checkout_notifier.dart';
import 'package:payment_gateways/features/checkout/logic/strategies/digital_wallet_strategy.dart';

// تعريف الـ Providers المحلية
final walletRepoProvider = Provider<DigitalWalletRepository>((ref) => MockDigitalWalletRepository());

// StateProvider لحفظ حالة الرصيد (هل تم الاستعلام عنه ولا لسه؟ وقيمته كام)
final walletBalanceStateProvider = StateProvider.autoDispose<double?>((ref) => null);
final isCheckingBalanceProvider = StateProvider.autoDispose<bool>((ref) => false);

class DigitalWalletPaymentForm extends ConsumerStatefulWidget {
  const DigitalWalletPaymentForm({super.key});

  @override
  ConsumerState<DigitalWalletPaymentForm> createState() => _DigitalWalletPaymentFormState();
}

class _DigitalWalletPaymentFormState extends ConsumerState<DigitalWalletPaymentForm> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // مراقبة قيمة الرصيد الحالي وحالة التحميل للرصيد
    final currentBalance = ref.watch(walletBalanceStateProvider);
    final isChecking = ref.watch(isCheckingBalanceProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'الدفع من رصيد المحفظة الداخلية',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          // 1. زرار "معرفة الرصيد" (الذي يضغط عليه المستخدم أولاً)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: isChecking
                ? null
                : () async {
                    ref.read(isCheckingBalanceProvider.notifier).state = true;
                    // محاكاة جلب الرصيد من الـ Repository
                    final repo = ref.read(walletRepoProvider);
                    final wallet = await repo.getWalletBalance();
                    
                    // تحديث الحالة بالرصيد المستعلم
                    ref.read(walletBalanceStateProvider.notifier).state = wallet.balance;
                    ref.read(isCheckingBalanceProvider.notifier).state = false;
                  },
            icon: const Icon(Icons.visibility),
            label: Text(isChecking ? 'جاري الاستعلام...' : 'اضغط لمعرفة الرصيد المتاح'),
          ),

          const SizedBox(height: 12),

          // 2. عرض الرصيد لو المستخدم استعلم عنه
          if (currentBalance != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الرصيد الحالي بالمحفظة:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    '$currentBalance EGP',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // 3. حقل إدخال المبلغ المراد سحبه/دفعه
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'المبلغ المراد سحبه/دفعـه',
              border: OutlineInputBorder(),
              prefixText: 'EGP ',
            ),
          ),
          const SizedBox(height: 20),

          // 4. زر إتمام السحب والدفع
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              // شرط: هل المستخدم استعلم عن رصيده الأول ولا لسه؟
              if (currentBalance == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('من فضلك اضغط على زر "معرفة الرصيد" أولاً!'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final amount = double.tryParse(_amountController.text) ?? 0.0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('برجاء إدخال مبلغ صحيح')),
                );
                return;
              }

              // التحقق هل المبلغ أكبر من الرصيد المُستعلم عنه؟
              if (amount > currentBalance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('المبلغ المطلوب أكبر من رصيدك المتاح!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // تنفيذ عملية الدفع عبر الـ Notifier والاستراتيجية
              final repo = ref.read(walletRepoProvider);
              final strategy = DigitalWalletPaymentStrategy(repo);

              ref.read(checkoutProvider.notifier).executeDigitalWalletPayment(strategy, amount);

              // إعادة تعيين الرصيد ليحتاج استعلام جديد أو تحديثه
              ref.read(walletBalanceStateProvider.notifier).state = null;
              _amountController.clear();
            },
            child: const Text('سحب وإتمام الدفع', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}