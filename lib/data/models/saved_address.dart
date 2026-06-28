import 'package:my_first_app/core/network/json_utils.dart';

class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.city,
    required this.district,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String addressLine;
  final String city;
  final String district;
  final bool isDefault;

  String get fullAddress => '$addressLine, $city, $district';

  SavedAddress copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phone,
    String? addressLine,
    String? city,
    String? district,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      district: district ?? this.district,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: readString(json['id']),
      label: readString(json['label'] ?? json['title'], 'Home'),
      fullName: readString(json['full_name'] ?? json['name']),
      phone: readString(json['phone'] ?? json['mobile']),
      addressLine: readString(json['address_line'] ?? json['address']),
      city: readString(json['city']),
      district: readString(json['district'] ?? json['area']),
      isDefault: readBool(json['is_default'] ?? json['default'], false),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'full_name': fullName,
        'phone': phone,
        'address_line': addressLine,
        'city': city,
        'district': district,
        'is_default': isDefault,
      };
}
