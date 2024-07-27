class CartItem {
  final String name;
  final String variation;
  int quantity;
  final String addOns;
  final double price;
  final String note;
  final int tableNo;
  String finalNote;
  final String comId;
  final int productId;
  final String kotType;
  final String userId;
  final int oId;

  CartItem({
    required this.name,
    required this.variation,
    required this.quantity,
    required this.addOns,
    required this.price,
    required this.note,
    required this.tableNo,
    required this.finalNote,
    required this.comId,
    required productName,
    required this.productId,
    required this.kotType,
    required this.userId,
    required this.oId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'variation': variation,
      'quantity': quantity,
      'add_ons': addOns,
      'price': price,
      'note': note,
      'table_no': tableNo,
      'com_id': comId,
    };
  }
}
