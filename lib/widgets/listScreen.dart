import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/waste_item.dart';
import '../data/json_waste_store.dart';

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
                      // Navigate to Detail Screen
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
            // Navigate to New Post Screen
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
