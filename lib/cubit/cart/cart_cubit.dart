import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/cubit/cart/cart_state.dart';
import 'package:app_development_project/data/models/cart_item_model.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  static const int maxPerItem = 99;

  int quantityOf(int productId) => state.quantityOf(productId);

  /// بيضيف للسلة وبيرجّع الكمية اللي صارت فعلياً بالسلة.
  /// إذا تجاوزت الحد المتاح بتنقص عن المطلوب (الـ caller بيقارن ويعرض رسالة).
  int add({
    required int productId,
    required String name,
    required double price,
    String? categoryName,
    required int quantity,
    int? maxQuantity,
  }) {
    final limit = min(maxQuantity ?? maxPerItem, maxPerItem);
    if (limit < 1 || quantity < 1) return quantityOf(productId);

    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.productId == productId);
    final existing = index == -1 ? 0 : items[index].quantity;
    final next = min(existing + quantity, limit);

    final item = CartItem(
      productId: productId,
      name: name,
      price: price,
      categoryName: categoryName,
      quantity: next,
      maxQuantity: limit,
    );

    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }

    emit(CartState(items));
    return next;
  }

  void setQuantity(int productId, int quantity) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((i) => i.productId == productId);
    if (index == -1) return;

    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      items[index] =
          items[index].copyWith(quantity: min(quantity, items[index].maxQuantity));
    }
    emit(CartState(items));
  }

  void increment(int productId) =>
      setQuantity(productId, quantityOf(productId) + 1);

  void decrement(int productId) =>
      setQuantity(productId, quantityOf(productId) - 1);

  void remove(int productId) => setQuantity(productId, 0);

  void clear() => emit(const CartState());
}