import 'package:flutter/material.dart';
import '../models/waste_item.dart';
import '../data/json_waste_store.dart';
import 'new_post_screen.dart';
import 'settings_screen.dart';
import 'waste_list/listItem.dart';

class ListScreen extends StatefulWidget {
  final JsonWasteStore? store;
  const ListScreen({super.key, this.store});

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late JsonWasteStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? JsonWasteStore();
    _store.loadWasteItems();
  }

  @override
  void dispose() {
    if (widget.store == null) {
      _store.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: StreamBuilder<List<WasteItem>>(
          stream: _store.wasteItemsStream,
          initialData: _store.currentItems,
          builder: (context, snapshot) {
            int total = 0;
            if (snapshot.hasData && snapshot.data != null) {
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
        initialData: _store.currentItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            // This happens when _store.currentItems is null (not loaded yet)
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.isEmpty) {
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
                return ListItem(item: items[index]);
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
