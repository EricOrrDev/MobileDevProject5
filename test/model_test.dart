import 'package:flutter_test/flutter_test.dart';
import 'package:wasteagram/models/waste_item.dart';

void main() {
  test('WasteItem fromJson and toJson work correctly', () {
    final date = DateTime.parse('2026-03-04T12:00:00Z');
    const imageURL = 'https://example.com/image.png';
    const quantity = 5;
    const description = 'Wasted food';
    const latitude = 44.5;
    const longitude = -123.2;

    final wasteItem = WasteItem(
      date: date,
      imageURL: imageURL,
      quantity: quantity,
      description: description,
      latitude: latitude,
      longitude: longitude,
    );

    final json = wasteItem.toJson();

    expect(json['date'], date.toIso8601String());
    expect(json['imageURL'], imageURL);
    expect(json['quantity'], quantity);
    expect(json['description'], description);
    expect(json['latitude'], latitude);
    expect(json['longitude'], longitude);

    final fromJsonItem = WasteItem.fromJson(json);

    expect(fromJsonItem.date, date);
    expect(fromJsonItem.imageURL, imageURL);
    expect(fromJsonItem.quantity, quantity);
    expect(fromJsonItem.description, description);
    expect(fromJsonItem.latitude, latitude);
    expect(fromJsonItem.longitude, longitude);
  });

  test('WasteItem handles edge cases', () {
    final json = {
      'date': '2026-03-04T12:00:00Z',
      'imageURL': '',
      'quantity': 0,
      'description': '',
      'latitude': 0.0,
      'longitude': 0.0,
    };

    final wasteItem = WasteItem.fromJson(json);

    expect(wasteItem.quantity, 0);
    expect(wasteItem.imageURL, '');
    expect(wasteItem.description, '');
  });
}
