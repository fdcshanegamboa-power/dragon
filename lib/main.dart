// ignore_for_file: depend_on_referenced_packages
import 'package:dragon/firebase_options.dart';
import 'package:dragon/screens/home_screen.dart';
import 'package:dragon/screens/login_screen.dart';
import 'package:dragon/screens/register_screen.dart';
import 'package:dragon/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// Notifier that triggers GoRouter to re-evaluate its redirect
// whenever the Firebase auth state changes.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    FirebaseAuth.instance
        .authStateChanges()
        .listen((_) => notifyListeners());
  }
}

final _authNotifier = _AuthNotifier();

final _router = GoRouter(
  initialLocation: '/login',
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final isAuthenticated = FirebaseAuth.instance.currentUser != null;
    final path = state.matchedLocation;
    final onAuthRoute = path == '/login' || path == '/register';

    if (isAuthenticated && onAuthRoute) return '/home';
    if (!isAuthenticated && !onAuthRoute) return '/login';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dragon',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
