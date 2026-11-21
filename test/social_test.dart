import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:izleyelim/models/models.dart';
import 'package:izleyelim/services/social_service.dart';
import 'package:izleyelim/state/app_state.dart';

void main() {
  late FakeFirebaseFirestore db;
  late SocialService ali, ayse;
  const t = 'tv-1';

  setUp(() async {
    db = FakeFirebaseFirestore();
    ali = SocialService(db, 'aliUid');
    ayse = SocialService(db, 'ayseUid');
  });

  test('profil ve 6 haneli arkadaş kodu bir kez oluşur', () async {
    final code = await ali.ensureProfile(name: 'Ali');
    expect(code, matches(RegExp(r'^[A-Z2-9]{6}$')));
    expect(await ali.ensureProfile(name: 'Ali'), code);
    final owner = await db.collection('friendCodes').doc(code).get();
    expect(owner['uid'], 'aliUid');
  });

  test('arkadaş kodu ile karşılıklı arkadaş olunur', () async {
    await ali.ensureProfile(name: 'Ali');
    final code = await ayse.ensureProfile(name: 'Ayşe');
    expect(await ali.addFriendByCode(code.toLowerCase()), 'Ayşe');

    expect((await ali.friends().first).map((f) => f.name), ['Ayşe']);
    expect((await ayse.friends().first).map((f) => f.name), ['Ali']);
  });

  test('yanlış ya da kendi kodum hata verir', () async {
    final mine = await ali.ensureProfile(name: 'Ali');
    expect(() => ali.addFriendByCode('XXXXXX'), throwsA(isA<FriendError>()));
    expect(() => ali.addFriendByCode(mine), throwsA(isA<FriendError>()));
  });

  test('sohbet yalnızca izlediğim bölüme kadar olan mesajları getirir', () async {
    await ayse.sendMessage(t, 'aliUid', const EpisodeRef(1, 2), 'güzel bölüm');
    await ayse.sendMessage(t, 'aliUid', const EpisodeRef(2, 1), 'spoiler');
    await ali.sendMessage(t, 'ayseUid', const EpisodeRef(1, 1), 'başladım');

    final list = await ali.messages(t, 'ayseUid', const EpisodeRef(1, 5)).first;
    expect(list.map((m) => m.text), ['başladım', 'güzel bölüm']);
    expect(list.first.authorId, 'me');

    final later = await ali.messages(t, 'ayseUid', const EpisodeRef(2, 1)).first;
    expect(later.map((m) => m.text), contains('spoiler'));
  });

  test('uygulama buluta bağlanınca arkadaş ve ilerleme senkronlanır', () async {
    await ali.ensureProfile(name: 'Ali');
    final code = await ayse.ensureProfile(name: 'Ayşe');
    await ali.addFriendByCode(code);
    await ayse.setProgress(t, const EpisodeRef(2, 3));

    final app = AppState();
    await app.connect(ali, name: 'Ali');
    await pumpEventQueue();

    expect(app.isOnline, isTrue);
    expect(app.friends.map((f) => f.name), ['Ayşe']);
    expect(app.progressOf('ayseUid', t), const EpisodeRef(2, 3));
    expect(app.groups.first.memberIds, ['me', 'ayseUid']);
    await app.disconnect();
  });
}
