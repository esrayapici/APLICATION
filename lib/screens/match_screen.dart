import 'package:material_ui/material_ui.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import 'widgets.dart';

/// Grupla film/dizi seçme: kartı sağa kaydır = beğen, sola = geç.
/// Gruptaki herkes beğenirse "Eşleşme!" çıkar.
class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  int _groupIndex = 0;
  TitleType? _type; // null = hepsi

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final group = app.groups[_groupIndex];
    final deck = app.deckFor(group, type: _type);
    final matches = app.matchesFor(group);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  value: _groupIndex,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: Theme.of(context).textTheme.titleLarge,
                  items: [
                    for (var i = 0; i < app.groups.length; i++)
                      DropdownMenuItem(value: i, child: Text(app.groups[i].name)),
                  ],
                  onChanged: (i) => setState(() => _groupIndex = i!),
                ),
              ),
              Badge(
                label: Text('${matches.length}'),
                isLabelVisible: matches.isNotEmpty,
                child: IconButton(
                  tooltip: 'Eşleşmeler',
                  icon: const Icon(Icons.celebration_outlined),
                  onPressed: () => _showMatches(context, matches),
                ),
              ),
            ],
          ),
          Text(
            group.memberIds.map(app.nameOf).join(', '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          SegmentedButton<TitleType?>(
            segments: const [
              ButtonSegment(value: null, label: Text('Hepsi')),
              ButtonSegment(value: TitleType.film, label: Text('Film')),
              ButtonSegment(value: TitleType.dizi, label: Text('Dizi')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: deck.isEmpty
                ? const Center(child: Text('Bu grup için oylanacak yapım kalmadı.'))
                : _SwipeCard(
                    key: ValueKey(deck.first.id),
                    title: deck.first,
                    groupPlatforms: app.groupPlatforms(group),
                    onLike: () {
                      final t = deck.first;
                      if (app.like(group, t)) _celebrate(context, t);
                    },
                    onPass: () => app.pass(group, deck.first),
                  ),
          ),
        ],
      ),
    );
  }

  void _celebrate(BuildContext context, MediaTitle t) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.celebration, size: 40),
        title: const Text('Eşleşme!'),
        content: Text('Gruptaki herkes "${t.name}" izlemek istiyor.'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Harika'))],
      ),
    );
  }

  void _showMatches(BuildContext context, List<MediaTitle> matches) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          Text('Eşleşmeler', style: Theme.of(context).textTheme.titleLarge),
          if (matches.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('Henüz eşleşme yok.')),
          for (final t in matches)
            ListTile(
              leading: PosterBox(title: t, size: 32),
              title: Text(t.name),
              subtitle: Text('${t.type == TitleType.film ? 'Film' : 'Dizi'} · ${t.platforms.map((p) => p.label).join(', ')}'),
            ),
        ],
      ),
    );
  }
}

class _SwipeCard extends StatelessWidget {
  const _SwipeCard({
    super.key,
    required this.title,
    required this.groupPlatforms,
    required this.onLike,
    required this.onPass,
  });

  final MediaTitle title;
  final Set<Platform> groupPlatforms;
  final VoidCallback onLike;
  final VoidCallback onPass;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: Dismissible(
            key: ValueKey('card-${title.id}'),
            onDismissed: (dir) => dir == DismissDirection.startToEnd ? onLike() : onPass(),
            background: _swipeHint(Icons.favorite, Colors.green, Alignment.centerLeft),
            secondaryBackground: _swipeHint(Icons.close, Colors.red, Alignment.centerRight),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(flex: 3, child: Center(child: FittedBox(child: PosterBox(title: title, size: 140)))),
                    const SizedBox(height: 16),
                    Text(title.name, style: text.headlineSmall),
                    Text(
                      [
                        title.type == TitleType.film ? 'Film' : 'Dizi · ${title.seasons.length} sezon',
                        '${title.year}',
                        title.genres.join(', '),
                      ].join(' · '),
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Expanded(flex: 2, child: Text(title.overview, style: text.bodyMedium, overflow: TextOverflow.fade)),
                    PlatformChips(platforms: title.platforms, highlight: groupPlatforms),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filledTonal(iconSize: 32, onPressed: onPass, icon: const Icon(Icons.close)),
            IconButton.filled(iconSize: 32, onPressed: onLike, icon: const Icon(Icons.favorite)),
          ],
        ),
      ],
    );
  }

  Widget _swipeHint(IconData icon, Color color, Alignment align) => Container(
        alignment: align,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Icon(icon, color: color, size: 64),
      );
}
