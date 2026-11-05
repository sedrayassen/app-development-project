class CartItem {
  final int productId;
  final String name;
  final double price;
  final String? categoryName;
  final int quantity;
  final int maxQuantity;

  const CartItem({
    required this.productId,
    required this.name,
    required this.price,
    this.categoryName,
    required this.quantity,
    required this.maxQuantity,
  });

  double get lineTotal => price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      price: price,
      categoryName: categoryName,
      quantity: quantity ?? this.quantity,
      maxQuantity: maxQuantity,
    );
  }
}