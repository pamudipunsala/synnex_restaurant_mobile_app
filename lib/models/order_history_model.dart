import 'dart:ffi';

class HistoryItem {
  final String orderId;
  final String date;
  final String tabelNo;
  final String total_payable;
  final double total;
  final String note;
  final String customer;
  final String status;
  // final Float total_payable;
  // final DateTime created_date;

  HistoryItem({
    required this.orderId,
    required this.date,
    required this.tabelNo,
    required this.total_payable,
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
      date: json['created_date'] ?? 'Unknown',
      tabelNo: json['tabel_no'] ?? 0,
      total_payable: json['total_payable'] ?? 0,
      total: json['total']?.toDouble() ?? 0.0,
      note: json['note'] ?? '',
      customer: '',
      status: '',
      // total_payable: json['total_payable']?.toDouble() ?? 0.0,
      // created_date: ,
    );
  }
}
