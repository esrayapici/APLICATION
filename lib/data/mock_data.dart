import '../models/models.dart';

/// Örnek veri. Sonraki adımda TMDB API ve Firebase ile değiştirilecek.
/// Yapım adları örnek amaçlıdır.
const me = 'me';

const friends = <Friend>[
  Friend(id: 'ayse', name: 'Ayşe', platforms: {Platform.netflix, Platform.disneyPlus}),
  Friend(id: 'mert', name: 'Mert', platforms: {Platform.primeVideo, Platform.exxen}),
  Friend(id: 'zeynep', name: 'Zeynep', platforms: {Platform.netflix, Platform.mubi}),
];

const groups = <Group>[
  Group(id: 'g1', name: 'Cuma Akşamı', memberIds: [me, 'ayse', 'mert']),
  Group(id: 'g2', name: 'Sevgilimle', memberIds: [me, 'zeynep']),
];

const titles = <MediaTitle>[
  MediaTitle(id: 'f1', name: 'Yıldızlararası Yolculuk', type: TitleType.film, year: 2014,
      genres: ['Bilim Kurgu', 'Dram'], platforms: {Platform.netflix, Platform.primeVideo},
      overview: 'Bir grup kaşif insanlık için yeni bir yuva arar.'),
  MediaTitle(id: 'f2', name: 'Gece Yarısı Paris', type: TitleType.film, year: 2011,
      genres: ['Romantik', 'Komedi'], platforms: {Platform.mubi},
      overview: 'Bir yazar her gece yarısı geçmişe yolculuk eder.'),
  MediaTitle(id: 'f3', name: 'Soygun Planı', type: TitleType.film, year: 2019,
      genres: ['Aksiyon', 'Gerilim'], platforms: {Platform.disneyPlus},
      overview: 'Usta bir ekip son büyük işi için bir araya gelir.'),
  MediaTitle(id: 'f4', name: 'Köydeki Yabancı', type: TitleType.film, year: 2022,
      genres: ['Dram'], platforms: {Platform.exxen, Platform.blutv},
      overview: 'Anadolu\'da küçük bir köye gelen öğretmenin hikâyesi.'),
  MediaTitle(id: 'd1', name: 'Karanlık Orman', type: TitleType.dizi, year: 2021,
      genres: ['Gizem', 'Gerilim'], platforms: {Platform.netflix},
      overview: 'Kaybolan çocuklar küçük bir kasabanın sırlarını açığa çıkarır.',
      seasons: [8, 8, 6]),
  MediaTitle(id: 'd2', name: 'Mutfak Savaşları', type: TitleType.dizi, year: 2023,
      genres: ['Komedi'], platforms: {Platform.primeVideo},
      overview: 'İki rakip şef aynı restoranda çalışmak zorunda kalır.',
      seasons: [10]),
  MediaTitle(id: 'd3', name: 'Uzay İstasyonu', type: TitleType.dizi, year: 2020,
      genres: ['Bilim Kurgu'], platforms: {Platform.disneyPlus, Platform.netflix},
      overview: 'Dünya\'dan kopan bir istasyonda hayatta kalma mücadelesi.',
      seasons: [6, 6]),
];

/// Arkadaşların önceden beğendikleri (eşleşmeyi göstermek için).
final seedLikes = <String, Set<String>>{
  'ayse': {'f1', 'f3', 'd1', 'd3'},
  'mert': {'f1', 'f4', 'd2', 'd3'},
  'zeynep': {'f2', 'd1', 'f1'},
};

/// Dizi ilerlemeleri: kişi -> dizi -> son izlenen bölüm.
final seedProgress = <String, Map<String, EpisodeRef>>{
  me: {'d1': const EpisodeRef(1, 5), 'd3': const EpisodeRef(2, 2)},
  'ayse': {'d1': const EpisodeRef(2, 3), 'd3': const EpisodeRef(1, 4)},
  'zeynep': {'d1': const EpisodeRef(1, 3)},
  'mert': {'d3': const EpisodeRef(2, 6)},
};

final seedMessages = <EpisodeMessage>[
  EpisodeMessage(authorId: 'ayse', friendId: 'ayse', titleId: 'd1', episode: const EpisodeRef(1, 2),
      text: 'Bu bölümün sonu çok iyiydi!', sentAt: DateTime(2026, 11, 18, 21, 10)),
  EpisodeMessage(authorId: 'ayse', friendId: 'ayse', titleId: 'd1', episode: const EpisodeRef(2, 1),
      text: 'Mağaradaki kapıyı gördün mü?? İnanamıyorum.', sentAt: DateTime(2026, 11, 19, 22, 0)),
  EpisodeMessage(authorId: 'zeynep', friendId: 'zeynep', titleId: 'd1', episode: const EpisodeRef(1, 3),
      text: 'Saatçiye hiç güvenmiyorum.', sentAt: DateTime(2026, 11, 20, 20, 30)),
];
