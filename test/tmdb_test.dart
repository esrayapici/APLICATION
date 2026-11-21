import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:izleyelim/models/models.dart';
import 'package:izleyelim/services/tmdb_service.dart';

void main() {
  test('platform adları eşlenir', () {
    expect(TmdbService.platformFromName('Netflix'), Platform.netflix);
    expect(TmdbService.platformFromName('Amazon Prime Video'), Platform.primeVideo);
    expect(TmdbService.platformFromName('Bilinmeyen'), isNull);
  });

  test('anahtar yoksa boş katalog döner', () async {
    expect(await TmdbService(apiKey: '').fetchCatalog(), isEmpty);
  });

  test('TMDB yanıtı modele çevrilir, platformsuz yapım atlanır', () async {
    final client = MockClient((req) async {
      final p = req.url.path;
      Object body = switch (p) {
        '/3/genre/movie/list' || '/3/genre/tv/list' => {'genres': [{'id': 18, 'name': 'Dram'}]},
        '/3/discover/movie' => {'results': [
            {'id': 1, 'title': 'Film A', 'release_date': '2020-05-01', 'genre_ids': [18], 'poster_path': '/a.jpg', 'overview': 'x'},
            {'id': 2, 'title': 'Film B', 'release_date': '2021-01-01', 'genre_ids': []},
          ]},
        '/3/discover/tv' => {'results': [
            {'id': 3, 'name': 'Dizi C', 'first_air_date': '2019-01-01', 'genre_ids': [18]},
          ]},
        '/3/movie/1/watch/providers' => {'results': {'TR': {'flatrate': [{'provider_name': 'Netflix'}]}}},
        '/3/movie/2/watch/providers' => {'results': {}},
        '/3/tv/3/watch/providers' => {'results': {'TR': {'flatrate': [{'provider_name': 'Disney Plus'}]}}},
        '/3/tv/3' => {'seasons': [
            {'season_number': 0, 'episode_count': 2},
            {'season_number': 1, 'episode_count': 8},
            {'season_number': 2, 'episode_count': 6},
          ]},
        _ => throw StateError('beklenmeyen istek $p'),
      };
      return http.Response(jsonEncode(body), 200);
    });

    final list = await TmdbService(client: client, apiKey: 'k').fetchCatalog();
    expect(list.map((t) => t.name), ['Film A', 'Dizi C']);
    expect(list.first.platforms, {Platform.netflix});
    expect(list.first.genres, ['Dram']);
    expect(list.first.posterUrl, endsWith('/a.jpg'));
    expect(list.last.seasons, [8, 6]); // özel bölümler (sezon 0) hariç
  });
}
