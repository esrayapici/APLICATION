import 'package:flutter/widgets.dart';

import '../data/mock_data.dart' as data;
import '../logic/matching.dart';
import '../logic/spoiler.dart';
import '../models/models.dart';

/// Uygulama durumu. Şimdilik bellekte; sonra Firebase (Firestore) ile senkronlanacak.
class AppState extends ChangeNotifier {
  AppState({List<MediaTitle>? catalog}) : _catalog = catalog ?? data.titles;

  List<MediaTitle> _catalog;
  bool loadingCatalog = false;

  /// Kataloğu gerçek kaynaktan (TMDB) yükler; hata olursa örnek veride kalır.
  Future<void> loadCatalog(Future<List<MediaTitle>> Function() source) async {
    loadingCatalog = true;
    notifyListeners();
    try {
      final list = await source();
      if (list.isNotEmpty) _catalog = list;
    } catch (e) {
      debugPrint('Katalog yüklenemedi, örnek veri kullanılıyor: $e');
    } finally {
      loadingCatalog = false;
      notifyListeners();
    }
  }

  Set<Platform> myPlatforms = {Platform.netflix, Platform.primeVideo};

  final Map<String, Set<String>> _likes = {
    for (final e in data.seedLikes.entries) e.key: {...e.value},
    data.me: {},
  };
  final Map<String, Set<String>> _passes = {};
  final Map<String, Map<String, EpisodeRef>> _progress = {
    for (final e in data.seedProgress.entries) e.key: {...e.value},
  };
  final List<EpisodeMessage> _messages = [...data.seedMessages];

  List<Group> get groups => data.groups;
  List<Friend> get friends => data.friends;
  List<MediaTitle> get allTitles => _catalog;

  Friend friend(String id) => data.friends.firstWhere((f) => f.id == id);
  MediaTitle title(String id) => _catalog.firstWhere((t) => t.id == id);
  String nameOf(String id) => id == data.me ? 'Sen' : friend(id).name;

  Set<Platform> platformsOf(String id) =>
      id == data.me ? myPlatforms : friend(id).platforms;

  void togglePlatform(Platform p) {
    myPlatforms.contains(p) ? myPlatforms.remove(p) : myPlatforms.add(p);
    notifyListeners();
  }

  // ---------- Eşleştirme ----------

  Set<Platform> groupPlatforms(Group g) =>
      Matcher.groupPlatforms(g.memberIds.map(platformsOf));

  /// Grubun henüz oylamadığım, izleyebileceği yapımlar.
  List<MediaTitle> deckFor(Group g, {TitleType? type}) {
    final seen = {...?_likes[data.me], ...?_passes[g.id]};
    return Matcher.watchable(_catalog, groupPlatforms(g))
        .where((t) => type == null || t.type == type)
        .where((t) => !seen.contains(t.id))
        .toList();
  }

  /// Beğeniyi kaydeder; herkes beğendiyse true döner (eşleşme).
  bool like(Group g, MediaTitle t) {
    _likes[data.me]!.add(t.id);
    notifyListeners();
    return Matcher.isMatch(t.id, g.memberIds, _likes);
  }

  void pass(Group g, MediaTitle t) {
    _passes.putIfAbsent(g.id, () => {}).add(t.id);
    notifyListeners();
  }

  List<MediaTitle> matchesFor(Group g) => _catalog
      .where((t) => Matcher.isMatch(t.id, g.memberIds, _likes))
      .toList();

  // ---------- Dizi takibi ----------

  EpisodeRef progressOf(String personId, String titleId) =>
      _progress[personId]?[titleId] ?? EpisodeRef.none;

  /// Takip ettiğim diziler.
  List<MediaTitle> get mySeries => _catalog
      .where((t) => t.type == TitleType.dizi && _progress[data.me]!.containsKey(t.id))
      .toList();

  List<MediaTitle> get otherSeries => _catalog
      .where((t) => t.type == TitleType.dizi && !_progress[data.me]!.containsKey(t.id))
      .toList();

  void followSeries(MediaTitle t) {
    _progress[data.me]!.putIfAbsent(t.id, () => EpisodeRef.none);
    notifyListeners();
  }

  void setProgress(MediaTitle t, EpisodeRef ep) {
    _progress[data.me]![t.id] = ep;
    notifyListeners();
  }

  void markNextWatched(MediaTitle t) {
    final next = SpoilerGuard.nextEpisode(t, progressOf(data.me, t.id));
    if (next != null) setProgress(t, next);
  }

  /// Bu diziyi izleyen arkadaşlar.
  List<Friend> friendsWatching(MediaTitle t) => data.friends
      .where((f) => _progress[f.id]?.containsKey(t.id) ?? false)
      .toList();

  /// Benimle bir arkadaş arasındaki dizi sohbeti.
  List<EpisodeMessage> conversation(MediaTitle t, String friendId) => _messages
      .where((m) => m.titleId == t.id && m.friendId == friendId)
      .toList()
    ..sort((a, b) => a.episode.compareTo(b.episode) != 0
        ? a.episode.compareTo(b.episode)
        : a.sentAt.compareTo(b.sentAt));

  void sendMessage(MediaTitle t, String friendId, EpisodeRef ep, String text) {
    _messages.add(EpisodeMessage(
        authorId: data.me, friendId: friendId, titleId: t.id, episode: ep, text: text, sentAt: DateTime.now()));
    notifyListeners();
  }
}

/// Durumu widget ağacına taşır.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
