import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/waste_item.dart';

class JsonWasteStore {
  static const String _fileName = 'waste_items.json';
  final _itemsController = StreamController<List<WasteItem>>.broadcast();

  Stream<List<WasteItem>> get wasteItemsStream => _itemsController.stream;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<List<WasteItem>> loadWasteItems() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(contents);
        final items = jsonList.map((json) => WasteItem.fromJson(json)).toList();
        _itemsController.add(items);
        return items;
      }
      _itemsController.add([]);
      return [];
    } catch (e) {
      _itemsController.add([]);
      return [];
    }
  }

  Future<void> saveWasteItem(WasteItem item) async {
    final items = await loadWasteItems();
    items.add(item);
    final file = await _localFile;
    await file.writeAsString(jsonEncode(items.map((e) => e.toJson()).toList()));
    _itemsController.add(items);
  }

  void dispose() {
    _itemsController.close();
  }
}
