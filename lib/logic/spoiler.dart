import '../models/models.dart';

/// Spoiler koruması kuralları. Arayüzden bağımsız, test edilebilir saf fonksiyonlar.
class SpoilerGuard {
  const SpoilerGuard._();

  /// İki kişinin birlikte konuşabileceği en son bölüm: ikisinin de geçtiği bölüm.
  static EpisodeRef sharedProgress(EpisodeRef a, EpisodeRef b) =>
      a <= b ? a : b;

  /// Kullanıcı bir mesajı ancak o bölümü izlediyse görebilir.
  static bool canSee(EpisodeMessage m, EpisodeRef myProgress) =>
      m.episode != EpisodeRef.none && m.episode <= myProgress;

  /// Kullanıcı yalnızca iki tarafın da izlediği bölümlere mesaj yazabilir.
  static bool canPost(EpisodeRef target, EpisodeRef me, EpisodeRef friend) =>
      target != EpisodeRef.none && target <= sharedProgress(me, friend);

  /// Dizinin bölümlerini sırayla listeler.
  static List<EpisodeRef> allEpisodes(MediaTitle t) => [
        for (var s = 0; s < t.seasons.length; s++)
          for (var e = 1; e <= t.seasons[s]; e++) EpisodeRef(s + 1, e),
      ];

  /// İzlenen son bölümden sonraki bölüm; dizi bittiyse null.
  static EpisodeRef? nextEpisode(MediaTitle t, EpisodeRef current) {
    for (final ep in allEpisodes(t)) {
      if (current < ep) return ep;
    }
    return null;
  }

  /// İzlenen bölüm sayısı (ilerleme çubuğu için).
  static int watchedCount(MediaTitle t, EpisodeRef current) =>
      allEpisodes(t).where((ep) => ep <= current).length;
}
