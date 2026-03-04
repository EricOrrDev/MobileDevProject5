import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/waste_item.dart';
import '../detail_screen.dart';

class ListItem extends StatelessWidget {
  final WasteItem item;

  const ListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('EEEE, MMMM d, y').format(item.date);

    return Semantics(
      label: 'Waste post from $dateFormatted with ${item.quantity} items',
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
  }
}
