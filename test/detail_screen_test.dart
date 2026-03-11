import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasteagram/models/waste_item.dart';
import 'package:wasteagram/widgets/detail_screen.dart';

void main() {
  testWidgets('DetailScreen displays all item details', (WidgetTester tester) async {
    final item = WasteItem(
      date: DateTime.parse('2026-03-04T12:00:00Z'),
      imageURL: '', // Use empty string to show Placeholder
      quantity: 5,
      description: 'Test Waste',
      latitude: 44.5,
      longitude: -123.2,
    );

    await tester.pumpWidget(MaterialApp(home: DetailScreen(item: item)));

    // Verify date is displayed (Wednesday, March 4, 2026)
    expect(find.text('Wednesday, March 4, 2026'), findsOneWidget);
    
    // Verify quantity is displayed
    expect(find.text('5 items'), findsOneWidget);
    
    // Verify location is displayed
    expect(find.textContaining('Location: (44.5000, -123.2000)'), findsOneWidget);
    
    // Verify Placeholder is shown when imageURL is empty
    expect(find.byType(Placeholder), findsOneWidget);
  });

  testWidgets('DetailScreen has correct semantics', (WidgetTester tester) async {
    final item = WasteItem(
      date: DateTime.parse('2026-03-04T12:00:00Z'),
      imageURL: '', // Empty URL to avoid network image issues in this test
      quantity: 5,
      description: 'Test Waste',
      latitude: 44.5,
      longitude: -123.2,
    );

    await tester.pumpWidget(MaterialApp(home: DetailScreen(item: item)));
    await tester.pumpAndSettle();

    // Use find.bySemanticsLabel with RegExp to be more flexible if labels are merged
    expect(find.bySemanticsLabel(RegExp(r'Post date:.*March 4, 2026')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'5 items wasted')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'Location: Latitude 44.5000.*')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'Photo of wasted items|Placeholder')), findsOneWidget);
  });
}
