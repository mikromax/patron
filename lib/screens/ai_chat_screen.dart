import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Lottie paketini import ediyoruz
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
  final ApiService _apiService = ApiService();

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.insert(0, ChatMessage(text: text, participant: ChatParticipant.user));
      _isLoading = true;
    });

    try {
      final resultData = await _apiService.getAiQueryResult(text);
      setState(() { _isLoading = false; });
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DynamicDataGridScreen(title: text, data: resultData),
          ),
        );
      }
    } catch (e) {
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
      // --- DEĞİŞİKLİK 1: Scaffold'u SafeArea ile sarıyoruz ---
      // Bu, içeriğin telefonun çentik (notch) veya alt bar gibi
      // sistem alanlarına girmesini engeller.
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? _buildWelcomeScreen()
                  : _buildMessagesList(),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: CircularProgressIndicator(),
              ),
            // --- DEĞİŞİKLİK 2: Chatbox'ı klavyeden korumak için Padding ekliyoruz ---
            // Bu padding, klavye açıldığında onun kapladığı alan kadar
            // chatbox'ı yukarı iter.
            Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }



  // --- YENİ WIDGET: HOŞ GELDİNİZ EKRANI VE ANİMASYON ---
  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView( // Küçük ekranlarda taşmayı önler
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Yeni Lottie animasyonu
            Lottie.asset(
              'assets/animations/ai_anim.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            const Text(
              'Verileriniz hakkında ne merak ediyorsunuz?',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Mesaj listesini oluşturan widget
  Widget _buildMessagesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      reverse: true, // Mesajları aşağıdan yukarıya dizer
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  // Mesaj baloncuklarını oluşturan widget (değişmedi)
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

  // Chatbox widget'ı (değişmedi)
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