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
        child: Image.network(
          url,
          width: size,
          height: size * 1.4,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    final hue = _hueFor(title);
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
            HSLColor.fromAHSL(1, hue, .7, .5).toColor(),
            HSLColor.fromAHSL(1, (hue + 35) % 360, .6, .22).toColor(),
          ],
        ),
      ),
      child: Text(
        title.name.characters.first,
        style: TextStyle(
          fontSize: size * .5,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class PlatformChips extends StatelessWidget {
  const PlatformChips({
    super.key,
    required this.platforms,
    this.highlight = const {},
  });

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
              color: highlight.contains(p)
                  ? scheme.primary
                  : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              p.label,
              style: TextStyle(
                fontSize: 12,
                fontVariations: const [FontVariation('wght', 600)],
                color: highlight.contains(p)
                    ? scheme.onPrimary
                    : scheme.onSurface,
              ),
            ),
          ),
      ],
    );
  }
}

/// Afiş yoksa paletle uyumlu (turkuaz-mor-pembe arası) bir renk tonu.
double _hueFor(MediaTitle t) => 175 + (t.id.hashCode.abs() % 150).toDouble();

/// Alanı tamamen dolduran afiş (kaydırma kartı için).
class PosterFill extends StatelessWidget {
  const PosterFill({super.key, required this.title});

  final MediaTitle title;

  @override
  Widget build(BuildContext context) {
    final url = title.posterUrl;
    final hue = _hueFor(title);
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, hue, .75, .45).toColor(),
            HSLColor.fromAHSL(1, (hue + 40) % 360, .65, .18).toColor(),
          ],
        ),
      ),
      child: Align(
        alignment: const Alignment(0, -0.35),
        child: Text(
          title.name.characters.first,
          style: TextStyle(
            fontFamily: 'Bricolage',
            fontSize: 160,
            fontVariations: const [FontVariation('wght', 800)],
            color: Colors.white.withValues(alpha: 0.18),
          ),
        ),
      ),
    );
    if (url == null) return placeholder;
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
