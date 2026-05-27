import 'package:flutter/material.dart';
import 'movie_model.dart';

class MovieDetailScreen extends StatelessWidget {
  final MovieModel movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF0A0E21),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: movie.fullBackdropUrl.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          movie.fullBackdropUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const ColoredBox(color: Color(0xFF1C2033)),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF0A0E21),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const ColoredBox(color: Color(0xFF1C2033)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster + Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: movie.fullPosterUrl.isNotEmpty
                            ? Image.network(
                                movie.fullPosterUrl,
                                width: 110,
                                height: 165,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 110,
                                height: 165,
                                color: const Color(0xFF1C2033),
                                child: const Icon(Icons.movie,
                                    color: Colors.white24),
                              ),
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoBadge(
                                Icons.calendar_today,
                                movie.releaseDate.isNotEmpty
                                    ? movie.releaseDate
                                    : 'N/A'),
                            const SizedBox(height: 8),
                            _buildInfoBadge(
                                Icons.star_rounded, '${movie.rating} / 10',
                                color: const Color(0xFFF5C518)),
                            const SizedBox(height: 8),
                            _buildInfoBadge(
                                Icons.people_alt_rounded,
                                '${movie.voteCount} votes'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Rating bar visual
                  _buildRatingBar(movie.voteAverage),

                  const SizedBox(height: 28),

                  // Overview
                  const Text(
                    'Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2033),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      movie.overview.isNotEmpty
                          ? movie.overview
                          : 'No description available.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label,
      {Color color = Colors.white60}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(double rating) {
    final percent = rating / 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'User Score',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              '${(percent * 100).toInt()}%',
              style: const TextStyle(
                  color: Color(0xFF01B4E4),
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: const Color(0xFF1C2033),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF01B4E4)),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}