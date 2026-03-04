class WasteItem {
  final DateTime date;
  final String imageURL;
  final int quantity;
  final String description;
  final double latitude;
  final double longitude;

  WasteItem({
    required this.date,
    required this.imageURL,
    required this.quantity,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  factory WasteItem.fromJson(Map<String, dynamic> json) {
    return WasteItem(
      date: DateTime.parse(json['date']),
      imageURL: json['imageURL'],
      quantity: json['quantity'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    String dataString = date.toIso8601String();
    return {
      'date': dataString,
      'imageURL': imageURL,
      'quantity': quantity,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
