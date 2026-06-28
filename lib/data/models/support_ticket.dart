import 'package:my_first_app/data/models/customer_order.dart';

enum TicketStatus { open, inProgress, resolved }

extension TicketStatusX on TicketStatus {
  String get label => switch (this) {
        TicketStatus.open => 'Open',
        TicketStatus.inProgress => 'In Progress',
        TicketStatus.resolved => 'Resolved',
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
}
