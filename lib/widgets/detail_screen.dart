import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/waste_item.dart';

class DetailScreen extends StatelessWidget {
  final WasteItem item;

  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('EEEE, MMMM d, y').format(item.date);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Wasteagram'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
          child: Column(
            children: [
              Semantics(
                label: 'Post date: $dateFormatted',
                child: Text(
                  dateFormatted,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                label: 'Photo of wasted items',
                image: true,
                child: item.imageURL.isNotEmpty
                    ? Image.network(
                        item.imageURL,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                      )
                    : const Placeholder(fallbackHeight: 300),
              ),
              const SizedBox(height: 20),
              Semantics(
                label: '${item.quantity} items wasted',
                child: Text(
                  '${item.quantity} items',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                label: 'Location: Latitude ${item.latitude.toStringAsFixed(4)}, Longitude ${item.longitude.toStringAsFixed(4)}',
                child: Text(
                  'Location: (${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
