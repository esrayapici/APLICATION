import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:izleyelim/screens/login_screen.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('kayıt formu adı alır ve hesap oluşturur', (tester) async {
    final auth = MockFirebaseAuth();
    String? gotName;
    await tester.pumpWidget(MaterialApp(
      home: LoginScreen(auth: auth, onSignedIn: (_, name) => gotName = name, onTryDemo: () {}),
    ));

    await tester.tap(find.text('Yeni hesap oluştur'));
    await tester.pump();
    await tester.tap(find.text('Hesap oluştur'));
    await tester.pump();
    expect(find.text('Adını yaz'), findsOneWidget); // boş form gönderilmez

    await tester.enterText(find.widgetWithText(TextFormField, 'Adın'), 'Esra');
    await tester.enterText(find.widgetWithText(TextFormField, 'E-posta'), 'esra@ornek.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Şifre'), 'gizli123');
    await tester.tap(find.text('Hesap oluştur'));
    await tester.pumpAndSettle();

    expect(gotName, 'Esra');
    expect(auth.currentUser, isNotNull);
  });
}
