import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gift Card Suggester',
      home: const SuggestionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SuggestionPage extends StatefulWidget {
  const SuggestionPage({super.key});

  @override
  State<SuggestionPage> createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage> {
  final occasionController = TextEditingController();
  final relationshipController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';
  List<String> suggestions = [];
  String source = '';

  Future<void> getSuggestions() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      suggestions = [];
      source = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/v1/suggestions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'occasion': occasionController.text,
          'relationship': relationshipController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          suggestions = List<String>.from(data['suggestions']);
          source = data['source'];
        });
      } else {
        setState(() {
          errorMessage = extractErrorMessage(data);
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Could not connect to server';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String extractErrorMessage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return 'Unexpected error';
    }

    final message = data['message'];

    if (message is String && message.isNotEmpty) {
      return message;
    }

    return 'Unexpected error';
  }

  @override
  void dispose() {
    occasionController.dispose();
    relationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Card Message Suggester'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: occasionController,
              decoration: const InputDecoration(
                labelText: 'Occasion',
                hintText: 'e.g. Birthday',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                hintText: 'e.g. Friend',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : getSuggestions,
                child: const Text('Get suggestions'),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            if (source.isNotEmpty) Text('Source: $source'),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(suggestions[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}