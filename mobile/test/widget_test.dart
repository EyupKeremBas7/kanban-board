import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KanbanBoardApp());

    // Splash ekranında "Kanban Board" başlığı görünmeli
    expect(find.text('Kanban Board'), findsOneWidget);
    expect(find.text('Üye Ol'), findsOneWidget);
    expect(find.text('Oturum Aç'), findsOneWidget);
  });
}
