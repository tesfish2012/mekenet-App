class InsuranceDocumentModel {
  final int id;
  final int insuranceId;
  final String? insuranceNumber;
  final String documentType;
  final String filePath;
  final String? originalName;
  final int? fileSize;
  final String status;
  final String? createdAt;

  const InsuranceDocumentModel({
    required this.id,
    this.insuranceId = 0,
    this.insuranceNumber,
    this.documentType = '',
    this.filePath = '',
    this.originalName,
    this.fileSize,
    this.status = 'PENDING',
    this.createdAt,
  });

  factory InsuranceDocumentModel.fromJson(Map<String, dynamic> json) {
    return InsuranceDocumentModel(
      id: json['id'] as int? ?? 0,
      insuranceId: json['insuranceId'] as int? ?? 0,
      insuranceNumber: json['insuranceNumber'] as String?,
      documentType: json['documentType'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      originalName: json['originalName'] as String?,
      fileSize: json['fileSize'] as int?,
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] as String?,
    );
  }

  InsuranceDocumentModel copyWith({
    int? id,
    int? insuranceId,
    String? insuranceNumber,
    String? documentType,
    String? filePath,
    String? originalName,
    int? fileSize,
    String? status,
    String? createdAt,
  }) {
    return InsuranceDocumentModel(
      id: id ?? this.id,
      insuranceId: insuranceId ?? this.insuranceId,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      documentType: documentType ?? this.documentType,
      filePath: filePath ?? this.filePath,
      originalName: originalName ?? this.originalName,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
