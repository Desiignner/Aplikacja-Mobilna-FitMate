import 'dart:convert';
import 'package:fitmate/utils/app_colors.dart';
import 'package:fitmate/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class QuoteCard extends StatefulWidget {
  const QuoteCard({super.key});

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  String _quote = 'Loading quote...';
  String _author = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    try {
      final response =
          await http.get(Uri.parse('https://dummyjson.com/quotes/random'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            _quote = data['quote'];
            _author = data['author'];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _quote = 'Failed to load quote.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _quote = 'Could not fetch quote.';
        _isLoading = false;
      });
      debugPrint('Error fetching quote: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? const Center(
                child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(color: primaryColor),
              ))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote, color: primaryColor, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    _quote,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'serif', // Elegant serif font for quotes
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "- $_author",
                      style: const TextStyle(
                        color: secondaryTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
