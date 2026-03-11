import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wasteagram/widgets/new_post_screen.dart';
import 'package:wasteagram/data/json_waste_store.dart';
import 'package:wasteagram/models/waste_item.dart';

// Improved Mock Classes
class MockHttpClient extends http.BaseClient {
  bool sendCalled = false;
  String? lastQuery;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sendCalled = true;
    lastQuery = request.url.queryParameters['query'];

    final body = jsonEncode({
      'photos': [
        {
          'src': {'large': 'https://example.com/mock.png'},
        },
      ],
    });
    return http.StreamedResponse(Stream.value(utf8.encode(body)), 200);
  }
}

class MockLocation extends Fake implements Location {
  bool getLocationCalled = false;

  @override
  Future<bool> serviceEnabled() async => true;
  @override
  Future<PermissionStatus> hasPermission() async => PermissionStatus.granted;
  @override
  Future<LocationData> getLocation() async {
    getLocationCalled = true;
    return LocationData.fromMap({'latitude': 45.0, 'longitude': -122.0});
  }
}

class MockNavigatorObserver extends NavigatorObserver {
  bool popped = false;
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popped = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const String testFileName = 'waste_items_new_post_test.json';

  setUpAll(() {
    dotenv.testLoad(fileInput: 'PEXELS_API_KEY=test');
  });

  setUp(() async {
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

    // Clean up test file
    final file = File('./$testFileName');
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (e) {
        // Ignore if busy
      }
    }
  });

  testWidgets(
    'NewPostScreen shows validation error when description is empty',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: NewPostScreen()));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter a description'), findsOneWidget);
    },
    skip: true,
  );

  group('NewPostScreen saving process', () {
    late MockHttpClient mockClient;
    late MockLocation mockLocation;
    late JsonWasteStore store;
    late MockNavigatorObserver observer;

    setUp(() {
      mockClient = MockHttpClient();
      mockLocation = MockLocation();
      store = JsonWasteStore(fileName: testFileName);
      observer = MockNavigatorObserver();
    });

    tearDown(() async {
      store.dispose();
      // Give some time for any pending file ops to finish
      await Future.delayed(const Duration(milliseconds: 100));
      final file = File('./$testFileName');
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (e) {
          // Ignore
        }
      }
    });

    Future<void> setupWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewPostScreen(
                      httpClient: mockClient,
                      locationService: mockLocation,
                      store: store,
                    ),
                  ),
                );
              },
              child: const Text('Launch'),
            ),
          ),
          navigatorObservers: [observer],
        ),
      );

      await tester.tap(find.text('Launch'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'Leftover Pizza');
    }

    Future<void> waitForSave(WidgetTester tester) async {
      int attempts = 0;
      while (!observer.popped && attempts < 50) {
        await tester.runAsync(() async {
          await Future.delayed(const Duration(milliseconds: 100));
        });
        await tester.pump(); // Allow microtasks to run!
        attempts++;
      }
      // Transition pump
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('shows loading indicator when saving', (
      WidgetTester tester,
    ) async {
      await setupWidget(tester);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Still need to wait for it to finish to avoid interfering with next tests
      await waitForSave(tester);
    });

    testWidgets('calls location and image services', (
      WidgetTester tester,
    ) async {
      await setupWidget(tester);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Start loading

      await waitForSave(tester);

      expect(
        mockLocation.getLocationCalled,
        isTrue,
        reason: 'Location service should be called',
      );
      expect(
        mockClient.sendCalled,
        isTrue,
        reason: 'HTTP client should be called',
      );
      expect(mockClient.lastQuery, 'Leftover Pizza');
    });

    testWidgets('saves post to store and pops on success', (
      WidgetTester tester,
    ) async {
      await setupWidget(tester);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Start loading

      await waitForSave(tester);

      expect(
        observer.popped,
        isTrue,
        reason: 'Should have popped after saving',
      );

      // Verify store has the item
      final items = await store.loadWasteItems();
      expect(items.length, 1);
      expect(items.first.description, 'Leftover Pizza');
      expect(items.first.imageURL, 'https://example.com/mock.png');
    }, skip: true);
  });
}
