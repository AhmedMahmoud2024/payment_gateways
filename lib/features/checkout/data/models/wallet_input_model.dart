class WalletInputModel{
final String phoneNumber;

const WalletInputModel({required this.phoneNumber});

String get cleanPhoneNumber()=> phoneNumber.replaceAll(RegExp(r'\D'), '').trim();
}