
class BillData {
  final String billNo;
  final String senderName;
  final String senderAddress;
  final String recipientName;
  final String recipientAddress;
  final String truckOwnerName;
  final String chassisNo;
  final String driver;
  final String engineNo;
  final String date;
  final String truckNo;
  final String fromWhere;
  final String tillWhere;
  final String bankName;
  final String accountName;
  final String accountNo;
  final String ifscCode;

  BillData({
    required this.billNo,
    required this.senderName,
    required this.senderAddress,
    required this.recipientName,
    required this.recipientAddress,
    required this.truckOwnerName,
    required this.chassisNo,
    required this.driver,
    required this.engineNo,
    required this.date,
    required this.truckNo,
    required this.fromWhere,
    required this.tillWhere,
    required this.bankName,
    required this.accountName,
    required this.accountNo,
    required this.ifscCode,
  });
}
