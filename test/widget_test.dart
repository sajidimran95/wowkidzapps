import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart';

void main() {
  testWidgets('WowKidz app loads home page', (WidgetTester tester) async {
    await tester.pumpWidget(const WowKidzApp());
    await tester.pumpAndSettle();

    expect(find.text('WowKidz'), findsWidgets);
    expect(find.text('Featured Categories'), findsOneWidget);
  });
}
