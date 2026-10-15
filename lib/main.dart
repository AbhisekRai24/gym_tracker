import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/storage/hive_boxes.dart';
import 'app/app.dart';
import 'firebase_options.dart';

void _showStartupError(String stage, Object error, StackTrace stack) {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              'Startup failed at: $stage\n\n$error\n\n$stack',
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    _showStartupError('Firebase.initializeApp', e, st);
    return;
  }

  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (e) {
    debugPrint('Firestore settings skipped: $e');
  }

  try {
    await Hive.initFlutter();
    await HiveBoxes.openWorkoutsBox();
    await HiveBoxes.openWorkoutSessionsBox();
    await HiveBoxes.openExercisesBox();
    await HiveBoxes.openProfileBox();
    await HiveBoxes.openAuthBox();
    await HiveBoxes.openPlannerBox();
  } catch (e, st) {
    _showStartupError('Hive startup', e, st);
    return;
  }

  runApp(const ProviderScope(child: GymTrackApp()));
}
