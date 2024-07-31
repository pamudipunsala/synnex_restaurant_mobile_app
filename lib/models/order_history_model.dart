import 'dart:ffi';

class HistoryItem {
  final String orderId;
  final String item;
  final int quantity;
  final double price;
  final double total;
  final String note;
  final String customer;
  final String status;
  // final Float total_payable;
  // final DateTime created_date;

  HistoryItem({
    required this.orderId,
    required this.item,
    required this.quantity,
    required this.price,
    required this.total,
    required this.note,
    required this.customer,
    required this.status,
    // required this.total_payable,
    // required this.created_date,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      orderId: json['o_no'] ?? 'Unknown', // Provide default values
      item: json['item'] ?? 'Unknown',
      quantity: json['quantity'] ?? 0,
      price: json['price']?.toDouble() ?? 0.0,
      total: json['total']?.toDouble() ?? 0.0,
      note: json['note'] ?? '',
      customer: '',
      status: '',
      // total_payable: json['total_payable']?.toDouble() ?? 0.0,
      // created_date: ,
    );
  }
}
