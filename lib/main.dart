import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';

import 'screens/auth_gate.dart';
import 'screens/home_shell.dart';
import 'services/firebase_config.dart';
import 'services/tmdb_service.dart';
import 'state/app_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();

  // Firebase ayarları verildiyse giriş ve bulut açılır, verilmediyse örnek veriyle çalışır.
  var firebaseReady = false;
  if (FirebaseConfig.isConfigured) {
    try {
      await Firebase.initializeApp(options: FirebaseConfig.options);
      firebaseReady = true;
    } catch (e) {
      debugPrint('Firebase açılamadı, örnek veriyle devam: $e');
    }
  }

  final tmdb = TmdbService();
  // TMDB anahtarı verildiyse gerçek katalog yüklenir, yoksa örnek veriyle çalışır.
  if (tmdb.isConfigured) state.loadCatalog(tmdb.fetchCatalog);
  runApp(IzleyelimApp(state: state, firebaseReady: firebaseReady));
}

class IzleyelimApp extends StatelessWidget {
  const IzleyelimApp({super.key, required this.state, this.firebaseReady = false});

  final AppState state;
  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'İzleyelim',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: firebaseReady
            ? AuthGate(auth: FirebaseAuth.instance, db: FirebaseFirestore.instance)
            : const HomeShell(),
      ),
    );
  }
}
