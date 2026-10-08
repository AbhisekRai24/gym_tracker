import 'package:flutter/material.dart';
import 'package:gym_track/core/widgets/app_feedback.dart';
import 'package:gym_track/features/auth/view/auth_gate.dart';

class GymTrackApp extends StatelessWidget {
  const GymTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GymTrack',
      scaffoldMessengerKey: AppFeedback.messengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
