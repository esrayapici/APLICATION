import 'package:material_ui/material_ui.dart';

import '../logic/spoiler.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Bir arkadaşla dizi sohbeti. Her mesaj bir bölüme bağlıdır:
/// - O bölümü izlemediysen mesaj kilitli görünür.
/// - Yalnızca ikinizin de izlediği bölümler hakkında yazabilirsin.
class EpisodeChatScreen extends StatefulWidget {
  const EpisodeChatScreen({super.key, required this.titleId, required this.friendId});

  final String titleId;
  final String friendId;

  @override
  State<EpisodeChatScreen> createState() => _EpisodeChatScreenState();
}

class _EpisodeChatScreenState extends State<EpisodeChatScreen> {
  final _controller = TextEditingController();
  EpisodeRef? _target;
  Stream<List<EpisodeMessage>>? _stream;
  EpisodeRef? _streamFor;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = app.title(widget.titleId);
    final friend = app.friend(widget.friendId);
    final mine = app.progressOf('me', t.id);
    final theirs = app.progressOf(friend.id, t.id);
    final shared = SpoilerGuard.sharedProgress(mine, theirs);
    final postable = SpoilerGuard.allEpisodes(t)
        .where((ep) => SpoilerGuard.canPost(ep, mine, theirs))
        .toList();
    final target = postable.contains(_target) ? _target : (postable.isEmpty ? null : postable.last);
    // İlerlemem değişince akışı yenile: sunucu yalnızca izlediğim bölümlere kadarını verir.
    if (_stream == null || _streamFor != mine) {
      _stream = app.conversationStream(t, friend.id);
      _streamFor = mine;
    }
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${friend.name} · ${t.name}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              shared == EpisodeRef.none
                  ? 'Henüz ortak izlediğiniz bölüm yok'
                  : 'Güvenli bölge: ${shared.label}\'e kadar',
              style: TextStyle(color: scheme.primary),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<EpisodeMessage>>(
              stream: _stream,
              builder: (context, snap) {
                final messages = snap.data ?? const <EpisodeMessage>[];
                return ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    if (snap.hasError)
                      const Text('Mesajlar yüklenemedi. Bağlantını kontrol et.'),
                    for (final m in messages) _Bubble(message: m, visible: SpoilerGuard.canSee(m, mine)),
                    if (app.isOnline && mine < theirs)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Arkadaşın senden önde. Sonraki bölümlerin mesajları sen izledikçe açılır.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: target == null
                  ? const Text('İkiniz de en az bir bölüm izleyince sohbet açılır.')
                  : Row(
                      children: [
                        DropdownButton<EpisodeRef>(
                          value: target,
                          items: [
                            for (final ep in postable) DropdownMenuItem(value: ep, child: Text(ep.label)),
                          ],
                          onChanged: (ep) => setState(() => _target = ep),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(hintText: 'Mesaj yaz', border: OutlineInputBorder()),
                            onSubmitted: (_) => _send(app, t, target),
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.send), onPressed: () => _send(app, t, target)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _send(AppState app, MediaTitle t, EpisodeRef ep) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    app.sendMessage(t, widget.friendId, ep, text);
    _controller.clear();
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.visible});

  final EpisodeMessage message;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final mineMsg = message.authorId == 'me';
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: mineMsg ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: mineMsg ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${app.nameOf(message.authorId)} · ${message.episode.label}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            visible
                ? Text(message.text)
                : const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.lock_outline, size: 16, color: AppColors.accent),
                    SizedBox(width: 6),
                    Flexible(child: Text('Spoiler gizlendi. Bu bölümü izleyince açılır.')),
                  ]),
          ],
        ),
      ),
    );
  }
}
