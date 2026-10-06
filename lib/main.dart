import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/storage/hive_boxes.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await HiveBoxes.openWorkoutsBox();
  await HiveBoxes.openWorkoutSessionsBox();

  runApp(const ProviderScope(child: GymTrackApp()));
}
