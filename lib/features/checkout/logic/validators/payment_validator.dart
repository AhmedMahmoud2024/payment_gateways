class PaymentValidators {
  static String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم البطاقة';
    }
    final cleanValue = value.replaceAll(' ', '');
    if (cleanValue.length < 16) {
      return 'رقم البطاقة يجب أن يتكون من 16 رقم';
    }
    return null;
  }

  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال تاريخ الانتهاء';
    }
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
      return 'الصيغة غير صحيحة (MM/YY)';
    }
    return null;
  }

  static String? validateCVC(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال CVC';
    }
    if (value.length < 3) {
      return 'يجب أن يكون 3 أرقام';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الهاتف';
    }
    if (!RegExp(r'^01[0125]\d{8}$').hasMatch(value)) {
      return 'رقم هاتف مصري غير صحيح';
    }
    return null;
  }

static String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'يرجى إدخال البريد الإلكتروني';
  }
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
    return 'بريد إلكتروني غير صحيح';
  }
  return null;
}
}

