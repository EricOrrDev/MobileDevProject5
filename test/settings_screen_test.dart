import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasteagram/widgets/settings_screen.dart';
import 'package:wasteagram/data/json_waste_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String testFileName = 'waste_items_settings_test.json';

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

  testWidgets('SettingsScreen has a title and instructions', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Data Management'), findsOneWidget);
    expect(find.textContaining('permanently delete'), findsOneWidget);
  });

  testWidgets('Tapping the Clear All Posts button shows a confirmation dialog', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

    final button = find.byType(ElevatedButton);
    expect(button, findsOneWidget);
    expect(find.text('Clear All Posts'), findsOneWidget);

    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Are you sure?'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);
    expect(find.text('CLEAR ALL'), findsOneWidget);
  });

  testWidgets('Tapping CANCEL in dialog closes the dialog', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

    await tester.tap(find.text('Clear All Posts'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Tapping CLEAR ALL in dialog closes dialog and shows snackbar', (WidgetTester tester) async {
    final store = JsonWasteStore(fileName: testFileName);
    await tester.pumpWidget(MaterialApp(home: SettingsScreen(store: store)));

    await tester.tap(find.text('Clear All Posts'));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.tap(find.text('CLEAR ALL'));
      // Wait for the async onPressed to complete
      await Future.delayed(const Duration(milliseconds: 500));
    });
    
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('All posts cleared.'), findsOneWidget);
    store.dispose();
  });

  testWidgets('SettingsScreen button has correct semantics', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));

    final semantics = find.bySemanticsLabel('Clear all waste posts');
    expect(semantics, findsOneWidget);
  });
}
