class CardValidator {
 static bool isValidCardNumber(String cardNumber){
  final cleanNumber = cardNumber.replaceAll(
      RegExp(r'\s+|-'), ''
      );
   if(cleanNumber.isEmpty || cleanNumber.length<13 ||cleanNumber.length >19){
    return false;
   }
   int sum = 0;
   bool isSecondDigit= false;
   for(int i=cleanNumber.length-1; i>0;i--){
    int digit= int.tryParse(cleanNumber[i]) ?? -1;
    if(digit==-1) return false;
     if(isSecondDigit){
      digit *=2;
      if(digit>9){
        digit -=9;
      }
     }
     sum +=digit;
     isSecondDigit = !isSecondDigit;
      }
      return sum % 10 ==0;

 }
}