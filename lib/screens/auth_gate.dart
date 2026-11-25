import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'splash_screen.dart';
import 'main_shell.dart';

/// Listens to Firebase auth state and routes accordingly.
/// - Logged in  → MainShell (home feed)
/// - Logged out → SplashScreen (get started / sign in)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // While Firebase resolves the auth state, show a neutral loading screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Signed in
        if (snapshot.hasData && snapshot.data != null) {
          return const MainShell();
        }

        // Not signed in
        return const SplashScreen();
      },
    );
  }
}
