// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'movie_model.dart';
import 'movie_services.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen>
    with SingleTickerProviderStateMixin {
  final MovieService _movieService = MovieService();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  late Future<List<MovieModel>> _movieFuture;
  Future<List<MovieModel>>? _searchFuture;
  bool _isSearching = false;

  final List<Map<String, String>> _categories = [
    {'label': 'Popular', 'value': 'popular'},
    {'label': 'Now Playing', 'value': 'now_playing'},
    {'label': 'Top Rated', 'value': 'top_rated'},
    {'label': 'Upcoming', 'value': 'upcoming'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadMovies(_categories[_tabController.index]['value']!);
      }
    });
    _loadMovies('popular');
  }

  void _loadMovies(String category) {
    setState(() {
      _movieFuture = _movieService.fetchMovies(category: category);
    });
  }

  void _onSearchSubmit(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _searchFuture = _movieService.searchMovies(query.trim());
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchFuture = null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: _buildAppBar(),
      body: _isSearching && _searchFuture != null
          ? _buildMovieGrid(_searchFuture!)
          : Column(
              children: [
                _buildTabBar(),
                Expanded(child: _buildMovieGrid(_movieFuture)),
              ],
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0E21),
      elevation: 0,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Cari film...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
              ),
              onSubmitted: _onSearchSubmit,
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF01B4E4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.movie, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'MovieMate',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
      actions: [
        _isSearching
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _stopSearch,
              )
            : IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => setState(() => _isSearching = true),
              ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 40,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF01B4E4),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: _categories
            .map((c) => Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(c['label']!),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMovieGrid(Future<List<MovieModel>> future) {
    return FutureBuilder<List<MovieModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF01B4E4)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, color: Colors.white38, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Gagal memuat film',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _loadMovies('popular'),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01B4E4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.movie_filter, color: Colors.white38, size: 64),
                SizedBox(height: 16),
                Text(
                  'Film tidak ditemukan',
                  style: TextStyle(color: Colors.white38, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final movies = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => _loadMovies(
              _categories[_tabController.index]['value']!),
          color: const Color(0xFF01B4E4),
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return _MovieCard(movie: movies[index]);
            },
          ),
        );
      },
    );
  }
}

class _MovieCard extends StatelessWidget {
  final MovieModel movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MovieDetailScreen(movie: movie),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C2033),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    child: movie.fullPosterUrl.isNotEmpty
                        ? Image.network(
                            movie.fullPosterUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: const Color(0xFF1C2033),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF01B4E4),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stack) {
                              return Container(
                                color: const Color(0xFF1C2033),
                                child: const Icon(Icons.broken_image,
                                    color: Colors.white24, size: 40),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFF1C2033),
                            child: const Icon(Icons.movie,
                                color: Colors.white24, size: 40),
                          ),
                  ),
                  // Badge rating
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star,
                              color: Color(0xFFF5C518), size: 12),
                          const SizedBox(width: 3),
                          Text(
                            movie.rating,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.year,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}