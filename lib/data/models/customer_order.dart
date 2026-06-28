import 'package:flutter/material.dart';
import 'package:my_first_app/core/network/json_utils.dart';
import 'package:my_first_app/core/theme/app_colors.dart';

enum OrderPaymentStatus {
  paid,
  unpaid,
}

extension OrderPaymentStatusX on OrderPaymentStatus {
  String get label => switch (this) {
        OrderPaymentStatus.paid => 'Paid',
        OrderPaymentStatus.unpaid => 'Not Paid',
      };

  Color get color => switch (this) {
        OrderPaymentStatus.paid => AppColors.success,
        OrderPaymentStatus.unpaid => AppColors.discount,
      };
}

enum OrderStatus {
  confirmed,
  processing,
  packed,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get label => switch (this) {
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.processing => 'Processing',
        OrderStatus.packed => 'Packed',
        OrderStatus.outForDelivery => 'Out for Delivery',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
      };

  Color get color => switch (this) {
        OrderStatus.confirmed => AppColors.secondary,
        OrderStatus.processing => AppColors.accent,
        OrderStatus.packed => const Color(0xFF3B82F6),
        OrderStatus.outForDelivery => AppColors.primary,
        OrderStatus.delivered => AppColors.success,
        OrderStatus.cancelled => AppColors.discount,
      };

  IconData get icon => switch (this) {
        OrderStatus.confirmed => Icons.check_circle_outline,
        OrderStatus.processing => Icons.inventory_2_outlined,
        OrderStatus.packed => Icons.all_inbox_outlined,
        OrderStatus.outForDelivery => Icons.local_shipping_outlined,
        OrderStatus.delivered => Icons.done_all,
        OrderStatus.cancelled => Icons.cancel_outlined,
      };

  bool get isRunning =>
      this != OrderStatus.delivered && this != OrderStatus.cancelled;

  int get stepIndex => switch (this) {
        OrderStatus.confirmed => 0,
        OrderStatus.processing => 1,
        OrderStatus.packed => 2,
        OrderStatus.outForDelivery => 3,
        OrderStatus.delivered => 4,
        OrderStatus.cancelled => -1,
      };
}

const kOrderTrackingSteps = [
  OrderStatus.confirmed,
  OrderStatus.processing,
  OrderStatus.packed,
  OrderStatus.outForDelivery,
  OrderStatus.delivered,
];

class OrderStatusEvent {
  const OrderStatusEvent({required this.status, required this.at});

  final OrderStatus status;
  final DateTime at;
}

String formatOrderStatusDateTime(DateTime dateTime) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final hour = dateTime.hour;
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';

  return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, '
      '$displayHour:$minute $period';
}

class CustomerOrder {
  const CustomerOrder({
    required this.id,
    required this.dateLabel,
    required this.total,
    required this.status,
    required this.itemCount,
    required this.itemsSummary,
    required this.statusHistory,
    this.address = 'Dhaka, Bangladesh',
    this.paymentMethod = 'Cash on Delivery',
    this.paymentStatus = OrderPaymentStatus.paid,
  });

  final String id;
  final String dateLabel;
  final double total;
  final OrderStatus status;
  final int itemCount;
  final String itemsSummary;
  final List<OrderStatusEvent> statusHistory;
  final String address;
  final String paymentMethod;
  final OrderPaymentStatus paymentStatus;

  CustomerOrder copyWith({
    OrderPaymentStatus? paymentStatus,
  }) {
    return CustomerOrder(
      id: id,
      dateLabel: dateLabel,
      total: total,
      status: status,
      itemCount: itemCount,
      itemsSummary: itemsSummary,
      statusHistory: statusHistory,
      address: address,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  DateTime? timestampFor(OrderStatus status) {
    for (final event in statusHistory) {
      if (event.status == status) return event.at;
    }
    return null;
  }

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    final status = _parseOrderStatus(readString(json['status'], 'confirmed'));
    final history = asJsonList(json['status_history'] ?? json['timeline'])
        .map((e) {
          final map = asJsonMap(e);
          return OrderStatusEvent(
            status: _parseOrderStatus(readString(map['status'])),
            at: DateTime.tryParse(readString(map['at'] ?? map['date'])) ??
                DateTime.now(),
          );
        })
        .toList();

    final paymentRaw =
        readString(json['payment_status'] ?? json['paymentStatus'], 'paid');
    final paymentStatus = paymentRaw.toLowerCase().contains('unpaid') ||
            paymentRaw.toLowerCase() == 'pending'
        ? OrderPaymentStatus.unpaid
        : OrderPaymentStatus.paid;

    return CustomerOrder(
      id: readString(json['id'] ?? json['order_id'] ?? json['order_number']),
      dateLabel: readString(
        json['date_label'] ?? json['date'] ?? json['created_at'],
        formatOrderStatusDateTime(
          DateTime.tryParse(readString(json['created_at'])) ?? DateTime.now(),
        ),
      ),
      total: readDouble(json['total'] ?? json['grand_total'] ?? json['amount']),
      status: status,
      itemCount: readInt(json['item_count'] ?? json['items_count'], 1),
      itemsSummary: readString(
        json['items_summary'] ?? json['summary'] ?? json['items'],
      ),
      statusHistory: history.isEmpty
          ? [OrderStatusEvent(status: status, at: DateTime.now())]
          : history,
      address: readString(json['address'] ?? json['shipping_address']),
      paymentMethod: readString(json['payment_method'] ?? json['paymentMethod']),
      paymentStatus: paymentStatus,
    );
  }

  static OrderStatus _parseOrderStatus(String value) => switch (
        value.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_')) {
        'processing' => OrderStatus.processing,
        'packed' => OrderStatus.packed,
        'out_for_delivery' || 'shipped' => OrderStatus.outForDelivery,
        'delivered' => OrderStatus.delivered,
        'cancelled' || 'canceled' => OrderStatus.cancelled,
        _ => OrderStatus.confirmed,
      };
}
