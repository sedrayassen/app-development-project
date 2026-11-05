
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/constants/app_colors.dart';
import 'package:app_development_project/cubit/order/create_order_cubit.dart';
import 'package:app_development_project/cubit/order/create_order_state.dart';
import 'package:app_development_project/cubit/product/product_cubit.dart';
import 'package:app_development_project/cubit/product/product_state.dart';
import 'package:app_development_project/data/models/create_order_request.dart';
import 'package:app_development_project/data/models/product_model.dart';
import 'package:app_development_project/data/repository/order_repository.dart';
import 'package:app_development_project/data/repository/product_repository.dart';
import 'package:app_development_project/presentation/widgets/state_message.dart';
import 'package:app_development_project/routes/app_routes.dart';

class CreateOrderScreen extends StatelessWidget {
  const CreateOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) =>
              ProductsCubit(ctx.read<ProductRepository>())..load(),
        ),
        BlocProvider(
          create: (ctx) => CreateOrderCubit(ctx.read<OrderRepository>()),
        ),
      ],
      child: const _CreateOrderView(),
    );
  }
}

class _CreateOrderView extends StatefulWidget {
  const _CreateOrderView();

  @override
  State<_CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<_CreateOrderView> {
  static const int _maxQty = 99;

  final ScrollController _scroll = ScrollController();

  final Map<int, int> _qty = {};
  final Map<int, ProductModel> _selected = {};
  List<int> _submittedIds = [];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (!_scroll.hasClients) return;
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        context.read<ProductsCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  int get _count => _qty.values.fold(0, (a, b) => a + b);

  double get _total => _qty.entries.fold(
        0.0,
        (sum, e) => sum + (_selected[e.key]?.price ?? 0) * e.value,
      );

  void _change(ProductModel p, int delta) {
    setState(() {
      final next = (_qty[p.id] ?? 0) + delta;
      if (next <= 0) {
        _qty.remove(p.id);
        _selected.remove(p.id);
      } else if (next <= _maxQty) {
        _qty[p.id] = next;
        _selected[p.id] = p;
      }
    });
  }

  void _submit() {
    final ids = _qty.keys.toList();
    _submittedIds = ids;

    context.read<CreateOrderCubit>().submit([
      for (final id in ids) CreateOrderItem(productId: id, quantity: _qty[id]!),
    ]);
  }

  void _onState(BuildContext context, CreateOrderState state) {
    if (state is CreateOrderSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order #${state.order.id} created successfully'),
          backgroundColor: const Color(0xFF6BA58A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.of(context).pop(state.order.id);
    } else if (state is CreateOrderUnauthorized) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (_) => false,
      );
    } else if (state is CreateOrderValidationError) {
      _showDialog(
        context,
        icon: Icons.edit_note_rounded,
        title: 'Check your order',
        message: _validationText(state),
      );
    } else if (state is CreateOrderConflict) {
      _showDialog(
        context,
        icon: Icons.inventory_2_outlined,
        title: 'Cannot place this order',
        message: state.message,
      );
    } else if (state is CreateOrderForbidden) {
      _showDialog(
        context,
        icon: Icons.block_rounded,
        title: 'Not allowed',
        message: state.message,
      );
    } else if (state is CreateOrderServerError) {
      _showDialog(
        context,
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

  String _validationText(CreateOrderValidationError state) {
    if (state.fieldErrors.isEmpty) return state.message;

    final lines = <String>[];
    state.fieldErrors.forEach((key, messages) {
      final match = RegExp(r'^items\.(\d+)\.(.+)$').firstMatch(key);
      String? name;
      String field = key;

      if (match != null) {
        final index = int.parse(match.group(1)!);
        field = match.group(2)!.replaceAll('_', ' ');
        if (index < _submittedIds.length) {
          name = _selected[_submittedIds[index]]?.name;
        }
      }

      for (final m in messages) {
        lines.add(name == null ? m : m.replaceAll(key, '$field ($name)'));
      }
    });
    return lines.join('\n');
  }

  Future<void> _showDialog(
    BuildContext context, {
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
      builder: (context, state) {
        final submitting = state is CreateOrderSubmitting;

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
                  onPressed: submitting ? null : () => Navigator.of(context).pop(),
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF29244D).withValues(alpha: 0.07),
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
                'New order',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            body: IgnorePointer(
              ignoring: submitting,
              child: _buildProducts(),
            ),
            bottomNavigationBar: _BottomBar(
              count: _count,
              total: _total,
              submitting: submitting,
              onSubmit: _submit,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProducts() {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state is ProductsInitial || state is ProductsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is ProductsError) {
          return StateMessage(
            icon: Icons.error_outline_rounded,
            title: 'Could not load products',
            message: state.message,
            buttonText: 'Try again',
            onPressed: () => context.read<ProductsCubit>().load(),
          );
        }

        List<ProductModel> products = [];
        bool loadingMore = false;

        if (state is ProductsLoaded) {
          products = state.products;
        } else if (state is ProductsLoadingMore) {
          products = state.products;
          loadingMore = true;
        }

        if (products.isEmpty) {
          return const Center(
            child: Text(
              'No products available',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          itemCount: products.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == products.length) {
              return loadingMore
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            }

            final p = products[index];
            return _ProductTile(
              product: p,
              quantity: _qty[p.id] ?? 0,
              onAdd: () => _change(p, 1),
              onRemove: () => _change(p, -1),
            );
          },
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final ProductModel product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final selected = quantity > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.55)
              : Colors.transparent,
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : const Color(0xFF29244D).withValues(alpha: 0.06),
            blurRadius: selected ? 18 : 14,
            offset: Offset(0, selected ? 8 : 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
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
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!product.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAF0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Unavailable',
                style: TextStyle(
                  color: Color(0xFFE66F8D),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else if (!selected)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
              onPressed: onAdd,
              child: const Text('Add'),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QtyBtn(
                  icon: Icons.remove_rounded,
                  onTap: onRemove,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _QtyBtn(
                  icon: Icons.add_rounded,
                  onTap: onAdd,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.count,
    required this.total,
    required this.submitting,
    required this.onSubmit,
  });

  final int count;
  final double total;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                      count == 0 ? 'No items selected' : '$count item(s)',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
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
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.45),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onPressed: (count == 0 || submitting) ? null : onSubmit,
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
  }
}