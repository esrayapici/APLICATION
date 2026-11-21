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
