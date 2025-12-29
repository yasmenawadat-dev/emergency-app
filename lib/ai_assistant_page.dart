import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts flutterTts = FlutterTts();

  List<Map<String, String>> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("ar-SA");
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  String offlineReply(String input) {
    input = input.toLowerCase();
    if (input.contains('صداع')) {
      return '''
للصداع:
• اشربي ماء بكثرة
• خذي قسطًا من الراحة
• ابتعدي عن الإضاءة القوية
• يمكن أخذ مسكن خفيف إذا لزم
''';
    }
    if (input.contains('حرق')) {
      return '''
للحروق الخفيفة:
• ضعي مكان الحرق تحت ماء بارد 10 دقائق
• لا تضعي معجون أسنان
• غطّي الحرق بشاش نظيف
''';
    }
    if (input.contains('جرح') || input.contains('خدش')) {
      return '''
للجروح البسيطة:
• اغسلي الجرح بالماء
• طهّريه بمطهر
• غطّيه بضماد نظيف
''';
    }
    if (input.contains('برد') || input.contains('نزلة')) {
      return '''
لنزلة البرد:
• اشربي سوائل دافئة
• خذي قسطًا من الراحة
• يمكن أخذ فيتامين C
''';
    }
    return 'اسألي عن حالة مثل: صداع، حرق، جرح، نزلة برد';
  }

  Future<void> sendMessage() async {
    final userText = _controller.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": userText});
      isLoading = true;
    });

    _controller.clear();
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 600));

    final reply = offlineReply(userText);

    setState(() {
      messages.add({"role": "ai", "text": reply});
      isLoading = false;
    });

    _speak(reply);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Widget _buildMessageBubble(Map<String, String> msg) {
    final isUser = msg["role"] == "user";

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Colors.white, Colors.grey],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUser)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.smart_toy, color: Colors.red),
              ),
            Flexible(
              child: Text(
                msg["text"] ?? "",
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            if (isUser)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.person, color: Color.fromARGB(255, 25, 64, 131)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        appBar: AppBar(
          backgroundColor: Colors.red,
          elevation: 0,
          title: const Text(
            'المساعد الذكي',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isLoading && index == messages.length) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(color: Colors.red),
                    );
                  }
                  final msg = messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'اكتبي سؤالك الصحي...',
                        filled: true,
                        fillColor: const Color(0xFFF1F2F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
