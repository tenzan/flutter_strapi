import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

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
          .map((dynamic item) => Article.fromJson(item['attributes']))
          .toList();
      return articles;
    } else {
      throw "Can't get articles.";
    }
  }
}

class WebSocketService {
  final String socketUrl = "ws://127.0.0.1:3000/webhooks/article-updates";
  late WebSocketChannel channel;

  void connect(Function(dynamic) onData) {
    channel = WebSocketChannel.connect(Uri.parse(socketUrl));
    channel.stream.listen(
      onData,
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }

  void dispose() {
    channel.sink.close();
  }
}

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final ApiService apiService = ApiService();
  final WebSocketService webSocketService = WebSocketService();
  List<Article>? articles;

  @override
  void initState() {
    super.initState();
    webSocketService.connect(_handleWebSocketData);
    _fetchArticles();
  }

  void _fetchArticles() async {
    try {
      var fetchedArticles = await apiService.fetchArticles();
      setState(() {
        articles = fetchedArticles;
      });
    } catch (e) {
      print('Failed to fetch articles: $e');
    }
  }

  void _handleWebSocketData(dynamic data) {
    _fetchArticles();
  }

  @override
  void dispose() {
    webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
      ),
      body: articles == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: articles!.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(articles![index].title),
                subtitle: Text(articles![index].content),
              ),
            ),
    );
  }
}
