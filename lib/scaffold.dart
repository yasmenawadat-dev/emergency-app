import 'package:flutter/material.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String? title; 
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;

  const CustomScaffold({
    super.key,
    required this.body,
    this.title,
    this.bottomNavigationBar,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null 
          ? AppBar(
              title: Text(title!),
              centerTitle: true,
              backgroundColor: Colors.red.shade700, // لون موحد للتطبيق
              actions: actions,
            ) 
          : null,
      body: SafeArea(
        // تغليف المحتوى بالسكرول ليكون متاحاً في كل التطبيق
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: body,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}