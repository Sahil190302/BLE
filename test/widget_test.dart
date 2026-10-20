import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:assignment/controllers/ble_controllers.dart';
import 'package:assignment/main.dart';

void main() {
  testWidgets('ScanScreen shows empty state initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BleController(),
        child: const BleApp(),
      ),
    );

    await tester.pump();

    // App title renders
    expect(find.text('Nearby Devices'), findsOneWidget);

    // Empty state shows before any scan
    expect(find.text('No devices found'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget); // FAB label
  });
}