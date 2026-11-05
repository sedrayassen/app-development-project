import 'package:flutter/material.dart';

import 'package:app_development_project/constants/app_colors.dart';
import 'package:app_development_project/data/models/order_model.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status});

  final String status;

  Color get _color {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFE6A94F);
      case OrderStatus.confirmed:
        return const Color(0xFF5A9EDD);
      case OrderStatus.shipped:
        return const Color(0xFF8A7DEB);
      case OrderStatus.delivered:
        return const Color(0xFF6BA58A);
      case OrderStatus.cancelled:
        return const Color(0xFFE66F8D);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}