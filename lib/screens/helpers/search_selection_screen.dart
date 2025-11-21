// lib/screens/helpers/search_selection_screen.dart
import 'package:flutter/material.dart';
import '../../models/Helpers/base_card_view_model.dart';
import 'dart:async'; // Timer için

// Bu ekran, arama yapmak için bir fonksiyonu parametre olarak alır
typedef SearchFunction = Future<List<BaseCardViewModel>> Function(String term);

class SearchSelectionScreen extends StatefulWidget {
  final String title;
  final SearchFunction onSearch;

  const SearchSelectionScreen({super.key, required this.title, required this.onSearch});

  @override
  State<SearchSelectionScreen> createState() => _SearchSelectionScreenState();
}

class _SearchSelectionScreenState extends State<SearchSelectionScreen> {
  List<BaseCardViewModel> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Kullanıcı yazmayı bıraktıktan sonra aramayı tetikler (performans için)
  void _onSearchChanged(String term) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (term.length < 2) {
        setState(() => _results = []);
        return;
      }
      setState(() { _isLoading = true; });
      try {
        final results = await widget.onSearch(term);
        setState(() { _results = results; _isLoading = false; });
      } catch (e) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Arama yapın...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index];
                return ListTile(
                  title: Text(item.description),
                  subtitle: Text(item.code),
                  onTap: () {
                    // Seçilen öğeyi bir önceki sayfaya geri döndür
                    Navigator.pop(context, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}