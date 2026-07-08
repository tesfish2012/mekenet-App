import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_model.freezed.dart';
part 'document_model.g.dart';

@freezed
class InsuranceDocumentModel with _$InsuranceDocumentModel {
  const factory InsuranceDocumentModel({
    required int id,
    @Default(0) int insuranceId,
    String? insuranceNumber,
    @Default('') String documentType,
    @Default('') String filePath,
    String? originalName,
    int? fileSize,
    @Default('PENDING') String status,
    String? createdAt,
  }) = _InsuranceDocumentModel;

  factory InsuranceDocumentModel.fromJson(Map<String, dynamic> json) =>
      _$InsuranceDocumentModelFromJson(json);
}
