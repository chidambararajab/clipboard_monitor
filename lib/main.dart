import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clipboard_monitor/database/database.dart';
import 'package:clipboard_monitor/models/clipboard_item.dart';
import 'package:clipboard_monitor/database/database.dart';
import 'package:clipboard_monitor/services/clipboard_monitor.dart';

void main() {
  runApp(const MyApp());
  ClipboardMonitor().startMonitoring();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClipboardProvider(),
      child: MaterialApp(
        title: 'Clipboard Monitor App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ClipboardScreen(),
      ),
    );
  }
}

class ClipboardProvider extends ChangeNotifier {
  List<ClipboardItem> _items = [];

  List<ClipboardItem> get items => _items;

  void addClipboardItem(ClipboardItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeClipboardItem(int id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> loadClipboardItems() async {
    _items = await DatabaseService().getClipboardItems();
    notifyListeners();
  }
}

class ClipboardScreen extends StatefulWidget {
  @override
  _ClipboardScreenState createState() => _ClipboardScreenState();
}

class _ClipboardScreenState extends State<ClipboardScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ClipboardProvider>(context, listen: false).loadClipboardItems();
  }

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<ClipboardProvider>(context).items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipboard Monitor App'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item.text ?? ''),
            subtitle: item.imagePath != null
                ? Image.file(File(item.imagePath!))
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await DatabaseService().deleteClipboardItem(item.id);
                Provider.of<ClipboardProvider>(context, listen: false)
                    .removeClipboardItem(item.id);
              },
            ),
          );
        },
      ),
    );
  }
}
