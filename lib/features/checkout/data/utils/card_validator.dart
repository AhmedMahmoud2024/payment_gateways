class CardValidator {
  
  // 1. خوارزمية Luhn Algorithm
  static bool isValidCardNumber(String cardNumber) {
    // تنظيف الرقم من المسافات
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '').trim();
    
    if (cleanNumber.isEmpty || cleanNumber.length < 13 || cleanNumber.length > 19) {
      return false;
    }

    int sum = 0;
    bool isSecondDigit = false;

    // البدء من خانة الأحوال من اليمين إلى اليسار
    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.tryParse(cleanNumber[i]) ?? -1;
      if (digit == -1) return false; // لو فيه أي حرف مش رقم

      if (isSecondDigit) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isSecondDigit = !isSecondDigit;
    }

    return sum % 10 == 0;
  }

  // 2. التحقق من تاريخ الانتهاء (MM/YY)
  static bool isValidExpiryDate(String expiry) {
    if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(expiry)) {
      return false;
    }

    final parts = expiry.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse('20${parts[1]}'); // تحويل YY إلى YYYY

    final now = DateTime.now();
    final cardDate = DateTime(year, month + 1, 0); // آخر يوم في الشهر المحدد

    return cardDate.isAfter(now);
  }

  // 3. التحقق من الـ CVV
  static bool isValidCVV(String cvv) {
    return RegExp(r'^[0-9]{3,4}$').hasMatch(cvv);
  }
}