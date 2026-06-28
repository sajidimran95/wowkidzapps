import 'package:my_first_app/data/mock/mock_data.dart';
import 'package:my_first_app/data/models/saved_address.dart';
import 'package:my_first_app/data/models/support_ticket.dart';

abstract final class CustomerProfileMock {
  static const addresses = <SavedAddress>[
    SavedAddress(
      id: 'addr_1',
      label: 'Home',
      fullName: 'WowKidz Customer',
      phone: '01712345678',
      addressLine: 'House 12, Road 5, Block B, Banani',
      city: 'Dhaka',
      district: 'Dhaka',
      isDefault: true,
    ),
    SavedAddress(
      id: 'addr_2',
      label: 'Office',
      fullName: 'WowKidz Customer',
      phone: '01712345678',
      addressLine: 'Level 8, ABC Tower, Motijheel',
      city: 'Dhaka',
      district: 'Dhaka',
    ),
  ];

  static final tickets = <SupportTicket>[
    SupportTicket(
      id: 'TKT-1001',
      subject: 'Order delivery delay',
      message: 'My order WK48291 has not arrived yet.',
      createdAt: DateTime(2026, 6, 24, 14, 30),
      status: TicketStatus.inProgress,
    ),
    SupportTicket(
      id: 'TKT-1002',
      subject: 'Wrong size received',
      message: 'Received size 4-5Y but ordered 6-7Y.',
      createdAt: DateTime(2026, 6, 18, 10, 15),
      status: TicketStatus.resolved,
      attachmentName: 'order_proof.zip',
    ),
  ];

  static List<String> get defaultWishlistIds =>
      MockData.allProducts.take(8).map((p) => p.id).toList();
}
