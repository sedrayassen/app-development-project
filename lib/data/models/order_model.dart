class OrderStatus {
  static const pending = 'Pending';
  static const confirmed = 'Confirmed';
  static const shipped = 'Shipped';
  static const delivered = 'Delivered';
  static const cancelled = 'Cancelled';

  static const List<String> all = [
    pending,
    confirmed,
    shipped,
    delivered,
    cancelled,
  ];
}

class OrderItemModel {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: int.tryParse('${json['product_id']}') ?? 0,
      productName: json['product_name']?.toString() ?? '',
      quantity: int.tryParse('${json['quantity']}') ?? 0,
      unitPrice: double.tryParse('${json['unit_price']}') ?? 0,
      lineTotal: double.tryParse('${json['line_total']}') ?? 0,
    );
  }
}

class OrderModel {
  final int id;
  final int userId;
  final String status;
  final List<String> allowedNextStatuses;
  final double totalAmount;
  final List<OrderItemModel> items;
  final String? createdAt; // ممكن تكون null
  final String? updatedAt; // ممكن تكون null

  OrderModel({
    required this.id,
    required this.userId,
    required this.status,
    this.allowedNextStatuses = const [],
    required this.totalAmount,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final nextJson = json['allowed_next_statuses'];

    return OrderModel(
      id: int.tryParse('${json['id']}') ?? 0,
      userId: int.tryParse('${json['user_id']}') ?? 0,
      status: json['status']?.toString() ?? '',
      allowedNextStatuses: nextJson is List
          ? nextJson.map((e) => e.toString()).toList()
          : const [],
      totalAmount: double.tryParse('${json['total_amount']}') ?? 0,
      items: itemsJson is List
          ? itemsJson
              .whereType<Map>()
              .map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}