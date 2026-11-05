// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:app_development_project/constants/app_colors.dart';
// import 'package:app_development_project/cubit/product/product_detail_cubit.dart';
// import 'package:app_development_project/cubit/product/product_detail_state.dart';
// import 'package:app_development_project/data/models/product_detail_model.dart';
// import 'package:app_development_project/data/repository/product_repository.dart';
// import 'package:app_development_project/routes/app_routes.dart';
// import 'dart:math';

// import 'package:app_development_project/cubit/cart/cart_cubit.dart';
// import 'package:app_development_project/cubit/cart/cart_state.dart';

// class ProductDetailsScreen extends StatelessWidget {
//   const ProductDetailsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final args = ModalRoute.of(context)?.settings.arguments;
//     final productId = args is int ? args : null;

//     if (productId == null) {
//       return Scaffold(
//         appBar: AppBar(),
//         body: const Center(child: Text('Invalid product')),
//       );
//     }

//     return BlocProvider(
//       create: (ctx) =>
//           ProductDetailCubit(ctx.read<ProductRepository>())..load(productId),
//       child: const _ProductDetailsView(),
//     );
//   }
// }

// class _ProductDetailsView extends StatelessWidget {
//   const _ProductDetailsView();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       appBar: AppBar(
//         backgroundColor: AppColors.scaffoldBackground,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         title: const Text(
//           'Product details',
//           style: TextStyle(
//             color: AppColors.textPrimary,
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//       body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
//         builder: (context, state) {
//           if (state is ProductDetailInitial || state is ProductDetailLoading) {
//             return const Center(
//               child: CircularProgressIndicator(color: AppColors.primary),
//             );
//           }

//           if (state is ProductDetailNotFound) {
//             return _Message(
//               icon: Icons.search_off_rounded,
//               title: 'Product not found',
//               message: state.message,
//               buttonText: 'Go back',
//               onPressed: () => Navigator.of(context).pop(),
//             );
//           }

//           if (state is ProductDetailUnauthorized) {
//             return _Message(
//               icon: Icons.lock_outline_rounded,
//               title: 'Session expired',
//               message: state.message,
//               buttonText: 'Log in again',
//               onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
//                 AppRoutes.login,
//                 (_) => false,
//               ),
//             );
//           }

//           if (state is ProductDetailError) {
//             return _Message(
//               icon: Icons.error_outline_rounded,
//               title: 'Something went wrong',
//               message: state.message,
//               buttonText: 'Try again',
//               onPressed: () => context.read<ProductDetailCubit>().retry(),
//             );
//           }

//           if (state is ProductDetailLoaded) {
//             return RefreshIndicator(
//               color: AppColors.primary,
//               onRefresh: () => context.read<ProductDetailCubit>().retry(),
//               child: _Content(product: state.product),
//             );
//           }

//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }

// class _Content extends StatefulWidget {
//   const _Content({required this.product});

//   final ProductDetailModel product;

//   @override
//   State<_Content> createState() => _ContentState();
// }

// class _ContentState extends State<_Content> {
//   int _qty = 1;

//   ProductDetailModel get product => widget.product;

//   /// أقصى كمية تنختار: المتاح من الباك، أو 99 إذا ما رجّعها
//   int get _max =>
//       min(product.availableQuantity ?? CartCubit.maxPerItem, CartCubit.maxPerItem);

//   void _addToCart() {
//     final cart = context.read<CartCubit>();
//     final messenger = ScaffoldMessenger.of(context);
//     final before = cart.quantityOf(product.id);

//     final inCart = cart.add(
//       productId: product.id,
//       name: product.name,
//       price: product.price,
//       categoryName: product.categoryName,
//       quantity: _qty,
//       maxQuantity: product.availableQuantity,
//     );

//     messenger.hideCurrentSnackBar();

//     if (inCart == 0) {
//       messenger.showSnackBar(
//         const SnackBar(content: Text('This product is not available.')),
//       );
//       return;
//     }

//     final capped = before + _qty > inCart;

//     messenger.showSnackBar(
//       SnackBar(
//         content: Text(
//           capped
//               ? 'Only $inCart available. Cart updated.'
//               : 'Added to cart',
//         ),
//         action: SnackBarAction(
//           label: 'View cart',
//           onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
//         ),
//       ),
//     );

//     setState(() => _qty = 1);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final qty = product.availableQuantity;
//     final outOfStock = !product.isActive || (qty != null && qty <= 0);
//     final inCart = context.watch<CartCubit>().state.quantityOf(product.id);

//     return ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
//       children: [
//         Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 700),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _ImageGallery(images: product.images),
//                 const SizedBox(height: 20),
//                 if (product.categoryName != null)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFEAE7FF),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       product.categoryName!,
//                       style: const TextStyle(
//                         color: AppColors.primary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 12),
//                 Text(
//                   product.name,
//                   style: const TextStyle(
//                     color: AppColors.textPrimary,
//                     fontSize: 24,
//                     fontWeight: FontWeight.w700,
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '\$${product.price.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     color: AppColors.primary,
//                     fontSize: 22,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 14),
//                 _StockBadge(isActive: product.isActive, quantity: qty),
//                 const SizedBox(height: 22),
//                 const Text(
//                   'Description',
//                   style: TextStyle(
//                     color: AppColors.textPrimary,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   (product.description == null ||
//                           product.description!.trim().isEmpty)
//                       ? 'No description available.'
//                       : product.description!,
//                   style: const TextStyle(
//                     color: AppColors.textSecondary,
//                     fontSize: 14,
//                     height: 1.5,
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // ───── اختيار الكمية ─────
//                 if (!outOfStock) ...[
//                   Row(
//                     children: [
//                       const Text(
//                         'Quantity',
//                         style: TextStyle(
//                           color: AppColors.textPrimary,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       const Spacer(),
//                       IconButton(
//                         onPressed:
//                             _qty > 1 ? () => setState(() => _qty--) : null,
//                         icon: const Icon(Icons.remove_circle_outline_rounded),
//                         color: AppColors.primary,
//                       ),
//                       SizedBox(
//                         width: 32,
//                         child: Text(
//                           '$_qty',
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: AppColors.textPrimary,
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed:
//                             _qty < _max ? () => setState(() => _qty++) : null,
//                         icon: const Icon(Icons.add_circle_outline_rounded),
//                         color: AppColors.primary,
//                       ),
//                     ],
//                   ),
//                   if (inCart > 0)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 4),
//                       child: Text(
//                         '$inCart already in your cart',
//                         style: const TextStyle(
//                           color: AppColors.textSecondary,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   const SizedBox(height: 12),
//                 ],

//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: FilledButton.icon(
//                     style: FilledButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                     onPressed: outOfStock ? null : _addToCart,
//                     icon: const Icon(Icons.shopping_bag_outlined),
//                     label: Text(outOfStock ? 'Unavailable' : 'Add to cart'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _StockBadge extends StatelessWidget {
//   const _StockBadge({required this.isActive, required this.quantity});

//   final bool isActive;
//   final int? quantity;

//   @override
//   Widget build(BuildContext context) {
//     late final String text;
//     late final Color color;

//     if (!isActive) {
//       text = 'Not available';
//       color = const Color(0xFFE66F8D);
//     } else if (quantity == null) {
//       text = 'Available';
//       color = const Color(0xFF6BA58A);
//     } else if (quantity! <= 0) {
//       text = 'Out of stock';
//       color = const Color(0xFFE66F8D);
//     } else {
//       text = 'In stock: $quantity';
//       color = const Color(0xFF6BA58A);
//     }

//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(Icons.circle, size: 10, color: color),
//         const SizedBox(width: 6),
//         Text(
//           text,
//           style: TextStyle(
//             color: color,
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _ImageGallery extends StatefulWidget {
//   const _ImageGallery({required this.images});

//   final List<ProductImageModel> images;

//   @override
//   State<_ImageGallery> createState() => _ImageGalleryState();
// }

// class _ImageGalleryState extends State<_ImageGallery> {
//   int _index = 0;

//   Widget _placeholder() {
//     return const Center(
//       child: Icon(
//         Icons.image_outlined,
//         size: 64,
//         color: Color(0xFF8A7DEB),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final images = widget.images;

//     return Column(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: Container(
//             height: 300,
//             width: double.infinity,
//             color: const Color(0xFFF0ECFF),
//             child: images.isEmpty
//                 ? _placeholder()
//                 : PageView.builder(
//                     itemCount: images.length,
//                     onPageChanged: (i) => setState(() => _index = i),
//                     itemBuilder: (_, i) {
//                       return Image.network(
//                         images[i].url,
//                         fit: BoxFit.cover,
//                         headers: const {
//                           'ngrok-skip-browser-warning': 'true',
//                         },
//                         loadingBuilder: (context, child, progress) {
//                           if (progress == null) return child;
//                           return const Center(
//                             child: CircularProgressIndicator(
//                               color: AppColors.primary,
//                             ),
//                           );
//                         },
//                         errorBuilder: (_, __, ___) => _placeholder(),
//                       );
//                     },
//                   ),
//           ),
//         ),
//         if (images.length > 1) ...[
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               for (var i = 0; i < images.length; i++)
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   margin: const EdgeInsets.symmetric(horizontal: 3),
//                   width: i == _index ? 18 : 7,
//                   height: 7,
//                   decoration: BoxDecoration(
//                     color: i == _index
//                         ? AppColors.primary
//                         : const Color(0xFFD5D0F5),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//       ],
//     );
//   }
// }

// class _Message extends StatelessWidget {
//   const _Message({
//     required this.icon,
//     required this.title,
//     required this.message,
//     required this.buttonText,
//     required this.onPressed,
//   });

//   final IconData icon;
//   final String title;
//   final String message;
//   final String buttonText;
//   final VoidCallback onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(28),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 56, color: AppColors.primary),
//             const SizedBox(height: 14),
//             Text(
//               title,
//               style: const TextStyle(
//                 color: AppColors.textPrimary,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: AppColors.textSecondary),
//             ),
//             const SizedBox(height: 18),
//             FilledButton(
//               style: FilledButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//               ),
//               onPressed: onPressed,
//               child: Text(buttonText),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/constants/app_colors.dart';
import 'package:app_development_project/cubit/cart/cart_cubit.dart';
import 'package:app_development_project/cubit/product/product_detail_cubit.dart';
import 'package:app_development_project/cubit/product/product_detail_state.dart';
import 'package:app_development_project/data/models/product_detail_model.dart';
import 'package:app_development_project/data/repository/product_repository.dart';
import 'package:app_development_project/routes/app_routes.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final productId = args is int ? args : null;

    if (productId == null) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.scaffoldBackground,
          elevation: 0,
        ),
        body: const Center(child: Text('Invalid product')),
      );
    }

    return BlocProvider(
      create: (ctx) =>
          ProductDetailCubit(ctx.read<ProductRepository>())..load(productId),
      child: const _ProductDetailsView(),
    );
  }
}

class _ProductDetailsView extends StatelessWidget {
  const _ProductDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
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
          'Product details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          BlocBuilder<CartCubit, dynamic>(
            builder: (context, _) {
              final count = context.watch<CartCubit>().state.totalCount;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  tooltip: 'Cart',
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.cart),
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF29244D)
                                  .withValues(alpha: 0.07),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: AppColors.textDark,
                          size: 20,
                        ),
                      ),
                      if (count > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.scaffoldBackground,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                count > 99 ? '99+' : '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          if (state is ProductDetailInitial || state is ProductDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ProductDetailNotFound) {
            return _Message(
              icon: Icons.search_off_rounded,
              title: 'Product not found',
              message: state.message,
              buttonText: 'Go back',
              onPressed: () => Navigator.of(context).pop(),
            );
          }

          if (state is ProductDetailUnauthorized) {
            return _Message(
              icon: Icons.lock_outline_rounded,
              title: 'Session expired',
              message: state.message,
              buttonText: 'Log in again',
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (_) => false,
              ),
            );
          }

          if (state is ProductDetailError) {
            return _Message(
              icon: Icons.error_outline_rounded,
              title: 'Something went wrong',
              message: state.message,
              buttonText: 'Try again',
              onPressed: () => context.read<ProductDetailCubit>().retry(),
            );
          }

          if (state is ProductDetailLoaded) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<ProductDetailCubit>().retry(),
              child: _Content(product: state.product),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({required this.product});

  final ProductDetailModel product;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  int _qty = 1;

  ProductDetailModel get product => widget.product;

  int get _max =>
      min(product.availableQuantity ?? CartCubit.maxPerItem, CartCubit.maxPerItem);

  void _addToCart() {
    final cart = context.read<CartCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final before = cart.quantityOf(product.id);

    final inCart = cart.add(
      productId: product.id,
      name: product.name,
      price: product.price,
      categoryName: product.categoryName,
      quantity: _qty,
      maxQuantity: product.availableQuantity,
    );

    messenger.hideCurrentSnackBar();

    if (inCart == 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text('This product is not available.')),
      );
      return;
    }

    final capped = before + _qty > inCart;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          capped
              ? 'Only $inCart available. Cart updated.'
              : 'Added to cart',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'View cart',
          textColor: AppColors.primaryLight,
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
        ),
      ),
    );

    setState(() => _qty = 1);
  }

  @override
  Widget build(BuildContext context) {
    final qty = product.availableQuantity;
    final outOfStock = !product.isActive || (qty != null && qty <= 0);
    final inCart = context.watch<CartCubit>().state.quantityOf(product.id);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ───── معرض الصور ─────
                _ImageGallery(images: product.images),
                const SizedBox(height: 22),

                // ───── كرت المعلومات ─────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF29244D).withValues(alpha: 0.07),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.categoryName != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product.categoryName!,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Spacer(),
                          _StockBadge(
                            isActive: product.isActive,
                            quantity: qty,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ───── الوصف ─────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF29244D).withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Description',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        (product.description == null ||
                                product.description!.trim().isEmpty)
                            ? 'No description available.'
                            : product.description!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.5,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ───── الكمية + زر الإضافة ─────
                if (!outOfStock) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF29244D).withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _QtyButton(
                              icon: Icons.remove_rounded,
                              enabled: _qty > 1,
                              onTap: () => setState(() => _qty--),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: Text(
                                '$_qty',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            _QtyButton(
                              icon: Icons.add_rounded,
                              enabled: _qty < _max,
                              onTap: () => setState(() => _qty++),
                            ),
                            const Spacer(),
                            if (inCart > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$inCart in cart',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor:
                                  AppColors.primary.withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onPressed: _addToCart,
                            icon: const Icon(Icons.shopping_bag_outlined,
                                size: 20),
                            label: const Text('Add to cart'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE8E7EF),
                        foregroundColor: AppColors.textSecondary,
                        disabledBackgroundColor: const Color(0xFFE8E7EF),
                        disabledForegroundColor: AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: null,
                      icon: const Icon(Icons.block_rounded, size: 20),
                      label: const Text('Unavailable'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? AppColors.primary.withValues(alpha: 0.12)
          : const Color(0xFFF0EEF8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppColors.primary : AppColors.textGray,
          ),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.isActive, required this.quantity});

  final bool isActive;
  final int? quantity;

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color color;
    late final Color bg;

    if (!isActive) {
      text = 'Not available';
      color = const Color(0xFFE66F8D);
      bg = const Color(0xFFFFEAF0);
    } else if (quantity == null) {
      text = 'Available';
      color = const Color(0xFF6BA58A);
      bg = const Color(0xFFE4F4EA);
    } else if (quantity! <= 0) {
      text = 'Out of stock';
      color = const Color(0xFFE66F8D);
      bg = const Color(0xFFFFEAF0);
    } else {
      text = 'In stock · $quantity';
      color = const Color(0xFF6BA58A);
      bg = const Color(0xFFE4F4EA);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageGallery extends StatefulWidget {
  const _ImageGallery({required this.images});

  final List<ProductImageModel> images;

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int _index = 0;

  Widget _placeholder() {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF0ECFF), Color(0xFFE8E2FF)],
            ),
          ),
        ),
        Positioned(
          right: -30,
          bottom: -30,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Center(
          child: Icon(
            Icons.image_outlined,
            size: 64,
            color: Color(0xFF8A7DEB),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;

    return Column(
      children: [
        Container(
          height: 320,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF29244D).withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: images.isEmpty
                ? _placeholder()
                : PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) {
                      return Image.network(
                        images[i].url,
                        fit: BoxFit.cover,
                        headers: const {
                          'ngrok-skip-browser-warning': 'true',
                        },
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFFF0ECFF),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => _placeholder(),
                      );
                    },
                  ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < images.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 3.5),
                  width: i == _index ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? AppColors.primary
                        : const Color(0xFFD5D0F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onPressed,
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}