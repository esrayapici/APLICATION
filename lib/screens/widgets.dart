import 'package:material_ui/material_ui.dart';

import '../models/models.dart';

/// Afiş yerine geçici renkli kutu (gerçek sürümde TMDB afişi).
class PosterBox extends StatelessWidget {
  const PosterBox({super.key, required this.title, this.size = 56});

  final MediaTitle title;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (title.posterUrl case final url?) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 6),
        child: Image.network(url, width: size, height: size * 1.4, fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholder()),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    final hue = (title.id.hashCode % 360).abs().toDouble();
    return Container(
      width: size,
      height: size * 1.4,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, hue, .55, .45).toColor(),
            HSLColor.fromAHSL(1, (hue + 40) % 360, .6, .25).toColor(),
          ],
        ),
      ),
      child: Text(
        title.name.characters.first,
        style: TextStyle(fontSize: size * .5, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}

class PlatformChips extends StatelessWidget {
  const PlatformChips({super.key, required this.platforms, this.highlight = const {}});

  final Set<Platform> platforms;
  final Set<Platform> highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final p in platforms)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: highlight.contains(p) ? scheme.primaryContainer : scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(p.label, style: const TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}
