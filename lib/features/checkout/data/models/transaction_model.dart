import 'package:hive/hive.dart';

part  'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
    @HiveField(0)
    final String id;

     @HiveField(1)
    final  double amount ;

     @HiveField(2)
    final String type;  //withdraw or transfer
    
     @HiveField(3)
    final String timestamp;

  TransactionModel({
    required this.id,
     required this.amount,
      required this.type,
       required this.timestamp
       });
    
}