import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



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