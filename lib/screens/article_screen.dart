import 'package:flutter/material.dart';
import '../models/article.dart';

class ArticleScreen extends StatelessWidget {
  final Article article;

  ArticleScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📖 Статья'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F4F4F),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  article.content,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Color(0xFF2F4F4F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}