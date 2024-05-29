class CartItem {
  final String name;
  final String variation;
  int quantity;
  final String addOns;
  final double price;
  final String note;
  final int tableNo;
  String finalNote;

  CartItem({
    required this.name,
    required this.variation,
    required this.quantity,
    required this.addOns,
    required this.price,
    required this.note,
    required this.tableNo,
    required this.finalNote,
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
    };
  }
}
