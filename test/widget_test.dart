// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ecotrack/main.dart';
import 'package:ecotrack/services/authentication_service.dart';
import 'package:ecotrack/services/returns_service.dart';
import 'package:ecotrack/services/database_service.dart';
import 'package:ecotrack/services/sync_service.dart';

void main() {
  testWidgets('EcoTrack app starts with splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthenticationService>(
            create: (_) => AuthenticationService(),
          ),
          Provider<ReturnsService>(create: (_) => ReturnsService()),
          Provider<DatabaseService>(create: (_) => DatabaseService()),
          Provider<SyncService>(
            create: (context) => SyncService(
              databaseService: context.read<DatabaseService>(),
              returnsService: context.read<ReturnsService>(),
            ),
          ),
        ],
        child: const EcoTrackApp(),
      ),
    );

    // Verify that splash screen appears with EcoTrack title
    expect(find.text('EcoTrack Namibia'), findsOneWidget);
    expect(find.text('Wildlife Compliance Platform'), findsOneWidget);
  });
}
