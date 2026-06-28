import 'package:my_first_app/core/network/json_utils.dart';
import 'package:my_first_app/data/models/customer_order.dart';

enum TicketStatus { open, inProgress, resolved }

extension TicketStatusX on TicketStatus {
  String get label => switch (this) {
        TicketStatus.open => 'Open',
        TicketStatus.inProgress => 'In Progress',
        TicketStatus.resolved => 'Resolved',
      };

  static TicketStatus fromString(String value) => switch (value.toLowerCase()) {
        'in_progress' || 'in progress' || 'processing' => TicketStatus.inProgress,
        'resolved' || 'closed' => TicketStatus.resolved,
        _ => TicketStatus.open,
      };
}

class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.subject,
    required this.message,
    required this.createdAt,
    this.status = TicketStatus.open,
    this.attachmentName,
  });

  final String id;
  final String subject;
  final String message;
  final DateTime createdAt;
  final TicketStatus status;
  final String? attachmentName;

  String get formattedDate => formatOrderStatusDateTime(createdAt);

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: readString(json['id'] ?? json['ticket_id']),
      subject: readString(json['subject'] ?? json['title']),
      message: readString(json['message'] ?? json['body']),
      createdAt: DateTime.tryParse(readString(json['created_at'])) ??
          DateTime.now(),
      status: TicketStatusX.fromString(readString(json['status'], 'open')),
      attachmentName: readNullableString(
        json['attachment_name'] ?? json['attachment'],
      ),
    );
  }
}
