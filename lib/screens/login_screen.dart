import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_ui/material_ui.dart';

/// E-posta ve şifreyle giriş / kayıt.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth, required this.onSignedIn, required this.onTryDemo});

  final FirebaseAuth auth;

  /// Giriş başarılı olunca kullanıcı ve (kayıtta) girilen ad ile çağrılır.
  final void Function(User user, String? name) onSignedIn;
  final VoidCallback onTryDemo;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final email = _email.text.trim();
      final cred = _register
          ? await widget.auth.createUserWithEmailAndPassword(email: email, password: _password.text)
          : await widget.auth.signInWithEmailAndPassword(email: email, password: _password.text);
      final name = _register ? _name.text.trim() : null;
      if (name != null) await cred.user!.updateDisplayName(name);
      widget.onSignedIn(cred.user!, name);
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _message(e.code));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _message(String code) => switch (code) {
        'invalid-email' => 'E-posta adresi geçersiz.',
        'email-already-in-use' => 'Bu e-postayla zaten bir hesap var. Giriş yapmayı dene.',
        'weak-password' => 'Şifre en az 6 karakter olmalı.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' => 'E-posta ya da şifre hatalı.',
        'network-request-failed' => 'İnternet bağlantısı yok.',
        'too-many-requests' => 'Çok fazla deneme yapıldı. Biraz sonra tekrar dene.',
        _ => 'Bir sorun oluştu ($code).',
      };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('İzleyelim', style: text.displaySmall, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      const Text('Arkadaşlarınla birlikte seç, spoilersız izle.', textAlign: TextAlign.center),
                      const SizedBox(height: 32),
                      if (_register) ...[
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(labelText: 'Adın', border: OutlineInputBorder()),
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.givenName],
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Adını yaz'
                              : (v.trim().length > 40 ? 'En fazla 40 karakter' : null),
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(labelText: 'E-posta', border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: (v) => (v == null || !v.contains('@')) ? 'Geçerli bir e-posta yaz' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _password,
                        decoration: const InputDecoration(labelText: 'Şifre', border: OutlineInputBorder()),
                        obscureText: true,
                        autofillHints: [_register ? AutofillHints.newPassword : AutofillHints.password],
                        validator: (v) => (v == null || v.length < 6) ? 'En az 6 karakter' : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _busy ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(_register ? 'Hesap oluştur' : 'Giriş yap'),
                        ),
                      ),
                      TextButton(
                        onPressed: _busy ? null : () => setState(() => _register = !_register),
                        child: Text(_register ? 'Zaten hesabım var' : 'Yeni hesap oluştur'),
                      ),
                      const Divider(height: 32),
                      OutlinedButton(onPressed: widget.onTryDemo, child: const Text('Örnek verilerle dene')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
