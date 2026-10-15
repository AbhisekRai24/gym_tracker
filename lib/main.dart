import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/storage/hive_boxes.dart';
import 'app/app.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  await Hive.initFlutter();
  await HiveBoxes.openWorkoutsBox();
  await HiveBoxes.openWorkoutSessionsBox();
  await HiveBoxes.openExercisesBox();
  await HiveBoxes.openProfileBox();
  await HiveBoxes.openAuthBox();
  await HiveBoxes.openPlannerBox();

  runApp(const ProviderScope(child: GymTrackApp()));
}
