import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasteagram/models/waste_item.dart';
import 'package:wasteagram/widgets/waste_list/listItem.dart';
import 'package:wasteagram/widgets/detail_screen.dart';

void main() {
  testWidgets('ListItem displays date and quantity', (WidgetTester tester) async {
    final item = WasteItem(
      date: DateTime.parse('2026-03-04T12:00:00Z'),
      imageURL: 'url',
      quantity: 5,
      description: 'Test',
      latitude: 0,
      longitude: 0,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListItem(item: item),
      ),
    ));

    expect(find.text('Wednesday, March 4, 2026'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('ListItem has correct semantics', (WidgetTester tester) async {
    final item = WasteItem(
      date: DateTime.parse('2026-03-04T12:00:00Z'),
      imageURL: 'url',
      quantity: 5,
      description: 'Test',
      latitude: 0,
      longitude: 0,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListItem(item: item),
      ),
    ));

    expect(
      find.bySemanticsLabel(RegExp(r'Waste post from.*March 4, 2026.*5 items')),
      findsOneWidget,
    );
  });

  testWidgets('Tapping ListItem navigates to DetailScreen', (WidgetTester tester) async {
    final item = WasteItem(
      date: DateTime.parse('2026-03-04T12:00:00Z'),
      imageURL: 'url',
      quantity: 5,
      description: 'Test',
      latitude: 0,
      longitude: 0,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListItem(item: item),
      ),
    ));

    await tester.tap(find.byType(ListItem));
    await tester.pumpAndSettle();

    expect(find.byType(DetailScreen), findsOneWidget);
    expect(find.text('5 items'), findsOneWidget);
  });
}
