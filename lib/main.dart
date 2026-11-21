import 'package:material_ui/material_ui.dart';

import 'screens/home_shell.dart';
import 'services/tmdb_service.dart';
import 'state/app_state.dart';

void main() {
  final state = AppState();
  final tmdb = TmdbService();
  // TMDB anahtarı verildiyse gerçek katalog yüklenir, yoksa örnek veriyle çalışır.
  if (tmdb.isConfigured) state.loadCatalog(tmdb.fetchCatalog);
  runApp(IzleyelimApp(state: state));
}

class IzleyelimApp extends StatelessWidget {
  const IzleyelimApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'İzleyelim',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFFE5484D),
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const HomeShell(),
      ),
    );
  }
}
