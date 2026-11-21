// Uygulamanın temel veri modelleri.

enum TitleType { film, dizi }

/// Yayın platformları. Gerçek sürümde TMDB "watch providers" verisinden gelir.
enum Platform { netflix, primeVideo, disneyPlus, exxen, blutv, mubi }

extension PlatformLabel on Platform {
  String get label => switch (this) {
        Platform.netflix => 'Netflix',
        Platform.primeVideo => 'Prime Video',
        Platform.disneyPlus => 'Disney+',
        Platform.exxen => 'Exxen',
        Platform.blutv => 'BluTV',
        Platform.mubi => 'MUBI',
      };
}

class MediaTitle {
  const MediaTitle({
    required this.id,
    required this.name,
    required this.type,
    required this.year,
    required this.genres,
    required this.platforms,
    this.overview = '',
    this.seasons = const [],
    this.posterUrl,
  });

  final String id;
  final String name;
  final TitleType type;
  final int year;
  final List<String> genres;
  final Set<Platform> platforms;
  final String overview;

  /// Diziler için her sezondaki bölüm sayısı. Örn: [8, 10] = 2 sezon.
  final List<int> seasons;

  /// Afiş adresi (TMDB). Yoksa renkli yer tutucu gösterilir.
  final String? posterUrl;

  int get totalEpisodes => seasons.fold(0, (a, b) => a + b);
}

/// Bir dizide belirli bir bölüm. Karşılaştırılabilir (S1B3 < S2B1).
class EpisodeRef implements Comparable<EpisodeRef> {
  const EpisodeRef(this.season, this.episode);

  final int season;
  final int episode;

  /// Hiç izlenmemiş durumunu temsil eder.
  static const none = EpisodeRef(0, 0);

  @override
  int compareTo(EpisodeRef other) =>
      season != other.season ? season - other.season : episode - other.episode;

  bool operator <=(EpisodeRef other) => compareTo(other) <= 0;
  bool operator <(EpisodeRef other) => compareTo(other) < 0;

  @override
  bool operator ==(Object other) =>
      other is EpisodeRef && other.season == season && other.episode == episode;

  @override
  int get hashCode => Object.hash(season, episode);

  String get label => this == none ? 'Başlamadı' : 'S${season}B$episode';

  @override
  String toString() => label;
}

class Friend {
  const Friend({required this.id, required this.name, required this.platforms});

  final String id;
  final String name;
  final Set<Platform> platforms;
}

class Group {
  const Group({required this.id, required this.name, required this.memberIds});

  final String id;
  final String name;

  /// Kullanıcının kendisi ('me') de dahil tüm üyeler.
  final List<String> memberIds;
}

/// Bir dizinin belirli bir bölümüne bağlı sohbet mesajı.
class EpisodeMessage {
  const EpisodeMessage({
    required this.authorId,
    required this.friendId,
    required this.titleId,
    required this.episode,
    required this.text,
    required this.sentAt,
  });

  final String authorId;

  /// Sohbetin hangi arkadaşla olduğu (birebir dizi sohbeti).
  final String friendId;
  final String titleId;
  final EpisodeRef episode;
  final String text;
  final DateTime sentAt;
}
