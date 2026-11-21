# İzleyelim

Arkadaşlarla birlikte film/dizi seçme ve spoilersız dizi takibi uygulaması (Flutter, önce Android, sonra iOS).

## MVP özellikleri (bu sürümde)
- **Eşleş:** Bir grup seç (ör. "Cuma Akşamı"), kartları sağa (beğen) / sola (geç) kaydır. Gruptaki herkes beğenince "Eşleşme!" çıkar. Film / Dizi / Hepsi filtresi var. Kartlar yalnızca grubun aboneliklerindeki yapımlardan gelir.
- **Dizilerim:** Takip ettiğin diziler, ilerleme çubuğu, "sonraki bölümü izledim" düğmesi, bölüm bölüm işaretleme.
- **Spoilersız sohbet:** Bir arkadaşınla dizi bazında sohbet. Her mesaj bir bölüme bağlı; o bölümü izlemediysen mesaj kilitli görünür. Yalnızca ikinizin de izlediği bölümler hakkında yazabilirsin. Arkadaşın öndeyse bölüm numarası bile gösterilmez ("Senden önde").
- **Profil:** Abonelik seçimi, arkadaş listesi.

Katalog: TMDB anahtarı verilirse Türkiye'deki popüler film/diziler, afişler ve platformlar TMDB'den gelir (`lib/services/tmdb_service.dart`); anahtar yoksa örnek veri kullanılır. Arkadaşlar, gruplar ve sohbet şimdilik örnek (bellekte). Kurallar `lib/logic/` içinde, arayüzden bağımsız ve testli.

## Sonraki adımlar
1. Firebase: giriş (Google/Apple), arkadaş ekleme, Firestore ile gerçek zamanlı grup ve sohbet.
2. ~~TMDB API~~ (eklendi). Sırada arama ve sayfalama.
3. Bildirimler: "Eşleşme!" ve "Arkadaşın yeni bölüm izledi".
4. iOS derlemesi ve mağaza yayını.

## Çalıştırma
```
flutter pub get
flutter run        # bağlı Android cihaz veya emülatör (örnek veri)
flutter run --dart-define-from-file=config/secrets.json   # gerçek katalog
flutter test
```

## TMDB anahtarı
`config/secrets.example.json` dosyasını `config/secrets.json` adıyla kopyala ve anahtarını yaz.
`config/secrets.json` `.gitignore` içinde, GitHub'a gönderilmez.

## Klasör yapısı
- `lib/models/` veri modelleri
- `lib/logic/` eşleştirme ve spoiler kuralları
- `lib/state/` uygulama durumu
- `lib/data/` örnek veri
- `lib/screens/` ekranlar
