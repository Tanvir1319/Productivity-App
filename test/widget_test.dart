import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focusflow/main.dart';
import 'package:focusflow/services/storage_service.dart';

void main() {
  testWidgets('FocusFlow smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = StorageService();
    await storage.init();

    await tester.pumpWidget(FocusFlowApp(storageService: storage));
    await tester.pumpAndSettle();

    expect(find.text('FocusFlow'), findsOneWidget);
  });
}
