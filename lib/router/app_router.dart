import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/webview_screen.dart';

// GoRouter Provider
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'main',
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            child: WebViewScreen(
              webViewUrl: 'https://flutter-webview-nextjs.vercel.app/',
            ),
          );
        },
      ),
    ],
  );
});
