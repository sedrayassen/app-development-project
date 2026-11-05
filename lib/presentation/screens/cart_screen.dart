
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/constants/app_colors.dart';
import 'package:app_development_project/cubit/cart/cart_cubit.dart';
import 'package:app_development_project/cubit/cart/cart_state.dart';
import 'package:app_development_project/cubit/order/create_order_cubit.dart';
import 'package:app_development_project/cubit/order/create_order_state.dart';
import 'package:app_development_project/data/models/cart_item_model.dart';
import 'package:app_development_project/data/models/create_order_request.dart';
import 'package:app_development_project/data/repository/order_repository.dart';
import 'package:app_development_project/presentation/widgets/state_message.dart';
import 'package:app_development_project/routes/app_routes.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => CreateOrderCubit(ctx.read<OrderRepository>()),
      child: const _CartView(),
    );
  }
}

class _CartView extends StatefulWidget {
  const _CartView();

  @override
  State<_CartView> createState() => _CartViewState();
}

class _CartViewState extends State<_CartView> {
  List<CartItem> _submitted = [];

  void _submit() {
    final items = context.read<CartCubit>().state.items;
    _submitted = List.of(items);

    context.read<CreateOrderCubit>().submit([
      for (final i in items)
        CreateOrderItem(productId: i.productId, quantity: i.quantity),
    ]);
  }

  void _onState(BuildContext context, CreateOrderState state) {
    if (state is CreateOrderSuccess) {
      context.read<CartCubit>().clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #${state.order.id} created successfully'),
          backgroundColor: const Color(0xFF6BA58A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.orderDetails,
        arguments: state.order.id,
      );
    } else if (state is CreateOrderUnauthorized) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (_) => false,
      );
    } else if (state is CreateOrderValidationError) {
      _showDialog(
        icon: Icons.edit_note_rounded,
        title: 'Check your order',
        message: _validationText(state),
      );
    } else if (state is CreateOrderConflict) {
      _showDialog(
        icon: Icons.inventory_2_outlined,
        title: 'Cannot place this order',
        message: '${state.message}\n\nPlease update your cart and try again.',
      );
    } else if (state is CreateOrderForbidden) {
      _showDialog(
        icon: Icons.block_rounded,
        title: 'Not allowed',
        message: state.message,
      );
    } else if (state is CreateOrderServerError) {
      _showDialog(
        icon: Icons.error_outline_rounded,
        title: 'Order failed',
        message: '${state.message}\n\n'
            'Please check your orders list before trying again.',
      );
    } else if (state is CreateOrderUnavailable || state is CreateOrderError) {
      final message = (state as CreateOrderFailure).message;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(label: 'Retry', onPressed: _submit),
          ),
        );
    }
  }

  String _validationText(CreateOrderValidationError s) {
    if (s.fieldErrors.isEmpty) return s.message;

    final lines = <String>[];
    s.fieldErrors.forEach((key, messages) {
      final m = RegExp(r'^items\.(\d+)\.').firstMatch(key);
      final idx = m == null ? null : int.parse(m.group(1)!);
      final name =
          (idx != null && idx < _submitted.length) ? _submitted[idx].name : null;

      for (final msg in messages) {
        lines.add(name == null ? msg : '$name: $msg');
      }
    });
    return lines.join('\n');
  }

  Future<void> _showDialog({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateOrderCubit, CreateOrderState>(
      listener: _onState,
      builder: (context, orderState) {
        final submitting = orderState is CreateOrderSubmitting;

        return PopScope(
          canPop: !submitting,
          child: Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: AppBar(
              backgroundColor: AppColors.scaffoldBackground,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  onPressed:
                      submitting ? null : () => Navigator.of(context).pop(),
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF29244D).withValues(alpha: 0.07),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textDark,
                      size: 20,
                    ),
                  ),
                ),
              ),
              title: const Text(
                'My cart',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              actions: [
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, cart) {
                    if (cart.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextButton(
                        onPressed: submitting
                            ? null
                            : () => context.read<CartCubit>().clear(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFE66F8D),
                        ),
                        child: const Text(
                          'Clear',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: BlocBuilder<CartCubit, CartState>(
              builder: (context, cart) {
                if (cart.isEmpty) {
                  return StateMessage(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your cart is empty',
                    message: 'Add some products to place an order.',
                    buttonText: 'Browse products',
                    onPressed: () => Navigator.of(context).pop(),
                  );
                }

                return IgnorePointer(
                  ignoring: submitting,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _CartTile(item: cart.items[i]),
                  ),
                );
              },
            ),
            bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
              builder: (context, cart) {
                if (cart.isEmpty) return const SizedBox.shrink();

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF29244D).withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${cart.totalCount} item(s)',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '\$${cart.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.primary
                                    .withValues(alpha: 0.45),
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 22),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              onPressed: submitting ? null : _submit,
                              child: submitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Place order'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartCubit>();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29244D).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).pushNamed(
              AppRoutes.productDetails,
              arguments: item.productId,
            ),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF0ECFF), Color(0xFFE8E2FF)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF8A7DEB),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)} each',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${item.lineTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QtyBtn(
                      icon: Icons.remove_rounded,
                      onTap: () => cart.decrement(item.productId),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _QtyBtn(
                      icon: Icons.add_rounded,
                      enabled: item.quantity < item.maxQuantity,
                      onTap: () => cart.increment(item.productId),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => cart.remove(item.productId),
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: const Text('Remove'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFE66F8D),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? AppColors.primary.withValues(alpha: 0.12)
          : const Color(0xFFF0EEF8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            icon,
            size: 17,
            color: enabled ? AppColors.primary : AppColors.textGray,
          ),
        ),
      ),
    );
  }
}