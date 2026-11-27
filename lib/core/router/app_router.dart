import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/verify_email_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/onboarding/providers/onboarding_provider.dart';
import '../../features/profile/presentation/profile_screen.dart';

import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/checkout/presentation/order_success_screen.dart';
import '../../features/orders/presentation/orders_history_screen.dart';

import '../../features/notifications/presentation/notification_settings_screen.dart';

const _publicRoutes = {'/login', '/register', '/forgot-password'};

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final seen = ref.read(onboardingSeenProvider);
      final user = ref.read(sessionProvider);
      final loc = state.matchedLocation;

      if (!seen) return loc == '/onboarding' ? null : '/onboarding';
      if (loc == '/onboarding') return user == null ? '/login' : '/';

      if (user == null) return _publicRoutes.contains(loc) ? null : '/login';

      if (!user.canAccess) return loc == '/verify-email' ? null : '/verify-email';

      if (_publicRoutes.contains(loc) || loc == '/verify-email') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (c, s) => const HomeShell()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (c, s) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/verify-email', builder: (c, s) => const VerifyEmailScreen()),
      GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
            GoRoute(path: '/cart', builder: (c, s) => const CartScreen()),
      GoRoute(path: '/checkout', builder: (c, s) => const CheckoutScreen()),
      GoRoute(
        path: '/order-success/:id',
        builder: (c, s) => OrderSuccessScreen(orderId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/orders', builder: (c, s) => const OrdersHistoryScreen()),
      GoRoute(path: '/notifications', builder: (c, s) => const NotificationSettingsScreen(),),
    ],
  );

  // Re-evalúa las redirecciones cuando cambia la sesión o el onboarding,
  // sin usar ChangeNotifier/ValueNotifier ni reconstruir el router.
  ref.listen(sessionProvider, (_, _) => router.refresh());
  ref.listen(onboardingSeenProvider, (_, _) => router.refresh());
  ref.onDispose(router.dispose);

  return router;
});