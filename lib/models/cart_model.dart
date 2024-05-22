class CartItem {
  final String name;
  final String variation;
  final int quantity;
  final String addOns;
  final double price;
  final String note;
  final int tableNo;

  CartItem({
    required this.name,
    required this.variation,
    required this.quantity,
    required this.addOns,
    required this.price,
    required this.note,
    required this.tableNo,
  });
}
