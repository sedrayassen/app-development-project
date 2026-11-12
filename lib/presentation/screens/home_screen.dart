

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/constants/app_colors.dart';
import 'package:app_development_project/cubit/category/category_cubit.dart';
import 'package:app_development_project/cubit/category/category_state.dart';
import 'package:app_development_project/cubit/product/product_cubit.dart';
import 'package:app_development_project/cubit/product/product_state.dart';
import 'package:app_development_project/data/models/category_model.dart';
import 'package:app_development_project/data/models/product_model.dart';
import 'package:app_development_project/data/repository/category_repository.dart';
import 'package:app_development_project/data/repository/product_repository.dart';
import 'package:app_development_project/routes/app_routes.dart';
import 'package:app_development_project/cubit/cart/cart_cubit.dart';
import 'package:app_development_project/cubit/cart/cart_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              CategoryCubit(context.read<CategoryRepository>())
                ..getCategories(),
        ),
        BlocProvider(
          create: (context) =>
              ProductsCubit(context.read<ProductRepository>())..load(),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _selectedDestination = 0;
  final Set<int> _favoriteProducts = {};

  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _showSearch = false;

  int? _selectedCategoryId; // null = All
  String? _search;
  double? _minPrice;
  double? _maxPrice;
  String? _sort;
  String? _direction;

  static const _allCategory = _Category(
    'All',
    Icons.grid_view_rounded,
    Color(0xFFEAE7FF),
  );

  bool get _hasActiveFilters =>
      _minPrice != null || _maxPrice != null || _sort != null;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 300) {
        context.read<ProductsCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _searchController.dispose();
    super.dispose();
  }


  void _reload() {
    context.read<ProductsCubit>().load(
          search: _search,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          sort: _sort,
          direction: _direction,
          categoryId: _selectedCategoryId,
        );
  }

  void _selectCategory(int? id) {
    if (_selectedCategoryId == id) return;
    setState(() => _selectedCategoryId = id);
    _reload();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search = value.trim().isEmpty ? null : value.trim();
      _reload();
    });
  }

  void _toggleSearch() {
    setState(() => _showSearch = !_showSearch);
    if (!_showSearch && _searchController.text.isNotEmpty) {
      _searchController.clear();
      _search = null;
      _reload();
    }
  }

  void _clearFilters() {
    setState(() {
      _minPrice = null;
      _maxPrice = null;
      _sort = null;
      _direction = null;
    });
    _reload();
  }

  void _toggleFavorite(int id) {
    setState(() {
      if (!_favoriteProducts.add(id)) _favoriteProducts.remove(id);
    });
  }

    Future<void> _onRefresh() async {
    await context.read<CategoryCubit>().getCategories();
    _reload();
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }


  Future<void> _openFilterSheet() async {
    final minCtrl = TextEditingController(text: _minPrice?.toString() ?? '');
    final maxCtrl = TextEditingController(text: _maxPrice?.toString() ?? '');
    String? sort = _sort;
    String? direction = _direction;

    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    22,
                    12,
                    22,
                    MediaQuery.of(ctx).viewInsets.bottom + 22,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDD9F3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const _SheetLabel('Price range'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _PriceField(controller: minCtrl, label: 'Min'),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '–',
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _PriceField(controller: maxCtrl, label: 'Max'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const _SheetLabel('Sort by'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final s in const ['price', 'name'])
                            _OptionChip(
                              label: s == 'price' ? 'Price' : 'Name',
                              selected: sort == s,
                              onTap: () =>
                                  setSheet(() => sort = sort == s ? null : s),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const _SheetLabel('Order'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _OptionChip(
                            label: 'Ascending',
                            selected: direction == 'asc',
                            onTap: () => setSheet(
                              () => direction = direction == 'asc' ? null : 'asc',
                            ),
                          ),
                          _OptionChip(
                            label: 'Descending',
                            selected: direction == 'desc',
                            onTap: () => setSheet(
                              () => direction =
                                  direction == 'desc' ? null : 'desc',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.35),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  minCtrl.clear();
                                  maxCtrl.clear();
                                  setSheet(() {
                                    sort = null;
                                    direction = null;
                                  });
                                },
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 52,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'Apply',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (applied == true) {
      setState(() {
        _minPrice = double.tryParse(minCtrl.text.trim());
        _maxPrice = double.tryParse(maxCtrl.text.trim());
        _sort = sort;
        _direction = sort == null ? null : (direction ?? 'asc');
      });
      _reload();
    }
  }

  _Category _mapApiCategory(CategoryModel category) {
    final style = _StyleHelper.byName(category.slug);
    return _Category(category.name, style.icon, style.categoryBg);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 68,
        titleSpacing: 24,
        title: const Text(
          'Discover',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        actions: [
          _AppBarAction(
            icon: _showSearch ? Icons.close_rounded : Icons.search_rounded,
            label: 'Search',
            onPressed: _toggleSearch,
          ),
          _AppBarAction(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            onPressed: () =>
      Navigator.of(context).pushNamed(AppRoutes.notifications),
          ),
          BlocBuilder<CartCubit, CartState>(
            buildWhen: (a, b) => a.totalCount != b.totalCount,
            builder: (context, cart) {
              final count = cart.totalCount;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _AppBarAction(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Cart',
                  badge: count == 0 ? null : (count > 99 ? '99+' : '$count'),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.cart),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _onRefresh,
        child : SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: LayoutBuilder(
              builder: (context, c) {
                final width = c.maxWidth;
                final columns = width >= 900
                    ? 4
                    : width >= 620
                        ? 3
                        : 2;
                const spacing = 16.0;
                final cardWidth = (width - spacing * (columns - 1)) / columns;
                final cardHeight = cardWidth + 112;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: _showSearch
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: _SearchField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                              ),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    _WelcomeCard(width: width),
                    const SizedBox(height: 30),
                    const _SectionHeading(title: 'Shop by category'),
                    const SizedBox(height: 16),
                    _buildCategories(),
                    const SizedBox(height: 30),
                    _SectionHeading(
                      title: 'Popular Products',
                      action: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Tooltip(
                            message: 'Filter',
                            child: Material(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: _openFilterSheet,
                                child: const SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Icon(
                                    Icons.tune_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_hasActiveFilters)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE66F8D),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.scaffoldBackground,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_hasActiveFilters)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ActionChip(
                            avatar: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              'Clear filters',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.08),
                            side: BorderSide.none,
                            shape: const StadiumBorder(),
                            onPressed: _clearFilters,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildProducts(columns, spacing, cardHeight),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      ),
      bottomNavigationBar: Container(
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
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: NavigationBar(
            selectedIndex: _selectedDestination,
            onDestinationSelected: (i) {
              if (i == 2) {
                Navigator.of(context).pushNamed(AppRoutes.cart);
                return;
              }
              if (i == 3) {
                Navigator.of(context).pushNamed(AppRoutes.orders);
                return;
              }
              if (i == 4) {
                Navigator.of(context).pushNamed(AppRoutes.profile);
                return;
              }
              setState(() => _selectedDestination = i);
            },
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            indicatorColor: AppColors.primary.withValues(alpha: 0.12),
            height: 72,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon:
                    Icon(Icons.home_rounded, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon:
                    Icon(Icons.grid_view_rounded, color: AppColors.primary),
                label: 'Categories',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon:
                    Icon(Icons.shopping_bag_rounded, color: AppColors.primary),
                label: 'Cart',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon:
                    Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon:
                    Icon(Icons.person_rounded, color: AppColors.primary),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────── الأصناف ─────────────

  Widget _buildCategories() {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading || state is CategoryInitial) {
          return const _CategoriesSkeleton();
        }

        if (state is CategoryFailure) {
          return SizedBox(
            height: 105,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<CategoryCubit>().getCategories(),
                    child: const Text(
                      'Try again',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is CategorySuccess) {
          final categories = state.categories;
          return SizedBox(
            height: 105,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _CategoryTile(
                    category: _allCategory,
                    isSelected: _selectedCategoryId == null,
                    onTap: () => _selectCategory(null),
                  );
                }
                final apiCategory = categories[index - 1];
                return _CategoryTile(
                  category: _mapApiCategory(apiCategory),
                  isSelected: _selectedCategoryId == apiCategory.id,
                  onTap: () => _selectCategory(apiCategory.id),
                );
              },
            ),
          );
        }

        return const SizedBox(height: 105);
      },
    );
  }

  // ───────────── المنتجات ─────────────

  Widget _buildProducts(int columns, double spacing, double cardHeight) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state is ProductsInitial || state is ProductsLoading) {
          return _Pulse(
            child: GridView.builder(
              itemCount: columns * 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                mainAxisExtent: cardHeight,
              ),
              itemBuilder: (_, __) => const _ProductSkeleton(),
            ),
          );
        }

        if (state is ProductsError) {
          return _StateView(
            icon: Icons.cloud_off_rounded,
            title: 'Something went wrong',
            message: state.message,
            buttonText: 'Try again',
            onPressed: _reload,
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
          return const _StateView(
            icon: Icons.search_off_rounded,
            title: 'No products found',
            message: 'Try another category, search or filter.',
          );
        }

        return Column(
          children: [
            GridView.builder(
              itemCount: products.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                mainAxisExtent: cardHeight,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductCard(
                  product: product,
                  isFavorite: _favoriteProducts.contains(product.id),
                  onFavoritePressed: () => _toggleFavorite(product.id),
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.productDetails,
                    arguments: product.id,
                  ),
                );
              },
            ),
            if (loadingMore)
              const Padding(
                padding: EdgeInsets.all(22),
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.6,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}


class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShadow.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(color: AppColors.textGray, fontSize: 14.5),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear',
                icon: const Icon(
                  Icons.close_rounded,
                  size: 19,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              );
            },
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.45),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final compact = width < 380;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gradientStart, Color(0xFFF9F8FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryShadow.withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -46,
            child: _Blob(
              size: 150,
              color: AppColors.primary.withValues(alpha: 0.09),
            ),
          ),
          Positioned(
            right: 54,
            bottom: -58,
            child: _Blob(
              size: 110,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 18 : 22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'MONDAY, JUNE 10',
                              style: TextStyle(
                                color: AppColors.textGray,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Good morning, Alex',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: compact ? 20 : 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Find something you’ll love today.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: compact ? 52 : 60,
                  height: compact ? 52 : 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryShadow,
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
    this.isSelected = false,
  });

  final _Category category;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : category.background,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.35)
                          : const Color(0xFF29244D).withValues(alpha: 0.05),
                      blurRadius: isSelected ? 16 : 10,
                      offset: Offset(0, isSelected ? 7 : 4),
                    ),
                  ],
                ),
                child: Icon(
                  category.icon,
                  color: isSelected ? Colors.white : const Color(0xFF514A78),
                  size: 27,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onTap,
  });

  final ProductModel product;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _StyleHelper.byName(product.categoryName ?? '');
    final tint = Color.lerp(style.background, style.accent, 0.24)!;

    return _PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
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
            // ───── منطقة الصورة ─────
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [style.background, tint],
                              ),
                            ),
                          ),
                          Positioned(
                            right: -26,
                            bottom: -26,
                            child: _Blob(
                              size: 96,
                              color: style.accent.withValues(alpha: 0.16),
                            ),
                          ),
                          Positioned(
                            left: -18,
                            top: 44,
                            child: _Blob(
                              size: 56,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.72),
                                boxShadow: [
                                  BoxShadow(
                                    color: style.accent.withValues(alpha: 0.28),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                style.icon,
                                size: 40,
                                color: style.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // تصنيف المنتج
                  Positioned(
                    left: 8,
                    top: 8,
                    right: 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          product.categoryName ?? 'General',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: style.accent,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // المفضلة
                  Positioned(
                    right: 7,
                    top: 7,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: onFavoritePressed,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              key: ValueKey(isFavorite),
                              size: 18,
                              color: isFavorite
                                  ? const Color(0xFFE66F8D)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ───── البيانات ─────
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 4, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(11),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  const _PressScale({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _AppBarAction extends StatelessWidget {
  const _AppBarAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: label,
        child: Container(
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
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        icon,
                        key: ValueKey(icon),
                        color: AppColors.textDark,
                        size: 22,
                      ),
                    ),
                    if (badge != null)
                      Positioned(
                        right: -3,
                        top: -3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          constraints: const BoxConstraints(
                            minWidth: 19,
                            minHeight: 19,
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
                              badge!,
                              textAlign: TextAlign.center,
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
            ),
          ),
        ),
      ),
    );
  }
}


class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGray),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        prefixText: '\$ ',
        prefixStyle: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: const Color(0xFFF7F5FF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFF4F2FF),
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}


class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 12),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 38, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 18),
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
                  buttonText!,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ───────────── Skeleton (حالة التحميل) ─────────────

class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(begin: 0.45, end: 1)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({this.width, this.height, this.radius = 12});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE9E6F7),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _CategoriesSkeleton extends StatelessWidget {
  const _CategoriesSkeleton();

  @override
  Widget build(BuildContext context) {
    return _Pulse(
      child: SizedBox(
        height: 105,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, __) => const SizedBox(
            width: 72,
            child: Column(
              children: [
                _SkeletonBox(width: 64, height: 64, radius: 22),
                SizedBox(height: 10),
                _SkeletonBox(width: 40, height: 10, radius: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductSkeleton extends StatelessWidget {
  const _ProductSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _SkeletonBox(width: double.infinity, radius: 18),
          ),
          SizedBox(height: 14),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: _SkeletonBox(width: 100, height: 12, radius: 6),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.fromLTRB(6, 0, 6, 6),
            child: _SkeletonBox(width: 60, height: 14, radius: 6),
          ),
        ],
      ),
    );
  }
}


class _Category {
  const _Category(this.name, this.icon, this.background);

  final String name;
  final IconData icon;
  final Color background;
}

class _Style {
  const _Style(this.icon, this.categoryBg, this.background, this.accent);

  final IconData icon;
  final Color categoryBg;
  final Color background;
  final Color accent;
}

class _StyleHelper {
  static _Style byName(String raw) {
    final n = raw.toLowerCase();

    if (n.contains('book')) {
      return const _Style(Icons.menu_book_rounded, Color(0xFFEAE7FF),
          Color(0xFFF0ECFF), Color(0xFF8A7DEB));
    }
    if (n.contains('electr')) {
      return const _Style(Icons.headphones_rounded, Color(0xFFE2F2FF),
          Color(0xFFE8F4FF), Color(0xFF5A9EDD));
    }
    if (n.contains('home') || n.contains('kitchen')) {
      return const _Style(Icons.chair_alt_rounded, Color(0xFFE4F4EA),
          Color(0xFFEAF3EF), Color(0xFF6BA58A));
    }
    if (n.contains('sport')) {
      return const _Style(Icons.sports_basketball_rounded, Color(0xFFFFF1D9),
          Color(0xFFFFF2DF), Color(0xFFE6A94F));
    }
    return const _Style(Icons.category_rounded, Color(0xFFEAE7FF),
        Color(0xFFFFEAE1), Color(0xFFDA8766));
  }
}