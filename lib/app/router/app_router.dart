import 'package:go_router/go_router.dart';
import '../theme/shell_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';

/// App router configuration using GoRouter.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
            SplashPage(onInitialized: () => router.go('/')),
      ),
      GoRoute(path: '/', builder: (context, state) => const ShellPage()),
    ],
  );
}
