import 'package:flutter/material.dart';
import '../models/form_schema.dart';
import '../widgets/dynamic_form.dart';

class DraftFormScreen extends StatelessWidget {
  final DraftSchema schema;
  const DraftFormScreen({super.key, required this.schema});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(schema.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: DynamicForm(schema: schema),
        ),
      ),
    );
  }
}
