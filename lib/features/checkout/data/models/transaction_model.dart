import 'package:hive/hive.dart';

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

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 0;

  @override
  TransactionModel read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final fieldCount = reader.readByte();
    for (var i = 0; i < fieldCount; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return TransactionModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      type: fields[2] as String,
      timestamp: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.timestamp);
  }
}