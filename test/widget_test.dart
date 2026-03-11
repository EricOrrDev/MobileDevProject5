import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasteagram/main.dart';
import 'package:wasteagram/widgets/new_post_screen.dart';
import 'package:wasteagram/widgets/settings_screen.dart';
import 'package:wasteagram/widgets/listScreen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return '.';
            }
            return null;
          },
        );
  });

  testWidgets('App starts at ListScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const WasteagramApp());
    await tester.pump(const Duration(seconds: 5)); // Wait for initial load

    expect(find.byType(ListScreen), findsOneWidget);
  });

  testWidgets('Navigation: Can navigate to and from Settings',
      (WidgetTester tester) async {
    await tester.pumpWidget(const WasteagramApp());
    await tester.pump(const Duration(seconds: 5));

    // Navigate to Settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(SettingsScreen), findsOneWidget);

    // Go back
    await tester.tap(find.byType(BackButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ListScreen), findsOneWidget);
  });

  testWidgets('Navigation: Can navigate to NewPostScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const WasteagramApp());
    await tester.pump(const Duration(seconds: 5));

    // Navigate to NewPostScreen
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(NewPostScreen), findsOneWidget);
  });
}
