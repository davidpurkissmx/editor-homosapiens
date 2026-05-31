import 'package:flutter_test/flutter_test.dart';

import 'package:editor_app/main.dart';

void main() {
  testWidgets('App renders editor title', (WidgetTester tester) async {
    await tester.pumpWidget(const EditorApp());
    expect(find.text('Editor Homosapiens'), findsOneWidget);
  });
}
