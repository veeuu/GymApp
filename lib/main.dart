import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/local_auth_service.dart';
import 'services/client_auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/client/client_dashboard_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArjunGymApp());
}

class ArjunGymApp extends StatelessWidget {
  const ArjunGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalAuthService()),
        ChangeNotifierProvider(create: (_) => ClientAuthService()),
      ],
      child: MaterialApp(
        title: 'Arjun Gym App',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/client-dashboard': (context) => const ClientDashboardScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocalAuthService, ClientAuthService>(
      builder: (context, trainerAuth, clientAuth, child) {
        // Check if either trainer or client is loading
        if (trainerAuth.isLoading || clientAuth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // If trainer is authenticated, show trainer dashboard
        if (trainerAuth.isAuthenticated) {
          return const DashboardScreen();
        }
        
        // If client is authenticated, show client dashboard
        if (clientAuth.isAuthenticated) {
          return const ClientDashboardScreen();
        }
        
        // If no one is authenticated, show login selection
        return const LoginScreen();
      },
    );
  }
}