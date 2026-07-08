import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_model.freezed.dart';
part 'profile_model.g.dart';

@freezed
class CustomerProfileModel with _$CustomerProfileModel {
  const factory CustomerProfileModel({
    int? id,
    @Default('') String name,
    @Default('') String email,
    String? phone,
    String? profileUrl,
    @Default('CUSTOMER') String role,
    String? dob,
    String? gender,
    String? maritalStatus,
    String? bloodGroup,
    double? height,
    double? weight,
    int? age,
    String? customerCode,
    String? city,
    String? state,
    String? country,
    String? address,
  }) = _CustomerProfileModel;

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerProfileModelFromJson(json);
}

@freezed
class UpdateProfileRequest with _$UpdateProfileRequest {
  const factory UpdateProfileRequest({
    String? name,
    String? phone,
    String? dob,
    String? gender,
    String? maritalStatus,
    String? bloodGroup,
    double? height,
    double? weight,
    String? city,
    String? state,
    String? country,
    String? address,
  }) = _UpdateProfileRequest;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);
}
