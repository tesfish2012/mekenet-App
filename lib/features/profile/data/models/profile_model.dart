class CustomerProfileModel {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? profileUrl;
  final String role;
  final String? dob;
  final String? gender;
  final String? maritalStatus;
  final String? bloodGroup;
  final double? height;
  final double? weight;
  final int? age;
  final String? customerCode;
  final String? city;
  final String? state;
  final String? country;
  final String? address;

  const CustomerProfileModel({
    this.id,
    this.name = '',
    this.email = '',
    this.phone,
    this.profileUrl,
    this.role = 'CUSTOMER',
    this.dob,
    this.gender,
    this.maritalStatus,
    this.bloodGroup,
    this.height,
    this.weight,
    this.age,
    this.customerCode,
    this.city,
    this.state,
    this.country,
    this.address,
  });

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      profileUrl: json['profile'] as String? ?? json['profileUrl'] as String?,
      role: json['role'] as String? ?? 'CUSTOMER',
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      height: _toDouble(json['height']),
      weight: _toDouble(json['weight']),
      age: json['age'] as int?,
      customerCode: json['customerCode'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      address: json['address'] as String?,
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    return double.tryParse(v.toString());
  }
}

class UpdateProfileRequest {
  final String? name;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? maritalStatus;
  final String? bloodGroup;
  final double? height;
  final double? weight;
  final String? city;
  final String? state;
  final String? country;
  final String? address;

  const UpdateProfileRequest({
    this.name,
    this.phone,
    this.dob,
    this.gender,
    this.maritalStatus,
    this.bloodGroup,
    this.height,
    this.weight,
    this.city,
    this.state,
    this.country,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (phone != null) map['phone'] = phone;
    if (dob != null) map['dob'] = dob;
    if (gender != null) map['gender'] = gender;
    if (maritalStatus != null) map['maritalStatus'] = maritalStatus;
    if (bloodGroup != null) map['bloodGroup'] = bloodGroup;
    if (height != null) map['height'] = height;
    if (weight != null) map['weight'] = weight;
    if (city != null) map['city'] = city;
    if (state != null) map['state'] = state;
    if (country != null) map['country'] = country;
    if (address != null) map['address'] = address;
    return map;
  }
}
