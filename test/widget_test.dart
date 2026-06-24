import 'package:flutter_test/flutter_test.dart';

import 'package:aquapulse_smart_water_user_app/main.dart';

void main() {
  testWidgets('AquaPulse app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const AquaPulseApp());

    expect(find.text('AquaPulse'), findsWidgets);
  });
}
