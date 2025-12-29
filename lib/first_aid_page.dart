import 'package:flutter/material.dart';
import 'ai_assistant_page.dart';

class FirstAidPage extends StatelessWidget {
  const FirstAidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإسعافات'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.smart_toy),
          label: const Text('الذكاء الاصطناعي'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AiAssistantPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
