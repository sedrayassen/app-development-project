import 'package:app_development_project/data/models/cart_item_model.dart';

class CartState {
  final List<CartItem> items;

  const CartState([this.items = const []]);

  bool get isEmpty => items.isEmpty;

  /// مجموع القطع (للـ badge)
  int get totalCount => items.fold(0, (sum, i) => sum + i.quantity);

  double get totalPrice => items.fold(0.0, (sum, i) => sum + i.lineTotal);

  int quantityOf(int productId) {
    for (final i in items) {
      if (i.productId == productId) return i.quantity;
    }
    return 0;
  }
}