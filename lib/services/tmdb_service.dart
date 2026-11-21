import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

/// TMDB (themoviedb.org) katalog servisi: Türkiye'deki popüler film ve diziler,
/// afişleri ve hangi platformda olduğu.
///
/// Anahtar derleme sırasında verilir, koda yazılmaz:
///   flutter run --dart-define=TMDB_API_KEY=xxxx
class TmdbService {
  TmdbService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('TMDB_API_KEY');

  final http.Client _client;
  final String _apiKey;

  static const _base = 'api.themoviedb.org';
  static const _region = 'TR';
  static const _imageBase = 'https://image.tmdb.org/t/p/w342';

  bool get isConfigured => _apiKey.isNotEmpty;

  /// TMDB'deki sağlayıcı adını uygulamadaki platforma çevirir.
  static Platform? platformFromName(String name) {
    final n = name.toLowerCase();
    if (n.contains('netflix')) return Platform.netflix;
    if (n.contains('prime video') || n == 'amazon video') return Platform.primeVideo;
    if (n.contains('disney')) return Platform.disneyPlus;
    if (n.contains('exxen')) return Platform.exxen;
    if (n.contains('blutv') || n.contains('blu tv')) return Platform.blutv;
    if (n.contains('mubi')) return Platform.mubi;
    return null;
  }

  Future<Map<String, dynamic>> _get(String path, [Map<String, String>? query]) async {
    final uri = Uri.https(_base, '/3$path', {
      'api_key': _apiKey,
      'language': 'tr-TR',
      ...?query,
    });
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('TMDB $path: ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Popüler filmler ve diziler; yalnızca bilinen bir platformda olanlar.
  Future<List<MediaTitle>> fetchCatalog({int perType = 20}) async {
    if (!isConfigured) return const [];
    final films = await _discover(TitleType.film, perType);
    final series = await _discover(TitleType.dizi, perType);
    return [...films, ...series];
  }

  Future<List<MediaTitle>> _discover(TitleType type, int limit) async {
    final kind = type == TitleType.film ? 'movie' : 'tv';
    final genres = await _genres(kind);
    final page = await _get('/discover/$kind', {
      'watch_region': _region,
      'with_watch_monetization_types': 'flatrate',
      'sort_by': 'popularity.desc',
    });
    final results = (page['results'] as List).cast<Map<String, dynamic>>().take(limit);

    final out = <MediaTitle>[];
    for (final r in results) {
      final id = r['id'] as int;
      final platforms = await _providers(kind, id);
      if (platforms.isEmpty) continue;
      final seasons = type == TitleType.dizi ? await _seasons(id) : const <int>[];
      final date = (r['release_date'] ?? r['first_air_date'] ?? '') as String;
      final poster = r['poster_path'] as String?;
      out.add(MediaTitle(
        id: '$kind-$id',
        name: (r['title'] ?? r['name']) as String,
        type: type,
        year: date.length >= 4 ? int.parse(date.substring(0, 4)) : 0,
        genres: [
          for (final g in (r['genre_ids'] as List? ?? const [])) ?genres[g],
        ],
        platforms: platforms,
        overview: (r['overview'] as String?) ?? '',
        seasons: seasons,
        posterUrl: poster == null ? null : '$_imageBase$poster',
      ));
    }
    return out;
  }

  final _genreCache = <String, Map<int, String>>{};

  Future<Map<int, String>> _genres(String kind) async {
    if (_genreCache[kind] case final cached?) return cached;
    final res = await _get('/genre/$kind/list');
    return _genreCache[kind] = {
      for (final g in (res['genres'] as List).cast<Map<String, dynamic>>())
        g['id'] as int: g['name'] as String,
    };
  }

  Future<Set<Platform>> _providers(String kind, int id) async {
    final res = await _get('/$kind/$id/watch/providers');
    final tr = (res['results'] as Map<String, dynamic>)[_region] as Map<String, dynamic>?;
    final flat = (tr?['flatrate'] as List? ?? const []).cast<Map<String, dynamic>>();
    return {
      for (final p in flat) ?platformFromName(p['provider_name'] as String),
    };
  }

  Future<List<int>> _seasons(int id) async {
    final res = await _get('/tv/$id');
    return [
      for (final s in (res['seasons'] as List).cast<Map<String, dynamic>>())
        if ((s['season_number'] as int) > 0) s['episode_count'] as int,
    ];
  }
}
