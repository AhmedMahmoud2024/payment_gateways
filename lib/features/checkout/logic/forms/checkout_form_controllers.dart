import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1. Card Form Controllers Class
class CardFormControllers {
  final cardNumber = TextEditingController();
  final expiryDate = TextEditingController();
  final cvc = TextEditingController();
  final cardHolderName = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void dispose() {
    cardNumber.dispose();
    expiryDate.dispose();
    cvc.dispose();
    cardHolderName.dispose();
  }
}

/// Provider خاص ببطاقة الائتمان (ينظف نفسه تلقائياً)
final cardFormProvider = Provider.autoDispose<CardFormControllers>((ref) {
  final controllers = CardFormControllers();
  ref.onDispose(() => controllers.dispose());
  return controllers;
});

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

/// 3. OTP Controller
final otpControllerProvider = Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

/// Fawry Form Controllers Class
class FawryFormControllers {
  final phone = TextEditingController();
  final email = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void dispose() {
    phone.dispose();
    email.dispose();
  }
}

/// Provider خاص بـ فوري
final fawryFormProvider = Provider.autoDispose<FawryFormControllers>((ref) {
  final controllers = FawryFormControllers();
  ref.onDispose(() => controllers.dispose());
  return controllers;
});