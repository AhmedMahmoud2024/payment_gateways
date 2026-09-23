import 'package:flutter/material.dart';

enum PaymentMethodType{ card,wallet,fawry}
class PaymentMethodSelector extends StatelessWidget{
  final PaymentMethodType selectedMethod;
  final ValueChanged<PaymentMethodType> onMethodChanged;

  const PaymentMethodSelector({
    super.key,
   required this.selectedMethod,
    required this.onMethodChanged});
  @override
  Widget build(BuildContext context) {
  return   SegmentedButton<PaymentMethodType>(
                    segments: const [
                      ButtonSegment(
                        value: PaymentMethodType.card,
                        label: Text('بطاقة'),
                        icon: Icon(Icons.credit_card),
                      ),
                      ButtonSegment(
                        value: PaymentMethodType.wallet,
                        label: Text('محفظة'),
                        icon: Icon(Icons.account_balance_wallet),
                      ),
                      ButtonSegment(
                        value: PaymentMethodType.fawry,
                        label: Text('فوري'),
                        icon: Icon(Icons.store),
                      ),
                    ],
                    selected: {selectedMethod},
                    onSelectionChanged: (Set<PaymentMethodType> selection) {
                      onMethodChanged(selection.first);
                    },
                  );  
  
                    }
                    }