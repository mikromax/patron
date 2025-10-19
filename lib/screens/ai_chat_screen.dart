import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dynamic_data_grid_screen.dart';

// ... ChatMessage ve ChatParticipant tanımları aynı kalıyor ...
enum ChatParticipant { user, model }
class ChatMessage {
  final String text;
  final ChatParticipant participant;
  ChatMessage({required this.text, required this.participant});
}


class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  
  // ApiService'i burada oluşturuyoruz
  final ApiService _apiService = ApiService();

  // --- HANDLE SUBMITTED FONKSİYONUNUN İÇİ DOLDU ---
  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();

    // 1. Kullanıcının mesajını ve bir yükleniyor durumunu ekle
    setState(() {
      _messages.insert(0, ChatMessage(text: text, participant: ChatParticipant.user));
      _isLoading = true;
    });

    try {
      // 2. ApiService'i çağır
      final resultData = await _apiService.getAiQueryResult(text);
      setState(() { _isLoading = false; });
      
      // 3. Başarılı ise, yeni grid ekranına yönlendir
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DynamicDataGridScreen(
              title: text, // Sayfa başlığı olarak kullanıcının sorusunu kullan
              data: resultData,
            ),
          ),
        );
      }
    } catch (e) {
      // 4. Hata var ise, hata mesajını sohbet ekranına ekle
      setState(() {
        _messages.insert(0, ChatMessage(text: 'Bir hata oluştu: ${e.toString()}', participant: ChatParticipant.model));
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Asistanı')),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(/* ... Hoşgeldiniz mesajı aynı ... */)
                // Mesajları göstermek için ListView
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  // --- MESAJ BALONCUĞU TASARIMI ---
  Widget _buildMessageBubble(ChatMessage message) {
    bool isUser = message.participant == ChatParticipant.user;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? Theme.of(context).primaryColor : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(color: isUser ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTextComposer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: _isLoading ? null : _handleSubmitted,
              decoration: const InputDecoration(
                hintText: 'Örn: "Ankara bölgesindeki borçları göster"',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}