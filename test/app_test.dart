import 'package:flutter_test/flutter_test.dart';
import 'package:izleyelim/main.dart';
import 'package:izleyelim/state/app_state.dart';
import 'package:material_ui/material_ui.dart' show Size;

void main() {
  testWidgets('üç sekme açılır ve dizi sohbeti spoiler gizler', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(IzleyelimApp(state: AppState()));
    expect(find.text('Cuma Akşamı'), findsOneWidget);

    await tester.tap(find.text('Dizilerim'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Karanlık Orman'));
    await tester.pumpAndSettle();

    // Ayşe S2B3'te, ben S1B5'teyim: Ayşe'nin bölümü gizli.
    expect(find.text('Senden önde'), findsOneWidget);
    await tester.tap(find.text('Sohbet').first);
    await tester.pumpAndSettle();

    expect(find.text('Bu bölümün sonu çok iyiydi!'), findsOneWidget);
    expect(find.textContaining('Mağaradaki kapı'), findsNothing);
    expect(find.textContaining('Spoiler gizlendi'), findsOneWidget);
  });
}
