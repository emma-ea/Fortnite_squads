import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../screens/splash/splash_screen.dart'; // You'll need a simple splash
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/onboarding/profile_setup_screen.dart';
import '../screens/squads/squads_list_screen.dart';
import '../screens/squads/create_squad_screen.dart'; // Placeholder
import '../screens/squads/squad_detail_screen.dart'; // Placeholder
import '../screens/messaging/squad_chat_screen.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: StreamListenable(authBloc.stream), // Listens to Auth State changes
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuth = authState is Authenticated;
      final isUnAuth = authState is Unauthenticated;
      
      final isOnLogin = state.matchedLocation == '/auth/login';
      final isOnRegister = state.matchedLocation == '/auth/register';
      final isOnVerify = state.matchedLocation == '/auth/verify-email';
      final isPublicRoute = isOnLogin || isOnRegister || isOnVerify;

      // 1. If unauthenticated and trying to access private route -> Login
      if (isUnAuth && !isPublicRoute) {
        return '/auth/login';
      }

      // 2. If authenticated and on login/register -> Home
      if (isAuth && isPublicRoute) {
        return '/home';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/verify-email',
        builder: (context, state) {
          // Handle deep link param: /auth/verify-email?token=xyz
          final token = state.uri.queryParameters['token'];
          return VerifyEmailScreen(token: token);
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const SquadsListScreen(),
        routes: [
           // Nested routes for Squads
           GoRoute(
             path: 'create', // /home/create
             builder: (context, state) => const CreateSquadScreen(),
           ),
        ],
      ),
      GoRoute(
        path: '/squads/:id',
        builder: (context, state) {
           final id = state.pathParameters['id']!;
           return SquadDetailScreen(squadId: id); 
        },
      ),
      GoRoute(
        path: '/squads/:id/chat',
        builder: (context, state) {
           final id = state.pathParameters['id']!;
           final extra = state.extra as Map<String, dynamic>?; 
           return SquadChatScreen(
             squadId: id, 
             squadName: extra?['name'] ?? 'Squad Chat'
           );
        },
      ),
    ],
  );
}

// Helper to convert Stream to Listenable for GoRouter refresh
class StreamListenable extends ChangeNotifier {
  final Stream stream;
  StreamListenable(this.stream) {
    stream.listen((_) => notifyListeners());
  }
}