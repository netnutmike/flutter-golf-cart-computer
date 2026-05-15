import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_cart_computer/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: GolfCartComputerApp()),
    );

    expect(find.text('Golf Cart Computer'), findsOneWidget);
  });
}
