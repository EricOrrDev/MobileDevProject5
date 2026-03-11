import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasteagram/widgets/listScreen.dart';
import 'package:wasteagram/models/waste_item.dart';
import 'package:wasteagram/data/json_waste_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String testFileName = 'waste_items_list_test.json';

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wasteagram_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return tempDir.path;
            }
            return null;
          },
        );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  testWidgets('ListScreen shows empty state when no data', (
    WidgetTester tester,
  ) async {
    final store = JsonWasteStore(fileName: testFileName);
    await tester.pumpWidget(MaterialApp(home: ListScreen(store: store)));

    // Initial state is loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the store to finish loading empty list
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    //confirm that
    //expect(find.text('No waste data found.'), findsOneWidget);
    expect(find.text('Wasteagram - 0'), findsOneWidget);
    store.dispose();
  });

  testWidgets('ListScreen shows list of items', (WidgetTester tester) async {
    // Create a file with some data before starting
    final file = File('${tempDir.path}/$testFileName');
    final items = [
      WasteItem(
        date: DateTime.parse('2026-03-04T12:00:00Z'),
        imageURL: '',
        quantity: 5,
        description: 'First',
        latitude: 0,
        longitude: 0,
      ),
      WasteItem(
        date: DateTime.parse('2026-03-05T12:00:00Z'),
        imageURL: '',
        quantity: 10,
        description: 'Second',
        latitude: 0,
        longitude: 0,
      ),
    ];
    await file.writeAsString(jsonEncode(items.map((e) => e.toJson()).toList()));

    final store = JsonWasteStore(fileName: testFileName);
    await tester.pumpWidget(MaterialApp(home: ListScreen(store: store)));

    // Process loading
    await tester.pump(); // Start building
    await tester.pumpAndSettle(); // Wait for stream

    // Total should be 15
    expect(find.text('Wasteagram - 15'), findsOneWidget);

    // Items should be reversed, so 2026-03-05 should be first
    expect(find.textContaining('Thursday, March 5, 2026'), findsOneWidget);
    expect(find.textContaining('Wednesday, March 4, 2026'), findsOneWidget);

    expect(find.text('10'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    store.dispose();
  }, skip: true);

  testWidgets('ListScreen has correct FAB semantics', (
    WidgetTester tester,
  ) async {
    final store = JsonWasteStore(fileName: testFileName);
    await tester.pumpWidget(MaterialApp(home: ListScreen(store: store)));

    final fab = find.bySemanticsLabel('Add new waste post');
    expect(fab, findsOneWidget);
    store.dispose();
  });
}
