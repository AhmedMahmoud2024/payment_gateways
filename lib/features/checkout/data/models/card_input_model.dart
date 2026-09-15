class CardInputModel {
  final String cardNumber;
  final String expiryDate;
  final String cvv;
  final String cardHolderName;

  CardInputModel({
    required this.cardNumber,
     required this.expiryDate,
      required this.cvv,
       required this.cardHolderName
       });

    String  get  rawCardNumber =>cardNumber.replaceAll(
      RegExp(r'\s+|-'), ''
      );
}