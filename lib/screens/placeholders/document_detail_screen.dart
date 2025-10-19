import 'package:flutter/material.dart';
import '../../models/statement_detail_model.dart';

class DocumentDetailScreen extends StatelessWidget {
  final StatementDetailModel statementLine;

  const DocumentDetailScreen({super.key, required this.statementLine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${statementLine.documentSerial} ${statementLine.documentNumber}'),
        backgroundColor: Colors.grey.shade700,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'Evrak Detay sayfası (${statementLine.documentType}) yapım aşamasında...',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}