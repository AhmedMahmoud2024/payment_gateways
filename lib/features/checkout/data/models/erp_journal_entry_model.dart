class ErpJournalEntryModel {
  final String entryId;
  final String transactionId;
  final double amount;
  final String debitAccount;
  final String creditAccount;
  final DateTime timestamp;

  ErpJournalEntryModel({
    required this.entryId;
    required this.transactionId;
    required this.amount; 
     required this.debitAccount;
      required this.creditAccount;
       required this.timestamp;
  });
}