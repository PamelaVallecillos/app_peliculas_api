import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class Movie {
  final String title;
  final String posterPath;

  Movie(this.title, this.posterPath);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<Movie>> _listadoPeliculas = Future<List<Movie>>.value([]);

  Future<List<Movie>> _getPeliculas() async {
    final apiKey = "516b140cbda766452488fc90314e3f65";
    final uri =
        Uri.parse("https://api.themoviedb.org/3/movie/popular?api_key=$apiKey");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final results = jsonData["results"] as List;

      final peliculas = results.map((movieData) {
        return Movie(movieData["title"], movieData["poster_path"]);
      }).toList();

      return peliculas;
    } else {
      throw Exception("Fallo la conexión");
    }
  }

  @override
  void initState() {
    super.initState();
    _listadoPeliculas = _getPeliculas();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Peliculas Populares'),
        ),
        body: FutureBuilder(
          future: _listadoPeliculas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final pelicula = snapshot.data?[index];
                    return Card(
                      child: Column(
                        children: [
                          if (pelicula != null)
                            Image.network(
                              "https://image.tmdb.org/t/p/w185${pelicula.posterPath}",
                              fit: BoxFit.cover,
                              height: 150,
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(pelicula?.title ?? ""),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return Text("Error");
              }
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
