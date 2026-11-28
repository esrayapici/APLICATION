import 'package:firebase_core/firebase_core.dart';

/// Firebase ayarları derleme sırasında config/secrets.json'dan gelir:
///   flutter run --dart-define-from-file=config/secrets.json
/// Değerler Firebase konsolunda: Proje ayarları > Genel > Android uygulaması.
/// Boşsa uygulama Firebase olmadan, örnek veriyle çalışır.
class FirebaseConfig {
  const FirebaseConfig._();

  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  static bool get isConfigured =>
      [_apiKey, _appId, _senderId, _projectId].every((v) => v.isNotEmpty);

  static FirebaseOptions get options => const FirebaseOptions(
        apiKey: _apiKey,
        appId: _appId,
        messagingSenderId: _senderId,
        projectId: _projectId,
      );
}
