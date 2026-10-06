import 'package:flutter/material.dart';

import '../../workouts/views/exercise_library_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Exercise Library'),
            subtitle: const Text('Manage your exercises'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExerciseLibraryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
