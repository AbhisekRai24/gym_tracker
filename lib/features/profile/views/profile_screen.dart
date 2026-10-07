import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_track/features/planner/views/weekly_planner_screen.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../workouts/views/exercise_library_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _pickAvatar() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    ref.read(authViewModelProvider.notifier).updateAvatar(image.path);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authRepositoryProvider).getUser();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          const SizedBox(height: 24),

          Column(
            children: [
              GestureDetector(
                onTap: _pickAvatar,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: user?.avatarPath != null
                      ? FileImage(File(user!.avatarPath!))
                      : null,
                  child: user?.avatarPath == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Tap to change photo',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 12),

              Text(
                '@${user?.username ?? 'User'}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                user?.email ?? '',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () async {
                  final username = user?.username;

                  if (username == null) {
                    return;
                  }

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditProfileScreen(currentUsername: username),
                    ),
                  );

                  ref.invalidate(authRepositoryProvider);
                },
                child: const Text('Edit Profile'),
              ),
            ],
          ),

          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Workout Planner'),
            subtitle: const Text('Plan your weekly workouts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeeklyPlannerScreen(),
                ),
              );
            },
          ),

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

          const SizedBox(height: 16),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              ref.read(authViewModelProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}
