import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strapi Articles',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ArticlesPage(),
    );
  }
}

class Article {
  final String title;
  final String content;

  Article({required this.title, required this.content});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      content: json['content'],
    );
  }
}

class ApiService {
  final String apiUrl = "http://localhost:1337/api/articles";

  Future<List<Article>> fetchArticles() async {
    var response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['data'];
      List<Article> articles = body
          .map(
            (dynamic item) => Article.fromJson(item['attributes']),
      )
          .toList();
      return articles;
    } else {
      throw "Can't get articles.";
    }
  }
}

class ArticlesPage extends StatelessWidget {
  final ApiService apiService = ApiService();

  ArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
      ),
      body: FutureBuilder(
        future: apiService.fetchArticles(),
        builder: (BuildContext context, AsyncSnapshot<List<Article>> snapshot) {
          if (snapshot.hasData) {
            List<Article>? articles = snapshot.data;
            return ListView.builder(
              itemCount: articles!.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(articles[index].title),
                subtitle: Text(articles[index].content),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
