import 'package:local_auth/local_auth.dart';

abstract class BiometricService {
  Future<bool> authenticateUser();
}

class BiometricServiceImpl implements BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  Future<bool> authenticateUser() async {
    try {
      // 1. التأكد هل الجهاز يدعم البصمة وتم إعدادها عليه أم لا
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        // لو الجهاز لا يدعم البصمة، ممكن نسمح بالدفع أو نرفض حسب سياسة التطبيق
        return true; 
      }

      // 2. طلب فتح نافذة البصمة من النظام
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'يرجى تأكيد بصمة الإصبع لإتمام عملية الدفع بأمان',
    
          biometricOnly: false, // السماح ببدائل أخرى مثل PIN الهاتف لو البصمة مشكلة
          sensitiveTransaction: true,
      );

      return didAuthenticate;
    } catch (e) {
      print("Biometric Error: $e");
      return false;
    }
  }
}