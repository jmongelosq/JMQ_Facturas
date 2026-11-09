import 'package:flutter_test/flutter_test.dart';
import 'package:jmq_facturas/main.dart';

void main() {
  testWidgets('La aplicación inicia', (WidgetTester tester) async {
    await tester.pumpWidget(const JmqFacturasApp());

    expect(find.text('JMQ SYSTEM'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
