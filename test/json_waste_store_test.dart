import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasteagram/data/json_waste_store.dart';
import 'package:wasteagram/models/waste_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late JsonWasteStore store;
  const String testFileName = 'waste_items_store_test.json';

  setUp(() async {
    // Mock path_provider
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

    store = JsonWasteStore(fileName: testFileName);
    final file = File('./$testFileName');
    if (await file.exists()) {
      await file.delete();
    }
  });

  tearDown(() async {
    store.dispose();
    final file = File('./$testFileName');
    if (await file.exists()) {
      await file.delete();
    }
  });

  test('loadWasteItems returns empty list when file does not exist', () async {
    final items = await store.loadWasteItems();
    expect(items, isEmpty);
  });

  test('saveWasteItem saves an item and loadWasteItems retrieves it', () async {
    final item = WasteItem(
      date: DateTime.now(),
      imageURL: 'https://example.com/image.png',
      quantity: 5,
      description: 'Test Item',
      latitude: 10.0,
      longitude: 20.0,
    );

    await store.saveWasteItem(item);
    final items = await store.loadWasteItems();

    expect(items.length, 1);
    expect(items.first.description, 'Test Item');
    expect(items.first.quantity, 5);
  });

  test('clearWasteItems deletes the file and clears the list', () async {
    final item = WasteItem(
      date: DateTime.now(),
      imageURL: 'url',
      quantity: 1,
      description: 'desc',
      latitude: 0,
      longitude: 0,
    );

    await store.saveWasteItem(item);
    var items = await store.loadWasteItems();
    expect(items, isNotEmpty);

    await store.clearWasteItems();
    items = await store.loadWasteItems();
    expect(items, isEmpty);
    
    final file = File('./$testFileName');
    expect(await file.exists(), isFalse);
  });

  test('wasteItemsStream emits updated list when item is saved', () async {
    final item = WasteItem(
      date: DateTime.now(),
      imageURL: 'url',
      quantity: 1,
      description: 'desc',
      latitude: 0,
      longitude: 0,
    );

    expect(store.wasteItemsStream, emitsInOrder([
      [],
      predicate((List<WasteItem> items) {
        return items.length == 1 && items.first.description == 'desc';
      })
    ]));

    await store.saveWasteItem(item);
  });
}
