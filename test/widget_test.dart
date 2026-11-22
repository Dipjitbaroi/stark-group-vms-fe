import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vms_web/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('VMS App mounts and renders fleet title when authenticated', (WidgetTester tester) async {
    await tester.pumpWidget(const VmsApp(startAuthenticated: true));
    await tester.pumpAndSettle();

    expect(find.text('Vehicles'), findsWidgets);
    expect(find.text('Register Vehicle'), findsWidgets);
  });

  testWidgets('VMS App displays login portal by default', (WidgetTester tester) async {
    await tester.pumpWidget(const VmsApp());
    await tester.pumpAndSettle();

    expect(find.text('Stark Group VMS'), findsWidgets);
    expect(find.text('Sign In to VMS'), findsWidgets);
  });
}
