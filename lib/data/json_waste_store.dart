import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/waste_item.dart';

class JsonWasteStore {
  final String fileName;
  final _itemsController = StreamController<List<WasteItem>>.broadcast();
  List<WasteItem>? _items;
  String? _cachedPath;

  JsonWasteStore({this.fileName = 'waste_items.json'});

  Stream<List<WasteItem>> get wasteItemsStream async* {
    if (_items != null) {
      yield List.from(_items!);
    }
    yield* _itemsController.stream;
  }
  
  List<WasteItem>? get currentItems => _items;

  Future<String> get _localPath async {
    if (_cachedPath != null) return _cachedPath!;
    final directory = await getApplicationDocumentsDirectory();
    _cachedPath = directory.path;
    return _cachedPath!;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  Future<List<WasteItem>> loadWasteItems() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isEmpty) {
          _items = [];
          _itemsController.add(List.from(_items!));
          return _items!;
        }
        final List<dynamic> jsonList = jsonDecode(contents);
        final items = jsonList.map((json) => WasteItem.fromJson(json)).toList();
        _items = items;
        _itemsController.add(List.from(_items!));
        return _items!;
      }
      _items = [];
      _itemsController.add(List.from(_items!));
      return _items!;
    } catch (e) {
      _items = [];
      _itemsController.add(List.from(_items!));
      return _items!;
    }
  }

  Future<void> saveWasteItem(WasteItem item) async {
    final items = await loadWasteItems();
    items.add(item);
    final file = await _localFile;
    await file.writeAsString(jsonEncode(items.map((e) => e.toJson()).toList()));
    _items = items;
    _itemsController.add(List.from(_items!));
  }

  Future<void> clearWasteItems() async {
    final file = await _localFile;
    if (await file.exists()) {
      await file.delete();
    }
    _items = [];
    _itemsController.add([]);
  }

  void dispose() {
    _itemsController.close();
  }
}
