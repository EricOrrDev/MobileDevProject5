import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/waste_item.dart';
import '../data/json_waste_store.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final _formKey = GlobalKey<FormState>();
  String _description = '';
  int _quantity = 0;
  bool _isLoading = false;

  Future<String> _fetchImageUrl(String query) async {
    final apiKey = dotenv.env['PEXELS_API_KEY'] ?? '';
    final response = await http.get(
      Uri.parse('https://api.pexels.com/v1/search?query=$query&per_page=1'),
      headers: {'Authorization': apiKey},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['photos'] != null && data['photos'].isNotEmpty) {
        return data['photos'][0]['src']['large'];
      }
    }
    return 'https://via.placeholder.com/600x400?text=No+Image+Found';
  }

  Future<LocationData?> _getLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return null;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return null;
    }

    return await location.getLocation();
  }

  void _savePost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final locationData = await _getLocation();
        final imageUrl = await _fetchImageUrl(_description);

        final newItem = WasteItem(
          date: DateTime.now(),
          imageURL: imageUrl,
          quantity: _quantity,
          description: _description,
          latitude: locationData?.latitude ?? 0.0,
          longitude: locationData?.longitude ?? 0.0,
        );

        final store = JsonWasteStore();
        await store.saveWasteItem(newItem);

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving post: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Post')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter a description' : null,
                      onSaved: (value) => _description = value!,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Number of Wasted Items',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    NumberPicker(
                      value: _quantity,
                      minValue: 0,
                      maxValue: 100,
                      step: 1,
                      itemHeight: 100,
                      axis: Axis.horizontal,
                      onChanged: (value) => setState(() => _quantity = value),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Semantics(
                      button: true,
                      label: 'Add this item to the list',
                      child: ElevatedButton(
                        onPressed: _savePost,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 80),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Icon(Icons.cloud_upload, size: 60),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
