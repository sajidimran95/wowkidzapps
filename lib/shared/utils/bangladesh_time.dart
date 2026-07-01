/// Bangladesh (Asia/Dhaka) timezone — fixed UTC+6, no daylight saving.
const Duration kBangladeshOffset = Duration(hours: 6);

/// Current moment as a UTC instant (use for storage/comparisons).
DateTime utcNow() => DateTime.now().toUtc();

/// Alias used when creating order timestamps from the app.
DateTime bangladeshNow() => utcNow();

/// Parse API / server datetime into a UTC instant.
DateTime? parseApiDateTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final value = raw.trim();
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;

  final hasTimezone = value.endsWith('Z') ||
      RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(value) ||
      RegExp(r'[+-]\d{4}$').hasMatch(value);

  if (hasTimezone) {
    return parsed.toUtc();
  }

  // Naive datetime from Laravel admin — already Asia/Dhaka wall clock.
  return DateTime.utc(
    parsed.year,
    parsed.month,
    parsed.day,
    parsed.hour,
    parsed.minute,
    parsed.second,
    parsed.millisecond,
    parsed.microsecond,
  ).subtract(kBangladeshOffset);
}

/// Format a UTC instant for display in Bangladesh time.
String formatBangladeshDateTime(DateTime instant) {
  final utc = instant.toUtc();
  final bdtMs = utc.millisecondsSinceEpoch + kBangladeshOffset.inMilliseconds;
  final bdt = DateTime.fromMillisecondsSinceEpoch(bdtMs, isUtc: true);

  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hour = bdt.hour;
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  final minute = bdt.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';

  return '${bdt.day} ${months[bdt.month - 1]} ${bdt.year}, '
      '$displayHour:$minute $period';
}

/// Same format as website admin panel order list.
String formatOrderStatusDateTime(DateTime instant) =>
    formatBangladeshDateTime(instant);

String orderDateLabelFromJson(Map<String, dynamic> json) {
  final apiLabel = json['date_label'] ?? json['date'];
  if (apiLabel != null && apiLabel.toString().trim().isNotEmpty) {
    return apiLabel.toString().trim();
  }

  final createdAt = parseApiDateTime(
    (json['created_at'] ?? json['createdAt'])?.toString(),
  );
  if (createdAt != null) {
    return formatBangladeshDateTime(createdAt);
  }

  return formatBangladeshDateTime(utcNow());
}

/// Compare countdown / deadlines using Bangladesh-aligned instants.
DateTime? parseApiInstant(String? raw) => parseApiDateTime(raw);

Duration timeUntilBangladeshDeadline(DateTime deadlineUtc) =>
    deadlineUtc.toUtc().difference(utcNow());
