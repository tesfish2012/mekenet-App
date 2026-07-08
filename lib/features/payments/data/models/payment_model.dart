import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_model.freezed.dart';
part 'payment_model.g.dart';

@freezed
class PaymentModel with _$PaymentModel {
  const factory PaymentModel({
    required int id,
    @Default(0) int insuranceId,
    String? insuranceNumber,
    String? policyTitle,
    String? paymentDate,
    @Default(0.0) double amount,
    String? paymentType,
    String? transactionId,
    @Default('PENDING') String status,
    String? receiptFile,
    String? notes,
  }) = _PaymentModel;

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);
}
