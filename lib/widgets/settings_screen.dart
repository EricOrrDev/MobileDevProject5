import 'package:flutter/material.dart';
import '../data/json_waste_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Data Management',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tapping the button below will permanently delete all wasteagram posts from your device.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Semantics(
                button: true,
                label: 'Clear all waste posts',
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  onPressed: () => _confirmClear(context),
                  child: const Text('Clear All Posts'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This action cannot be undone. All posts will be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              final store = JsonWasteStore();
              await store.clearWasteItems();
              if (context.mounted) {
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All posts cleared.')),
                );
              }
            },
            child: const Text('CLEAR ALL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
