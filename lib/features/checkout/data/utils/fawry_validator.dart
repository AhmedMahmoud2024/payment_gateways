class FawryValidator {
 static bool  isValidEmail(String email){
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email.trim());
 }

 static bool isValidPhone(String phone){
  final phoneRegex = RegExp(r'^01[0125]\d{8}$');
  return phoneRegex.hasMatch(phone.trim());
 }
}