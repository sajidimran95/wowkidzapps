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
}
