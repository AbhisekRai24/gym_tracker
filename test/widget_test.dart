import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_track/app/app.dart';

void main() {
  testWidgets('GymTrack app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GymTrackApp()));

    expect(find.text('GymTrack'), findsOneWidget);
  });
}
