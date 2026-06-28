Map<String, dynamic> asJsonMap(dynamic value) {
  if (value == null) return {};
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

List<dynamic> asJsonList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value;
  if (value is Map) {
    for (final key in const [
      'data',
      'items',
      'results',
      'products',
      'categories',
      'orders',
      'addresses',
      'tickets',
      'sliders',
      'banners',
      'features',
    ]) {
      final nested = value[key];
      if (nested is List) return nested;
    }
  }
  return [];
}

dynamic unwrapData(dynamic json) {
  if (json is Map && json.containsKey('data')) {
    return json['data'];
  }
  return json;
}

String readString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

double readDouble(dynamic value, [double fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? fallback;
}

int readInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

bool readBool(dynamic value, [bool fallback = false]) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final s = value.toString().toLowerCase();
  if (s == 'true' || s == '1' || s == 'yes') return true;
  if (s == 'false' || s == '0' || s == 'no') return false;
  return fallback;
}

String? readNullableString(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}
