import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GymTrack',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.person_outline)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good morning 👋',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            const Text(
              "Today's Workout",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upper Body',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('5 exercises'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('START WORKOUT'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'This Week',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _DayIndicator(day: 'M', completed: true),
                    _DayIndicator(day: 'T', completed: true),
                    _DayIndicator(day: 'W', completed: false),
                    _DayIndicator(day: 'T', completed: true),
                    _DayIndicator(day: 'F', completed: false),
                    _DayIndicator(day: 'S', completed: false),
                    _DayIndicator(day: 'S', completed: false),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Recent Workouts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const _WorkoutHistoryTile(workout: 'Upper Body', date: 'Oct 2'),

            const _WorkoutHistoryTile(workout: 'Lower Body', date: 'Sep 30'),

            const _WorkoutHistoryTile(workout: 'Upper Body', date: 'Sep 28'),
          ],
        ),
      ),
    );
  }
}

class _DayIndicator extends StatelessWidget {
  final String day;
  final bool completed;

  const _DayIndicator({required this.day, required this.completed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CircleAvatar(
          radius: 16,
          backgroundColor: completed ? Colors.green : Colors.grey.shade300,
          child: completed
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
      ],
    );
  }
}

class _WorkoutHistoryTile extends StatelessWidget {
  final String workout;
  final String date;

  const _WorkoutHistoryTile({required this.workout, required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
        title: Text(
          workout,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Text(date),
      ),
    );
  }
}
