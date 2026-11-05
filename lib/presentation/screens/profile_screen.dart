import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/constants/app_colors.dart';
import 'package:app_development_project/cubit/auth/logout/logout_cubit.dart';
import 'package:app_development_project/cubit/auth/logout/logout_state.dart';
import 'package:app_development_project/data/repository/auth_repository.dart';
import 'package:app_development_project/routes/app_routes.dart';
import 'package:app_development_project/cubit/cart/cart_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => LogoutCubit(ctx.read<AuthRepository>()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final cubit = context.read<LogoutCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed == true) cubit.logout();
  }

  Future<void> _showFailureDialog(
    BuildContext context,
    LogoutFailure state,
  ) {
    final cubit = context.read<LogoutCubit>();

    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.cloud_off_rounded,
          color: AppColors.primary,
          size: 36,
        ),
        title: const Text('Could not log out'),
        content: Text(
          state.isNetwork
              ? '${state.message}\n\nYou can try again, or log out on this '
                  'device only (your session on the server stays active).'
              : state.message,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              cubit.forceLogout();
            },
            child: const Text('Log out anyway'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              cubit.logout();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogoutCubit, LogoutState>(
      listener: (context, state) {
  if (state is LogoutSuccess || state is LogoutSessionExpired) {
    context.read<CartCubit>().clear();
    _goToLogin(context);
  } else if (state is LogoutFailure) {
    _showFailureDialog(context, state);
  }
},
      builder: (context, state) {
        final loading = state is LogoutLoading;

        return PopScope(
          canPop: !loading,
          child: Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: AppBar(
              backgroundColor: AppColors.scaffoldBackground,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAE7FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 44,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _Tile(
                  icon: Icons.receipt_long_outlined,
                  title: 'My orders',
                  onTap: loading
                      ? null
                      : () => Navigator.of(context).pushNamed(AppRoutes.orders),
                ),
                const SizedBox(height: 12),
                _Tile(
                  icon: Icons.logout_rounded,
                  title: 'Log out',
                  color: const Color(0xFFE66F8D),
                  loading: loading,
                  onTap: loading ? null : () => _confirmLogout(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppColors.textPrimary,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color color;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textGray,
                ),
            ],
          ),
        ),
      ),
    );
  }
}