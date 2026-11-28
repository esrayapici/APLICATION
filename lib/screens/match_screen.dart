import 'package:material_ui/material_ui.dart';

import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
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
    final groupIndex = _groupIndex.clamp(0, app.groups.length - 1);
    final group = app.groups[groupIndex];
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
                  value: groupIndex,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: Theme.of(context).textTheme.titleLarge,
                  items: [
                    for (var i = 0; i < app.groups.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(app.groups[i].name),
                      ),
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
                ? const Center(
                    child: Text('Bu grup için oylanacak yapım kalmadı.'),
                  )
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Harika'),
          ),
        ],
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
          if (matches.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Henüz eşleşme yok.'),
            ),
          for (final t in matches)
            ListTile(
              leading: PosterBox(title: t, size: 32),
              title: Text(t.name),
              subtitle: Text(
                '${t.type == TitleType.film ? 'Film' : 'Dizi'} · ${t.platforms.map((p) => p.label).join(', ')}',
              ),
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
    return Column(
      children: [
        Expanded(
          child: Dismissible(
            key: ValueKey('card-${title.id}'),
            onDismissed: (dir) =>
                dir == DismissDirection.startToEnd ? onLike() : onPass(),
            background: _swipeHint(
              Icons.favorite_rounded,
              AppColors.accent,
              Alignment.centerLeft,
            ),
            secondaryBackground: _swipeHint(
              Icons.close,
              AppColors.textMuted,
              Alignment.centerRight,
            ),
            child: _PosterCard(title: title, groupPlatforms: groupPlatforms),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundAction(
              label: 'Geç',
              icon: Icons.close_rounded,
              size: 60,
              onTap: onPass,
            ),
            const SizedBox(width: 36),
            _RoundAction(
              label: 'Beğen',
              icon: Icons.favorite_rounded,
              size: 76,
              onTap: onLike,
              highlighted: true,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _swipeHint(IconData icon, Color color, Alignment align) => Container(
    alignment: align,
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Icon(icon, color: color, size: 64),
  );
}

/// Tam boy afiş kartı: afiş arka planda, bilgiler alttaki karartmanın üstünde.
class _PosterCard extends StatelessWidget {
  const _PosterCard({required this.title, required this.groupPlatforms});

  final MediaTitle title;
  final Set<Platform> groupPlatforms;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final meta = [
      title.type == TitleType.film
          ? 'Film'
          : 'Dizi · ${title.seasons.length} sezon',
      '${title.year}',
      ...title.genres.take(2),
    ].join('  ·  ');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: AppColors.signature,
        boxShadow: AppColors.glow(),
      ),
      padding: const EdgeInsets.all(2), // ince renkli çerçeve
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PosterFill(title: title),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.35, 1],
                  colors: [Color(0x000B0716), Color(0xF20B0716)],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: _Tag(
                label: title.type == TitleType.film ? 'FİLM' : 'DİZİ',
                color: title.type == TitleType.film
                    ? AppColors.primary
                    : AppColors.accent,
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title.name, style: text.headlineMedium, maxLines: 2),
                  const SizedBox(height: 6),
                  Text(meta, style: text.bodySmall),
                  const SizedBox(height: 10),
                  Text(
                    title.overview,
                    style: text.bodyMedium?.copyWith(
                      color: AppColors.text.withValues(alpha: 0.85),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  PlatformChips(
                    platforms: title.platforms,
                    highlight: groupPlatforms,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontVariations: [FontVariation('wght', 800)],
        letterSpacing: 1.2,
        color: AppColors.onPrimary,
      ),
    ),
  );
}

/// Yuvarlak eylem düğmesi; vurgulu olan imza geçişli ve ışıltılı.
class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.label,
    required this.icon,
    required this.size,
    required this.onTap,
    this.highlighted = false,
  });

  final String label;
  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: highlighted ? AppColors.signature : null,
            color: highlighted ? null : AppColors.card,
            border: highlighted
                ? null
                : Border.all(color: AppColors.line, width: 1.5),
            boxShadow: highlighted ? AppColors.glow(AppColors.accent) : null,
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Icon(
              icon,
              size: size * 0.45,
              color: highlighted ? AppColors.onAccent : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
