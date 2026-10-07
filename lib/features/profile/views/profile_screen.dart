import 'package:flutter/material.dart';

import '../../workouts/views/exercise_library_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Abhisek';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          const SizedBox(height: 24),

          InkWell(
            onTap: () async {
              final name = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );

              if (name != null) {
                setState(() {
                  _name = name;
                });
              }
            },
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),

                const SizedBox(height: 12),

                Text(
                  _name,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                const Text(
                  'GymTrack Member',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Edit Profile',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

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
