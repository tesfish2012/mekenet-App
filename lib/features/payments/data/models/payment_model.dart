class PaymentModel {
  final int id;
  final int insuranceId;
  final String? insuranceNumber;
  final String? policyTitle;
  final String? paymentDate;
  final double amount;
  final String? paymentType;
  final String? transactionId;
  final String status;
  final String? receiptFile;
  final String? notes;

  const PaymentModel({
    required this.id,
    this.insuranceId = 0,
    this.insuranceNumber,
    this.policyTitle,
    this.paymentDate,
    this.amount = 0.0,
    this.paymentType,
    this.transactionId,
    this.status = 'PENDING',
    this.receiptFile,
    this.notes,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: _toInt(json['id']),
      insuranceId: _toInt(json['insuranceId']),
      insuranceNumber: json['insuranceNumber'] as String?,
      policyTitle: json['policyTitle'] as String?,
      paymentDate: json['paymentDate'] as String?,
      amount: _toDouble(json['amount']),
      paymentType: json['paymentType'] as String?,
      transactionId: json['transactionId'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      receiptFile: json['receiptFile'] as String?,
      notes: json['notes'] as String?,
    );
  }

  static int _toInt(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);
  static double _toDouble(dynamic v) =>
      v == null ? 0.0 : (v is double ? v : double.tryParse(v.toString()) ?? 0.0);
}
