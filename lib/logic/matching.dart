import '../models/models.dart';

/// Grup eşleştirme kuralları.
class Matcher {
  const Matcher._();

  /// Gruptaki herkesin en az birinin abone olduğu platformlar (ortak izlenebilirlik):
  /// bir yapım, gruptan herhangi birinin aboneliğinde varsa birlikte izlenebilir.
  static Set<Platform> groupPlatforms(Iterable<Set<Platform>> memberPlatforms) =>
      memberPlatforms.fold(<Platform>{}, (acc, p) => acc..addAll(p));

  /// Grubun izleyebileceği yapımlar.
  static List<MediaTitle> watchable(List<MediaTitle> titles, Set<Platform> platforms) =>
      titles.where((t) => t.platforms.any(platforms.contains)).toList();

  /// Bir yapım, gruptaki herkes beğendiyse eşleşmedir.
  static bool isMatch(String titleId, List<String> memberIds,
          Map<String, Set<String>> likesByMember) =>
      memberIds.isNotEmpty &&
      memberIds.every((m) => likesByMember[m]?.contains(titleId) ?? false);
}
