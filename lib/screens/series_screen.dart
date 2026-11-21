import 'package:material_ui/material_ui.dart';

import '../logic/spoiler.dart';
import '../state/app_state.dart';
import 'series_detail_screen.dart';
import 'widgets.dart';

/// Takip edilen diziler ve ilerleme.
class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Dizilerim', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final t in app.mySeries)
          Card(
            child: ListTile(
              leading: PosterBox(title: t, size: 36),
              title: Text(t.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${app.progressOf('me', t.id).label} · '
                      '${app.friendsWatching(t).length} arkadaş izliyor'),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: SpoilerGuard.watchedCount(t, app.progressOf('me', t.id)) / t.totalEpisodes,
                  ),
                ],
              ),
              trailing: IconButton(
                tooltip: 'Sonraki bölümü izledim',
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => app.markNextWatched(t),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => SeriesDetailScreen(titleId: t.id)),
              ),
            ),
          ),
        if (app.otherSeries.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Takibe al', style: Theme.of(context).textTheme.titleMedium),
          for (final t in app.otherSeries)
            ListTile(
              leading: PosterBox(title: t, size: 36),
              title: Text(t.name),
              subtitle: Text('${app.friendsWatching(t).length} arkadaş izliyor'),
              trailing: FilledButton.tonal(onPressed: () => app.followSeries(t), child: const Text('Takip et')),
            ),
        ],
      ],
    );
  }
}
