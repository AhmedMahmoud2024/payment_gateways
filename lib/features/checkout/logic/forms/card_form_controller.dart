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
