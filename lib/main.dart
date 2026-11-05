import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/routes/app_routes.dart';
import 'package:app_development_project/features/auth/data/datasources/token_storage.dart';
import 'package:app_development_project/data/network/dio_client.dart';
import 'package:app_development_project/data/network/app_logger.dart';

import 'package:app_development_project/data/services/auth_service.dart';
import 'package:app_development_project/data/services/category_service.dart';
import 'package:app_development_project/data/services/product_service.dart';
import 'package:app_development_project/data/services/order_service.dart';

import 'package:app_development_project/data/repository/auth_repository.dart';
import 'package:app_development_project/data/repository/category_repository.dart';
import 'package:app_development_project/data/repository/product_repository.dart';
import 'package:app_development_project/data/repository/order_repository.dart';

import 'package:app_development_project/cubit/auth/login/login_cubit.dart';

import 'package:app_development_project/presentation/screens/home_screen.dart';
import 'package:app_development_project/presentation/screens/login_screen.dart';
import 'package:app_development_project/presentation/screens/product_detail_screen.dart';
import 'package:app_development_project/presentation/screens/orders_screen.dart';
import 'package:app_development_project/presentation/screens/order_details_screen.dart';
import 'package:app_development_project/presentation/screens/create_order_screen.dart';
import 'package:app_development_project/presentation/screens/profile_screen.dart';
import 'package:app_development_project/cubit/cart/cart_cubit.dart';
import 'package:app_development_project/presentation/screens/cart_screen.dart';
import 'package:app_development_project/data/repository/notification_repository.dart';
import 'package:app_development_project/data/services/notification_service.dart';
import 'package:app_development_project/presentation/screens/notifications_screen.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();

  final tokenStorage = TokenStorage();
  final dioClient = DioClient(tokenStorage);

  // Auth
  final authService = AuthService(dioClient.dio);
  final authRepository = AuthRepository(
    authService: authService,
    tokenStorage: tokenStorage,
  );

  // Categories
  final categoryService = CategoryService(dioClient.dio);
  final categoryRepository = CategoryRepository(categoryService);

  // Products
  final productService = ProductService(dioClient.dio);
  final productRepository = ProductRepository(productService);

  // Orders
  final orderService = OrderService(dioClient.dio);
  final orderRepository = OrderRepository(orderService);

  final hasToken = await tokenStorage.hasToken();

  final notificationService = NotificationService(dioClient.dio);
final notificationRepository = NotificationRepository(notificationService);

  runApp(
    MyApp(
      authRepository: authRepository,
      categoryRepository: categoryRepository,
      productRepository: productRepository,
      orderRepository: orderRepository,
      initialRoute: hasToken ? AppRoutes.home : AppRoutes.login,
      notificationRepository: notificationRepository, 
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final CategoryRepository categoryRepository;
  final ProductRepository productRepository;
  final OrderRepository orderRepository;
  final String initialRoute;
  final NotificationRepository notificationRepository; 

  const MyApp({
    super.key,
    required this.authRepository,
    required this.categoryRepository,
    required this.productRepository,
    required this.orderRepository,
    required this.initialRoute,
    required this.notificationRepository, 
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<CategoryRepository>.value(
          value: categoryRepository,
        ),
        RepositoryProvider<ProductRepository>.value(
          value: productRepository,
        ),
        RepositoryProvider<OrderRepository>.value(value: orderRepository),
        RepositoryProvider<NotificationRepository>.value(value: notificationRepository),
      ],
      
      child: MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => LoginCubit(authRepository)),
    BlocProvider(create: (_) => CartCubit()),
  ],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: initialRoute,
    routes: {
      AppRoutes.login: (_) => const LoginScreen(),
      AppRoutes.home: (_) => const HomeScreen(),
      AppRoutes.productDetails: (_) => const ProductDetailsScreen(),
      AppRoutes.orders: (_) => const OrdersScreen(),
      AppRoutes.orderDetails: (_) => const OrderDetailsScreen(),
      AppRoutes.createOrder: (_) => const CreateOrderScreen(),
      AppRoutes.profile: (_) => const ProfileScreen(),
      AppRoutes.cart: (_) => const CartScreen(),
      AppRoutes.notifications: (_) => const NotificationsScreen(),
    },
  ),
),
    );
  }
}