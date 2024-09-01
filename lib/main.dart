import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AniList API ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  String _title = '';
  String _synopsis = '';
  String _imageUrl = '';
  String _error = '';

  Future<void> _fetchAnime() async {
    final query = _controller.text.isNotEmpty ? _controller.text : '';
    final url = 'https://graphql.anilist.co';

    final queryString = '''
    query {
      Media (search: "$query", type: ANIME) {
        title {
          romaji
        }
        description
        coverImage {
          large
        }
      }
    }
    ''';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': queryString}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data']['Media'] != null) {
          final media = data['data']['Media'];
          final title = media['title']['romaji'];
          final synopsis = media['description'];
          final imageUrl = media['coverImage']['large'];
          setState(() {
            _title = title;
            _synopsis = synopsis;
            _imageUrl = imageUrl;
            _error = '';
          });
        } else {
          setState(() {
            _error = 'No results found for "$query"';
            _title = '';
            _synopsis = '';
            _imageUrl = '';
          });
        }
      } else {
        setState(() {
          _error = 'Error: ${response.statusCode}';
          _title = '';
          _synopsis = '';
          _imageUrl = '';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Exception: $e';
        _title = '';
        _synopsis = '';
        _imageUrl = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AniList API '),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search for anime',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _fetchAnime,
              child: Text('Search'),
            ),
            SizedBox(height: 16.0),
            if (_error.isNotEmpty)
              Text(
                _error,
                style: TextStyle(color: Colors.red, fontSize: 16.0),
              ),
            if (_title.isNotEmpty) ...[
              Text(
                'Title: $_title',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 16.0),
              Text(
                'Synopsis: $_synopsis',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 16.0),
              _imageUrl.isNotEmpty
                  ? Image.network(
                      _imageUrl,
                      fit: BoxFit.cover,
                    )
                  : Container(),
            ],
          ],
        ),
      ),
    );
  }
}
