import 'package:hive/hive.dart';
import 'package:payment_gateways/features/checkout/data/models/transaction_model.dart';

abstract class DigitalWalletLocalDatatSource{
 Future<void>  cacheTransaction(TransactionModel transaction);
 List<TransactionModel> getCachedTransaction();
}

class DigitalWalletLocalDataSourceImpl implements DigitalWalletLocalDatatSource{
  final Box<TransactionModel> transactionBox;

  DigitalWalletLocalDataSourceImpl(this.transactionBox);

  @override
  Future<void> cacheTransaction(TransactionModel transaction) async{
    await transactionBox.add(transaction);
  }

  @override
  List<TransactionModel> getCachedTransaction() {
    return transactionBox.values.toList();
   
  }
  
}