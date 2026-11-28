import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';

/// Firestore üzerinde arkadaşlar, dizi ilerlemesi ve spoilersız sohbet.
///
/// Veri yapısı (sunucu kuralları: firestore.rules):
///   users/{uid}                     {name, friendCode, platforms[]}
///   users/{uid}/friends/{friendUid} {since}
///   users/{uid}/progress/{titleId}  {season, episode, epIndex}
///   friendCodes/{code}              {uid}
///   chats/{a_b__titleId}/messages   {authorId, titleId, season, episode, epIndex, text, sentAt}
///
/// Uygulamanın geri kalanı kullanıcıyı 'me' olarak tanır; bu sınıf kendi
/// uid'ini 'me'ye çevirir.
class SocialService {
  SocialService(this._db, this.uid);

  final FirebaseFirestore _db;
  final String uid;

  static const meAlias = 'me';

  /// Bölümü tek bir sayıya çevirir: S2B5 -> 2005. Sıralama ve kurallar için.
  static int epIndex(EpisodeRef ep) => ep.season * 1000 + ep.episode;

  /// İki kişi ve bir dizi için sohbet kimliği. Kurallar bu biçimi çözümler.
  static String chatId(String a, String b, String titleId) {
    final pair = [a, b]..sort();
    return '${pair[0]}_${pair[1]}__$titleId';
  }

  DocumentReference<Map<String, dynamic>> get _me => _db.collection('users').doc(uid);

  String _alias(String id) => id == uid ? meAlias : id;

  // ---------- Profil ----------

  /// İlk girişte profil ve arkadaş kodu oluşturur. Kodu döndürür.
  Future<String> ensureProfile({required String name}) async {
    final snap = await _me.get();
    final existing = snap.data()?['friendCode'] as String?;
    if (existing != null) return existing;

    final code = await _reserveFriendCode();
    await _me.set({
      'name': name,
      'friendCode': code,
      'platforms': <String>[],
    });
    return code;
  }

  Future<String> _reserveFriendCode() async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // karışan harfler yok
    final rnd = Random.secure();
    for (var i = 0; i < 5; i++) {
      final code = List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
      final ref = _db.collection('friendCodes').doc(code);
      final ok = await _db.runTransaction((tx) async {
        if ((await tx.get(ref)).exists) return false;
        tx.set(ref, {'uid': uid});
        return true;
      });
      if (ok) return code;
    }
    throw StateError('Arkadaş kodu oluşturulamadı');
  }

  Stream<({String name, String friendCode, Set<Platform> platforms})> myProfile() =>
      _me.snapshots().where((s) => s.exists).map((s) {
        final d = s.data()!;
        return (
          name: d['name'] as String? ?? '',
          friendCode: d['friendCode'] as String? ?? '',
          platforms: _platforms(d['platforms']),
        );
      });

  Future<void> setPlatforms(Set<Platform> platforms) =>
      _me.update({'platforms': platforms.map((p) => p.name).toList()});

  static Set<Platform> _platforms(Object? raw) => {
        for (final n in (raw as List? ?? const []))
          for (final p in Platform.values)
            if (p.name == n) p,
      };

  // ---------- Arkadaşlar ----------

  /// Arkadaş koduyla ekler (karşılıklı). Arkadaşın adını döndürür.
  Future<String> addFriendByCode(String rawCode) async {
    final code = rawCode.trim().toUpperCase();
    final codeDoc = await _db.collection('friendCodes').doc(code).get();
    final friendUid = codeDoc.data()?['uid'] as String?;
    if (friendUid == null) throw const FriendError('Bu kodla bir kullanıcı bulunamadı.');
    if (friendUid == uid) throw const FriendError('Bu senin kendi kodun.');

    final since = FieldValue.serverTimestamp();
    // Sıra önemli: kurallar, karşı tarafa yazmadan önce bizim tarafın var olmasını ister.
    await _me.collection('friends').doc(friendUid).set({'since': since, 'code': code});
    await _db.collection('users').doc(friendUid).collection('friends').doc(uid).set({'since': since});

    final profile = await _db.collection('users').doc(friendUid).get();
    return profile.data()?['name'] as String? ?? 'Arkadaş';
  }

  /// Arkadaş listesi; her arkadaşın profili canlı takip edilir.
  Stream<List<Friend>> friends() => _me.collection('friends').snapshots().asyncMap((s) async {
        final out = <Friend>[];
        for (final d in s.docs) {
          final p = await _db.collection('users').doc(d.id).get();
          final data = p.data();
          if (data == null) continue;
          out.add(Friend(
            id: d.id,
            name: data['name'] as String? ?? 'Arkadaş',
            platforms: _platforms(data['platforms']),
          ));
        }
        return out;
      });

  // ---------- İlerleme ----------

  /// Bir kişinin tüm dizi ilerlemesi (kendim için uid, arkadaş için onun uid'i).
  Stream<Map<String, EpisodeRef>> progress(String personUid) =>
      _db.collection('users').doc(personUid).collection('progress').snapshots().map((s) => {
            for (final d in s.docs)
              d.id: EpisodeRef(d['season'] as int, d['episode'] as int),
          });

  Future<void> setProgress(String titleId, EpisodeRef ep) =>
      _me.collection('progress').doc(titleId).set({
        'season': ep.season,
        'episode': ep.episode,
        'epIndex': epIndex(ep),
      });

  // ---------- Sohbet ----------

  /// Yalnızca benim izlediğim bölümlere kadar olan mesajları getirir.
  /// Sunucu kuralları da aynı sınırı uygular: daha ilerisi istemciye hiç gelmez.
  Stream<List<EpisodeMessage>> messages(String titleId, String friendUid, EpisodeRef myProgress) {
    return _db
        .collection('chats')
        .doc(chatId(uid, friendUid, titleId))
        .collection('messages')
        .where('epIndex', isLessThanOrEqualTo: epIndex(myProgress))
        .orderBy('epIndex')
        .snapshots()
        .map((s) {
      final list = [
        for (final d in s.docs)
          EpisodeMessage(
            authorId: _alias(d['authorId'] as String),
            friendId: friendUid,
            titleId: titleId,
            episode: EpisodeRef(d['season'] as int, d['episode'] as int),
            text: d['text'] as String,
            // Sunucu saati henüz yazılmadıysa (çevrimdışı) şimdiki zaman.
            sentAt: (d.data()['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          ),
      ];
      list.sort((a, b) {
        final c = a.episode.compareTo(b.episode);
        return c != 0 ? c : a.sentAt.compareTo(b.sentAt);
      });
      return list;
    });
  }

  Future<void> sendMessage(String titleId, String friendUid, EpisodeRef ep, String text) =>
      _db.collection('chats').doc(chatId(uid, friendUid, titleId)).collection('messages').add({
        'authorId': uid,
        'titleId': titleId,
        'season': ep.season,
        'episode': ep.episode,
        'epIndex': epIndex(ep),
        'text': text,
        'sentAt': FieldValue.serverTimestamp(),
      });
}

class FriendError implements Exception {
  const FriendError(this.message);
  final String message;
  @override
  String toString() => message;
}
