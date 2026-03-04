import 'package:flutter/material.dart';
import '../models/waste_item.dart';
import '../data/json_waste_store.dart';
import 'new_post_screen.dart';
import 'waste_list/listItem.dart';

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
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Waiting for waste data...'),
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
