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
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../presentation/widgets/main_layout.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../pages/stock_page.dart';
import '../../pages/produit_page.dart';
import '../../pages/categorie_page.dart';
import '../../pages/reglement_page.dart';

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
