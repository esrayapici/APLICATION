# İzleyelim

Arkadaşlarla birlikte film/dizi seçme ve spoilersız dizi takibi uygulaması (Flutter, önce Android, sonra iOS).

## MVP özellikleri (bu sürümde)
- **Eşleş:** Bir grup seç (ör. "Cuma Akşamı"), kartları sağa (beğen) / sola (geç) kaydır. Gruptaki herkes beğenince "Eşleşme!" çıkar. Film / Dizi / Hepsi filtresi var. Kartlar yalnızca grubun aboneliklerindeki yapımlardan gelir.
- **Dizilerim:** Takip ettiğin diziler, ilerleme çubuğu, "sonraki bölümü izledim" düğmesi, bölüm bölüm işaretleme.
- **Spoilersız sohbet:** Bir arkadaşınla dizi bazında sohbet. Her mesaj bir bölüme bağlı; o bölümü izlemediysen mesaj kilitli görünür. Yalnızca ikinizin de izlediği bölümler hakkında yazabilirsin. Arkadaşın öndeyse bölüm numarası bile gösterilmez ("Senden önde").
- **Profil:** Abonelik seçimi, arkadaş listesi.

Katalog: TMDB anahtarı verilirse Türkiye'deki popüler film/diziler, afişler ve platformlar TMDB'den gelir (`lib/services/tmdb_service.dart`); anahtar yoksa örnek veri kullanılır. Arkadaşlar, gruplar ve sohbet şimdilik örnek (bellekte). Kurallar `lib/logic/` içinde, arayüzden bağımsız ve testli.

## Sonraki adımlar
1. ~~Firebase~~ (eklendi: e-posta ile giriş, arkadaş kodu, canlı ilerleme ve sohbet). Sırada Google/Apple ile giriş ve grup oylarının senkronu.
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

## Firebase kurulumu (bir kez)
1. https://console.firebase.google.com adresinde yeni proje oluştur.
2. **Authentication** > Sign-in method > **Email/Password** aç.
3. **Firestore Database** oluştur (bölge: europe-west).
4. Proje ayarları > Genel > **Android uygulaması ekle** (paket adı: `com.izleyelim.izleyelim`).
5. Oradaki değerleri `config/secrets.json` içine yaz: `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_SENDER_ID`, `FIREBASE_PROJECT_ID`.
6. Güvenlik kurallarını yükle: Firestore > Rules sekmesine `firestore.rules` içeriğini yapıştır ve yayınla (ya da `firebase deploy --only firestore:rules`).

Ayarlar boşsa uygulama girişsiz, örnek veriyle açılır.

### Spoiler koruması sunucuda da var
`firestore.rules`, izlemediğin bölümün mesajlarını sunucudan okumanı ve arkadaşının izlemediği bölüme yazmanı engeller.
Kural testleri emülatörde çalışır: `cd rules-test && npm install && npm test`.

## Klasör yapısı
- `lib/models/` veri modelleri
- `lib/logic/` eşleştirme ve spoiler kuralları
- `lib/state/` uygulama durumu
- `lib/data/` örnek veri
- `lib/services/` TMDB kataloğu, Firebase arkadaş/ilerleme/sohbet servisi
- `lib/screens/` ekranlar
