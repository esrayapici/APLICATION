import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

import '../services/social_service.dart';
import '../state/app_state.dart';
import 'home_shell.dart';
import 'login_screen.dart';

/// Girişe göre ekran seçer: giriş yoksa giriş ekranı, varsa uygulama (bulut verisiyle).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.auth, required this.db});

  final FirebaseAuth auth;
  final FirebaseFirestore db;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _demo = false;
  String? _connectedUid;
  String? _pendingName;

  @override
  Widget build(BuildContext context) {
    if (_demo) return const HomeShell();
    return StreamBuilder<User?>(
      stream: widget.auth.authStateChanges(),
      builder: (context, snap) {
        final user = snap.data;
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (user == null) {
          _connectedUid = null;
          return LoginScreen(
            auth: widget.auth,
            onSignedIn: (_, name) => _pendingName = name,
            onTryDemo: () => setState(() => _demo = true),
          );
        }
        if (_connectedUid != user.uid) {
          _connectedUid = user.uid;
          final name = _pendingName ?? user.displayName ?? user.email?.split('@').first ?? 'Ben';
          final app = AppScope.of(context)..onSignOut = widget.auth.signOut;
          // Bağlantı build sırasında değil, kare çizildikten sonra kurulur.
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => app.connect(SocialService(widget.db, user.uid), name: name),
          );
        }
        return const HomeShell();
      },
    );
  }
}
