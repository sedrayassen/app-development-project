class CreateOrderItem {
  final int productId;
  final int quantity;

  const CreateOrderItem({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
      };
}

class CreateOrderRequest {
  final List<CreateOrderItem> items;

  const CreateOrderRequest(this.items);

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
      };
}