import 'package:flutter_test/flutter_test.dart';
import 'package:pawcare/app.dart';

void main() {
  testWidgets('PawCare app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PawCareApp());
    expect(find.text('PawCare'), findsWidgets);
  });
}
