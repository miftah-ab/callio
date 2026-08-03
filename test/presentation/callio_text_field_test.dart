import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:callio/presentation/widgets/callio_text_field.dart';

void main() {
  testWidgets('CallioTextField displays error text when validation fails', (WidgetTester tester) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: CallioTextField(
              controller: controller,
              labelText: 'Response Name',
              validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
            ),
          ),
        ),
      ),
    );

    // Initial state: no error
    expect(find.text('Name is required'), findsNothing);

    // Trigger validation
    formKey.currentState!.validate();
    await tester.pumpAndSettle();

    // Error should now be visible
    expect(find.text('Name is required'), findsOneWidget);
  });
}
