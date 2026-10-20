import 'package:payment_gateways/features/checkout/data/models/erp_journal_entry_model.dart';

abstract class ErpIntegrationRepository {
Future<String> postJournalEntry(ErpJournalEntryModel entry);
}

class MockErpIntegrationRepository implements ErpIntegrationRepository{
  @override
  Future<String> postJournalEntry(ErpJournalEntryModel entry)async {
  // محاكاة تأخير طلب الشبكة (API Request إلى نظام الـ ERP مثل Odoo أو SAP)
    await Future.delayed(const Duration(seconds: 1));
    // ignore: avoid_print
    print("🚀 [ERP System]: تم تسحيل القيد بنجاح برقم ${entry.entryId} بقيمة ${entry.amount} EGP");
   return "تم الترحيل بنجاح للـ ERP برقم قيد: ${entry.entryId}";
  }
  
}