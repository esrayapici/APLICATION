import 'package:material_ui/material_ui.dart';

import '../logic/spoiler.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'episode_chat_screen.dart';
import 'widgets.dart';

/// Dizi detayı: bölüm işaretleme ve arkadaşların ilerlemesi.
class SeriesDetailScreen extends StatelessWidget {
  const SeriesDetailScreen({super.key, required this.titleId});

  final String titleId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = app.title(titleId);
    final mine = app.progressOf('me', t.id);

    return Scaffold(
      appBar: AppBar(title: Text(t.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            PosterBox(title: t, size: 64),
            const SizedBox(width: 16),
            Expanded(child: Text('Sen: ${mine.label}\n${SpoilerGuard.watchedCount(t, mine)}/${t.totalEpisodes} bölüm')),
          ]),
          const SizedBox(height: 24),
          Text('Arkadaşlar', style: Theme.of(context).textTheme.titleMedium),
          if (app.friendsWatching(t).isEmpty) const Text('Bu diziyi izleyen arkadaşın yok.'),
          for (final f in app.friendsWatching(t))
            _FriendRow(title: t, friend: f, mine: mine, theirs: app.progressOf(f.id, t.id)),
          const SizedBox(height: 24),
          Text('Bölümler', style: Theme.of(context).textTheme.titleMedium),
          const Text('Son izlediğin bölüme dokun.', style: TextStyle(fontSize: 12)),
          for (var s = 0; s < t.seasons.length; s++) ...[
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Text('Sezon ${s + 1}'),
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var e = 1; e <= t.seasons[s]; e++)
                  _EpisodeChip(
                    ep: EpisodeRef(s + 1, e),
                    watched: EpisodeRef(s + 1, e) <= mine,
                    onTap: () => app.setProgress(t, EpisodeRef(s + 1, e)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => app.setProgress(t, EpisodeRef.none),
            child: const Text('İlerlemeyi sıfırla'),
          ),
        ],
      ),
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({required this.title, required this.friend, required this.mine, required this.theirs});

  final MediaTitle title;
  final Friend friend;
  final EpisodeRef mine;
  final EpisodeRef theirs;

  @override
  Widget build(BuildContext context) {
    final ahead = mine < theirs;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Text(friend.name.characters.first)),
      title: Text(friend.name),
      // Arkadaş öndeyse tam bölümünü göstermiyoruz: bölüm numarası bile ipucu olabilir.
      subtitle: Text(ahead ? 'Senden önde' : theirs.label),
      trailing: FilledButton.tonalIcon(
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Sohbet'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => EpisodeChatScreen(titleId: title.id, friendId: friend.id),
          ),
        ),
      ),
    );
  }
}

class _EpisodeChip extends StatelessWidget {
  const _EpisodeChip({required this.ep, required this.watched, required this.onTap});

  final EpisodeRef ep;
  final bool watched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => FilterChip(
        label: Text('${ep.episode}'),
        selected: watched,
        showCheckmark: false,
        onSelected: (_) => onTap(),
      );
}
