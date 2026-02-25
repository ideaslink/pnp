import 'package:flutter_test/flutter_test.dart';
import 'package:point_and_play/main.dart';

void main() {
  testWidgets('Dashboard screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const PointAndPlayApp());
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
