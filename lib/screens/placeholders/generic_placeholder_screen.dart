import 'package:flutter/material.dart';

class GenericPlaceholderScreen extends StatelessWidget {
  final String pageTitle;

  const GenericPlaceholderScreen({super.key, required this.pageTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        backgroundColor: Colors.grey.shade700,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              '"$pageTitle" sayfası yapım aşamasında...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}