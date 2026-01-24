import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/user_list_screen.dart';
import '../../features/admin/presentation/screens/user_details_screen.dart';
import '../../features/admin/presentation/screens/admin_create_user_screen.dart';
import '../../features/admin/presentation/screens/admin_edit_user_screen.dart';
import '../../features/admin/presentation/screens/admin_order_list_screen.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../presentation/widgets/main_layout.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../pages/stock_page.dart';
import '../../pages/produit_page.dart';
import '../../pages/categorie_page.dart';
import '../../pages/reglement_page.dart';
import '../../features/commerce/presentation/screens/shop_screen.dart';
import '../../features/commerce/presentation/screens/cart_screen.dart';
import '../../features/commerce/presentation/screens/checkout_screen.dart';
import '../../features/commerce/presentation/screens/orders_screen.dart';
import '../../features/commerce/presentation/screens/order_details_screen.dart';
import '../../features/complaints/presentation/screens/complaints_screen.dart';
import '../../features/complaints/presentation/screens/complaint_chat_screen.dart';
import '../../features/complaints/presentation/screens/create_complaint_screen.dart';
import '../../features/delivery/presentation/screens/delivery_orders_screen.dart';
import '../../features/delivery/presentation/screens/scan_qr_screen.dart';
import '../../pages/fournisseur_page.dart';
import '../../pages/secteur_activite_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      if (previous?.user != next.user || previous?.isInitialized != next.isInitialized) {
        notifyListeners();
      }
    });
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.read(routerNotifierProvider);
  
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      
      // Wait for initialization before redirecting
      if (!authState.isInitialized) {
        return '/splash';
      }

      final isLoggedIn = authState.user != null;
      final isGoingToAuth = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/register' || 
                           state.matchedLocation == '/welcome' ||
                           state.matchedLocation == '/splash' ||
                           state.matchedLocation == '/forgot-password' ||
                           state.matchedLocation == '/reset-password' ||
                           state.matchedLocation == '/verify-email' ||
                           state.matchedLocation == '/auth-callback';

      // Always move away from splash once initialized
      if (state.matchedLocation == '/splash') {
        return isLoggedIn ? '/' : '/welcome';
      }

      if (!isLoggedIn && !isGoingToAuth) {
        return '/welcome';
      }

      // If stuck on callback but not logged in/loading, go to login
      // We check that we are NOT loading to avoid premature redirection
      if (state.matchedLocation == '/auth-callback' && !isLoggedIn && !authState.isLoading && authState.isInitialized) {
        if (authState.error != null) return '/login'; // Redirect on failure
        return null; // Stay here while waiting for handlesOAuth2Success to start
      }

      if (isLoggedIn && isGoingToAuth) {
        return authState.user!.role == 'ADMIN' ? '/admin/dashboard' : '/';
      }
      
      // Admin protection
      if (isLoggedIn && state.matchedLocation.startsWith('/admin') && authState.user!.role != 'ADMIN') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return ResetPasswordScreen(token: token);
        },
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return VerifyEmailScreen(token: token);
        },
      ),
      GoRoute(
        path: '/auth-callback',
        builder: (context, state) {
          final accessToken = state.uri.queryParameters['accessToken'];
          final refreshToken = state.uri.queryParameters['refreshToken'];
          
          if (accessToken != null && refreshToken != null) {
            // We use a Future.delayed to avoid state modification during build
            Future.microtask(() async {
              await ref.read(authProvider.notifier).handleOAuth2Success(accessToken, refreshToken);
            });
          }
          return const SplashScreen(); // Show splash while processing
        },
      ),
      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const UserListScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const AdminCreateUserScreen(),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final user = state.extra as User;
              return AdminEditUserScreen(user: user);
            },
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) => UserDetailsScreen(userId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const AdminOrderListScreen(),
      ),
      // Main App Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'stocks',
                    builder: (context, state) => const StocksPage(),
                  ),
                  GoRoute(
                    path: 'products',
                    builder: (context, state) => const ProduitsPage(),
                  ),
                  GoRoute(
                    path: 'categories',
                    builder: (context, state) => const CategoriesPage(),
                  ),
                  GoRoute(
                    path: 'payments',
                    builder: (context, state) => const ReglementsPage(),
                  ),
                  GoRoute(
                    path: 'fournisseurs',
                    builder: (context, state) => const FournisseurPage(),
                  ),
                  GoRoute(
                    path: 'secteurs',
                    builder: (context, state) => const SecteurActivitePage(),
                  ),
                  // Commerce shortcuts accessible from Home
                  GoRoute(
                    path: 'complaints',
                    builder: (context, state) => const ComplaintsScreen(),
                    routes: [
                      GoRoute(
                        path: 'create',
                        builder: (context, state) {
                          final orderId = int.tryParse(state.uri.queryParameters['orderId'] ?? '');
                          return CreateComplaintScreen(orderId: orderId);
                        },
                      ),
                      GoRoute(
                        path: ':id',
                        builder: (context, state) => ComplaintChatScreen(
                          complaintId: int.parse(state.pathParameters['id']!),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'delivery',
                    builder: (context, state) => const DeliveryOrdersScreen(),
                    routes: [
                      GoRoute(
                        path: 'scan/:orderId',
                        builder: (context, state) => ScanQrScreen(
                          orderId: int.parse(state.pathParameters['orderId']!),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Shop
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shop',
                builder: (context, state) => const ShopScreen(),
                routes: [
                  GoRoute(
                    path: 'cart',
                    builder: (context, state) => const CartScreen(),
                  ),
                  GoRoute(
                    path: 'checkout',
                    builder: (context, state) => const CheckoutScreen(),
                  ),
                ],
              ),
              // Backward-compatible direct routes
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
              GoRoute(
                path: '/checkout',
                builder: (context, state) => const CheckoutScreen(),
              ),
            ],
          ),
          // Orders
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => OrderDetailsScreen(
                      orderId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
