import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Lottie paketini import ediyoruz
import '../services/api/ai_api.dart';
import 'dynamic_data_grid_screen.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';

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
  final AiApi _apiService = AiApi();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  @override
  void initState() {
    super.initState();
    _initSpeech();
  }
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }
  void _listen() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    } else {
      if (_speechEnabled) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _textController.text = result.recognizedWords;
            });
          },
        );
      }
    }
  }
  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.insert(0, ChatMessage(text: text, participant: ChatParticipant.user));
      _isLoading = true;
    });

    try {
      // Artık DTO göndermiyoruz, sadece metni gönderiyoruz
      final resultData = await _apiService.getAiQueryResult(text);
      setState(() { _isLoading = false; });
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DynamicDataGridScreen(
              title: text,
              data: resultData,
              // --- DEĞİŞİKLİK: queryLogId parametresi kaldırıldı ---
            ),
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
          if (Platform.isAndroid || Platform.isIOS)
          IconButton(
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
            color: _isListening ? Theme.of(context).primaryColor : null,
            tooltip: 'Sesli Komut',
            onPressed: _speechEnabled ? _listen : null, // Servis başlamadıysa pasif
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }
}