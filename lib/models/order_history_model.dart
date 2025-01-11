class HistoryItem {
  final int orderId;
  final String orderNo;
  final String date;
  final int tabelNo;
  final double totalPayable;
  final double serviceCharge;
  final String status;
  final int comId;

  HistoryItem(
      {required this.orderId,
      required this.orderNo,
      required this.date,
      required this.tabelNo,
      required this.totalPayable,
      required this.serviceCharge,
      required this.status,
      required this.comId,});

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      orderId: json['o_id'] ?? 0,
      orderNo: json['o_no'] ?? '',
      date: json['created_date'] ?? '',
      tabelNo: json['tabel_no'] ?? 0,
      totalPayable: (json['total_payable'] ?? 0).toDouble(),
      serviceCharge: (json['service_charge'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      comId: json['com_id'] ?? 0,
    );
  }
}
