import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/auth/viewmodel/auth_viewmodel.dart';

import '../../../features/home/views/dashboard_screen.dart';

import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authViewModelProvider);

    switch (auth.status) {
      case AuthStatus.loading:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.signedIn:
        return const DashboardScreen();
      case AuthStatus.signedOut:
        return const LoginScreen();
    }
  }
}
