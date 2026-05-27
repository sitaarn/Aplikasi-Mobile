import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_model.dart';

class MovieService {
  static const String _apiKey = 'fac6e02d1ad5ec445ac7b01fc6f2e513';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<MovieModel>> fetchMovies({String category = 'popular'}) async {
    final uri = Uri.parse(
      '$_baseUrl/movie/$category?api_key=$_apiKey&language=en-US&page=1',
    );

    final response = await http
        .get(uri, headers: {'Content-Type': 'application/json'})
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw Exception('Request timeout.'),
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results
          .map((json) => MovieModel.fromJson(json))
          .where((m) => m.posterPath != null)
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('API Key tidak valid.');
    } else {
      throw Exception('Gagal memuat data. Status: ${response.statusCode}');
    }
  }

  Future<List<MovieModel>> searchMovies(String query) async {
    final uri = Uri.parse(
      '$_baseUrl/search/movie?api_key=$_apiKey&language=en-US&query=$query&page=1',
    );

    final response = await http
        .get(uri, headers: {'Content-Type': 'application/json'})
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['results'];
      return results
          .map((json) => MovieModel.fromJson(json))
          .where((m) => m.posterPath != null)
          .toList();
    } else {
      throw Exception('Gagal mencari film.');
    }
  }
}