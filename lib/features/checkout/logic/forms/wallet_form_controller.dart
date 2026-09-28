import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 2. Wallet Form Controllers Class
class WalletFormControllers {
  final phone = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void dispose() {
    phone.dispose();
  }
}

/// Provider خاص بالمحفظة الإلكترونية
final walletFormProvider = Provider.autoDispose<WalletFormControllers>((ref) {
  final controllers = WalletFormControllers();
  ref.onDispose(() => controllers.dispose());
  return controllers;
});