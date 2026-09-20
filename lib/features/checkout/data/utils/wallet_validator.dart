class WalletValidator{
 static bool  isValidEgyptianPhone(String phone){
  final clean = phone.replaceAll(RegExp(r'\D'), '').trim();
  final phoneRegex = RegExp(r'^01[0125]\d{8}$');
  return phoneRegex.hasMatch(clean);
 }
}