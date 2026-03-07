import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/waste_item.dart';
import '../data/json_waste_store.dart';
import 'new_post_screen.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final JsonWasteStore _store = JsonWasteStore();

  @override
  void initState() {
    super.initState();
    _store.loadWasteItems();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: StreamBuilder<List<WasteItem>>(
          stream: _store.wasteItemsStream,
          builder: (context, snapshot) {
            int total = 0;
            if (snapshot.hasData) {
              total = snapshot.data!.fold(
                0,
                (sum, item) => sum + item.quantity,
              );
            }
            return Text('Wasteagram - $total');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              ).then((_) => _store.loadWasteItems());
            },
          ),
        ],
      ),
      body: StreamBuilder<List<WasteItem>>(
        stream: _store.wasteItemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No waste data found.'),
                ],
              ),
            );
          } else {
            final items = snapshot.data!.reversed.toList();
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final dateFormatted = DateFormat(
                  'EEEE, MMMM d, y',
                ).format(item.date);
                return Semantics(
                  label:
                      'Waste post from $dateFormatted with ${item.quantity} items',
                  child: ListTile(
                    title: Text(dateFormatted),
                    trailing: Text(
                      item.quantity.toString(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(item: item),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Semantics(
        label: 'Add new waste post',
        button: true,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewPostScreen()),
            ).then((_) {
              _store.loadWasteItems();
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
