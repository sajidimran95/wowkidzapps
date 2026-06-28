import 'package:my_first_app/data/models/customer_order.dart';

abstract final class CustomerOrdersMock {
  static final orders = <CustomerOrder>[
    CustomerOrder(
      id: 'WK48291',
      dateLabel: 'Today',
      total: 4930,
      status: OrderStatus.outForDelivery,
      itemCount: 3,
      itemsSummary: 'Kids T-Shirt, Sneakers, Cap',
      statusHistory: [
        OrderStatusEvent(
          status: OrderStatus.confirmed,
          at: DateTime(2026, 6, 22, 10, 15),
        ),
        OrderStatusEvent(
          status: OrderStatus.processing,
          at: DateTime(2026, 6, 23, 9, 30),
        ),
        OrderStatusEvent(
          status: OrderStatus.packed,
          at: DateTime(2026, 6, 24, 16, 0),
        ),
        OrderStatusEvent(
          status: OrderStatus.outForDelivery,
          at: DateTime(2026, 6, 25, 11, 20),
        ),
      ],
    ),
    CustomerOrder(
      id: 'WK48102',
      dateLabel: 'Yesterday',
      total: 3150,
      status: OrderStatus.processing,
      itemCount: 2,
      itemsSummary: 'School Bag, Water Bottle',
      paymentMethod: 'bKash',
      paymentStatus: OrderPaymentStatus.unpaid,
      statusHistory: [
        OrderStatusEvent(
          status: OrderStatus.confirmed,
          at: DateTime(2026, 6, 23, 14, 45),
        ),
        OrderStatusEvent(
          status: OrderStatus.processing,
          at: DateTime(2026, 6, 24, 10, 5),
        ),
      ],
    ),
    CustomerOrder(
      id: 'WK47120',
      dateLabel: '2 days ago',
      total: 2200,
      status: OrderStatus.packed,
      itemCount: 1,
      itemsSummary: 'Party Dress (Pink)',
      paymentMethod: 'Nagad',
      paymentStatus: OrderPaymentStatus.unpaid,
      statusHistory: [
        OrderStatusEvent(
          status: OrderStatus.confirmed,
          at: DateTime(2026, 6, 21, 11, 0),
        ),
        OrderStatusEvent(
          status: OrderStatus.processing,
          at: DateTime(2026, 6, 22, 15, 30),
        ),
        OrderStatusEvent(
          status: OrderStatus.packed,
          at: DateTime(2026, 6, 23, 18, 15),
        ),
      ],
    ),
    CustomerOrder(
      id: 'WK46805',
      dateLabel: '1 week ago',
      total: 1990,
      status: OrderStatus.delivered,
      itemCount: 2,
      itemsSummary: 'Pajama Set, Socks Pack',
      statusHistory: [
        OrderStatusEvent(
          status: OrderStatus.confirmed,
          at: DateTime(2026, 6, 15, 9, 20),
        ),
        OrderStatusEvent(
          status: OrderStatus.processing,
          at: DateTime(2026, 6, 16, 11, 45),
        ),
        OrderStatusEvent(
          status: OrderStatus.packed,
          at: DateTime(2026, 6, 17, 14, 10),
        ),
        OrderStatusEvent(
          status: OrderStatus.outForDelivery,
          at: DateTime(2026, 6, 18, 8, 30),
        ),
        OrderStatusEvent(
          status: OrderStatus.delivered,
          at: DateTime(2026, 6, 18, 17, 55),
        ),
      ],
    ),
    CustomerOrder(
      id: 'WK46211',
      dateLabel: '2 weeks ago',
      total: 890,
      status: OrderStatus.delivered,
      itemCount: 1,
      itemsSummary: 'Cartoon Lunch Box',
      statusHistory: [
        OrderStatusEvent(
          status: OrderStatus.confirmed,
          at: DateTime(2026, 6, 8, 16, 40),
        ),
        OrderStatusEvent(
          status: OrderStatus.processing,
          at: DateTime(2026, 6, 9, 10, 15),
        ),
        OrderStatusEvent(
          status: OrderStatus.packed,
          at: DateTime(2026, 6, 10, 13, 0),
        ),
        OrderStatusEvent(
          status: OrderStatus.outForDelivery,
          at: DateTime(2026, 6, 11, 9, 45),
        ),
        OrderStatusEvent(
          status: OrderStatus.delivered,
          at: DateTime(2026, 6, 11, 19, 20),
        ),
      ],
    ),
    CustomerOrder(
      id: 'WK45990',
      dateLabel: '3 weeks ago',
      total: 1450,
      status: OrderStatus.cancelled,
      itemCount: 1,
      itemsSummary: 'Winter Jacket',
      statusHistory: [
        OrderStatusEvent(
          status: OrderStatus.confirmed,
          at: DateTime(2026, 6, 1, 12, 30),
        ),
        OrderStatusEvent(
          status: OrderStatus.cancelled,
          at: DateTime(2026, 6, 2, 9, 10),
        ),
      ],
    ),
  ];

  static List<CustomerOrder> get running =>
      orders.where((o) => o.status.isRunning).toList();

  static List<CustomerOrder> byStatus(OrderStatus status) =>
      orders.where((o) => o.status == status).toList();

  static int countByStatus(OrderStatus status) =>
      orders.where((o) => o.status == status).length;

  static int get runningCount => running.length;

  static CustomerOrder? findById(String id) {
    for (final order in orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  static void updateOrder(CustomerOrder updated) {
    final index = orders.indexWhere((o) => o.id == updated.id);
    if (index != -1) orders[index] = updated;
  }
}
