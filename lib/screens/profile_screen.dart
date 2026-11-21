import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../models/models.dart';
import '../state/app_state.dart';

/// Abonelikler: eşleştirme yalnızca gruptaki aboneliklerde olan yapımları gösterir.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (app.isOnline) ...[
          const _AccountCard(),
          const SizedBox(height: 24),
        ],
        Text('Aboneliklerim', style: Theme.of(context).textTheme.titleLarge),
        const Text('Grup önerileri, gruptaki aboneliklere göre filtrelenir.'),
        const SizedBox(height: 8),
        for (final p in Platform.values)
          CheckboxListTile(
            value: app.myPlatforms.contains(p),
            title: Text(p.label),
            onChanged: (_) => app.togglePlatform(p),
          ),
        const Divider(height: 32),
        Text('Arkadaşlar', style: Theme.of(context).textTheme.titleLarge),
        if (app.friends.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Henüz arkadaşın yok. Arkadaş kodunu paylaş ya da bir kod gir.'),
          ),
        for (final f in app.friends)
          ListTile(
            leading: CircleAvatar(child: Text(f.name.characters.first)),
            title: Text(f.name),
            subtitle: Text(f.platforms.map((p) => p.label).join(', ')),
          ),
      ],
    );
  }
}

/// Hesap bilgisi, arkadaş kodu ve arkadaş ekleme.
class _AccountCard extends StatefulWidget {
  const _AccountCard();

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard> {
  final _code = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _add(AppState app) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final name = await app.addFriend(_code.text);
      _code.clear();
      messenger.showSnackBar(SnackBar(content: Text('$name arkadaş olarak eklendi.')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final code = app.myFriendCode ?? '…';
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text('Merhaba, ${app.myName}', style: text.titleLarge)),
              TextButton(onPressed: app.signOut, child: const Text('Çıkış yap')),
            ]),
            const SizedBox(height: 12),
            const Text('Arkadaş kodun'),
            Row(children: [
              SelectableText(code, style: text.headlineSmall?.copyWith(letterSpacing: 4)),
              IconButton(
                tooltip: 'Kopyala',
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Kod kopyalandı.')));
                },
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _code,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Arkadaşının kodu',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _add(app),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _busy ? null : () => _add(app), child: const Text('Ekle')),
            ]),
          ],
        ),
      ),
    );
  }
}
