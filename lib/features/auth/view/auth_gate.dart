import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/auth/viewmodel/auth_viewmodel.dart';

import '../../../features/home/views/dashboard_screen.dart';

import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authViewModelProvider);

    if (isLoggedIn) {
      return const DashboardScreen();
    }

    return const LoginScreen();
  }
}