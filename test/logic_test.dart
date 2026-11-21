import 'package:flutter_test/flutter_test.dart' hide Matcher;
import 'package:izleyelim/data/mock_data.dart' as data;
import 'package:izleyelim/logic/matching.dart';
import 'package:izleyelim/logic/spoiler.dart';
import 'package:izleyelim/models/models.dart';

void main() {
  final series = data.titles.firstWhere((t) => t.id == 'd1'); // [8, 8, 6]

  group('SpoilerGuard', () {
    test('ortak ilerleme, geride olanın ilerlemesidir', () {
      expect(SpoilerGuard.sharedProgress(const EpisodeRef(1, 5), const EpisodeRef(2, 3)),
          const EpisodeRef(1, 5));
    });

    test('izlemediğin bölümün mesajı gizlenir', () {
      final m = EpisodeMessage(authorId: 'ayse', friendId: 'ayse', titleId: 'd1',
          episode: const EpisodeRef(2, 1), text: 'spoiler', sentAt: DateTime(2026));
      expect(SpoilerGuard.canSee(m, const EpisodeRef(1, 8)), isFalse);
      expect(SpoilerGuard.canSee(m, const EpisodeRef(2, 1)), isTrue);
    });

    test('yalnızca ikinizin de izlediği bölüme yazabilirsin', () {
      const me = EpisodeRef(2, 2);
      const friend = EpisodeRef(1, 4);
      expect(SpoilerGuard.canPost(const EpisodeRef(1, 4), me, friend), isTrue);
      expect(SpoilerGuard.canPost(const EpisodeRef(1, 5), me, friend), isFalse);
      expect(SpoilerGuard.canPost(EpisodeRef.none, me, friend), isFalse);
    });

    test('sonraki bölüm sezon geçişini bilir', () {
      expect(SpoilerGuard.nextEpisode(series, const EpisodeRef(1, 8)), const EpisodeRef(2, 1));
      expect(SpoilerGuard.nextEpisode(series, const EpisodeRef(3, 6)), isNull);
      expect(SpoilerGuard.watchedCount(series, const EpisodeRef(2, 1)), 9);
    });
  });

  group('Matcher', () {
    test('herkes beğenirse eşleşme olur', () {
      final likes = {'me': {'f1'}, 'ayse': {'f1', 'f3'}};
      expect(Matcher.isMatch('f1', ['me', 'ayse'], likes), isTrue);
      expect(Matcher.isMatch('f3', ['me', 'ayse'], likes), isFalse);
    });

    test('grubun abonelikleri dışındaki yapımlar gösterilmez', () {
      final list = Matcher.watchable(data.titles, {Platform.mubi});
      expect(list.map((t) => t.id), ['f2']);
    });
  });
}
