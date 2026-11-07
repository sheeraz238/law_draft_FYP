import 'package:flutter/material.dart';
import '../models/form_schema.dart';

String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

Map<String, String> newParty() => {
  'name': '',
  'relation': 'S/O',
  'father': '',
  'caste': '',
  'address': '',
};

String? requiredValidator(String? v) =>
    (v == null || v.trim().isEmpty) ? 'Required' : null;

class DynamicForm extends StatefulWidget {
  final DraftSchema schema;
  const DynamicForm({super.key, required this.schema});

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _values = {};

  @override
  void initState() {
    super.initState();
    for (final s in widget.schema.sections) {
      for (final f in s.fields) {
        _values[f.key] = _initialValue(f);
      }
    }
  }

  dynamic _initialValue(FormFieldDef f) {
    switch (f.type) {
      case FieldType.dropdown:
        return f.options.first;
      case FieldType.date:
        return DateTime.now();
      case FieldType.parties:
        return {
          'type': f.options.first,
          'parties': [newParty()],
        };
      default:
        return '';
    }
  }

  String _label(FormFieldDef f) => f.required ? '${f.label} *' : f.label;

  Widget _buildField(FormFieldDef f) {
    switch (f.type) {
      case FieldType.text:
      case FieldType.multiline:
        return TextFormField(
          initialValue: _values[f.key] as String,
          maxLines: f.type == FieldType.multiline ? 4 : 1,
          decoration: InputDecoration(
            labelText: _label(f),
            hintText: f.hint,
            border: const OutlineInputBorder(),
          ),
          validator: f.required ? requiredValidator : null,
          onChanged: (v) => _values[f.key] = v,
        );
      case FieldType.dropdown:
        return DropdownButtonFormField<String>(
          value: _values[f.key] as String,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: _label(f),
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final o in f.options)
              DropdownMenuItem(value: o, child: Text(o)),
          ],
          onChanged: (v) => setState(() => _values[f.key] = v),
        );
      case FieldType.date:
        return _DateInput(
          label: _label(f),
          initial: _values[f.key] as DateTime,
          onChanged: (d) => _values[f.key] = d,
        );
      case FieldType.parties:
        return _PartiesField(
          field: f,
          data: _values[f.key] as Map<String, dynamic>,
        );
    }
  }

  Widget _buildSection(FormSectionDef s) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              s.title.toUpperCase(),
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final f in s.fields) ...[
              _buildField(f),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  String _summary() {
    final b = StringBuffer();
    for (final s in widget.schema.sections) {
      for (final f in s.fields) {
        final v = _values[f.key];
        b.writeln('${f.label}:');
        if (f.type == FieldType.parties) {
          final m = v as Map<String, dynamic>;
          final list = m['parties'] as List;
          for (var i = 0; i < list.length; i++) {
            final p = list[i] as Map<String, String>;
            b.writeln(
              '  ${i + 1}. ${p['name']} ${p['relation']} ${p['father']}, ${p['caste']}, ${p['address']}',
            );
          }
          b.writeln('  Type: ${m['type']}');
        } else if (v is DateTime) {
          b.writeln('  ${formatDate(v)}');
        } else {
          b.writeln('  $v');
        }
        b.writeln();
      }
    }
    return b.toString();
  }

  void _preview() {
    if (!_formKey.currentState!.validate()) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Preview'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(child: Text(_summary())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _generate() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('DOCX generation: Step 6 mein banega')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(widget.schema.description),
          const SizedBox(height: 16),
          for (final s in widget.schema.sections) _buildSection(s),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _preview,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Preview Document'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.download),
                  label: const Text('Generate DOCX'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DateInput extends StatefulWidget {
  final String label;
  final DateTime initial;
  final ValueChanged<DateTime> onChanged;
  const _DateInput({
    required this.label,
    required this.initial,
    required this.onChanged,
  });

  @override
  State<_DateInput> createState() => _DateInputState();
}

class _DateInputState extends State<_DateInput> {
  late DateTime _date = widget.initial;
  late final TextEditingController _c = TextEditingController(
    text: formatDate(widget.initial),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() {
        _date = d;
        _c.text = formatDate(d);
      });
      widget.onChanged(d);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _c,
      readOnly: true,
      onTap: _pick,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
    );
  }
}

class _PartiesField extends StatefulWidget {
  final FormFieldDef field;
  final Map<String, dynamic> data;
  const _PartiesField({required this.field, required this.data});

  @override
  State<_PartiesField> createState() => _PartiesFieldState();
}

class _PartiesFieldState extends State<_PartiesField> {
  List get _parties => widget.data['parties'] as List;

  Widget _partyCard(int i, Map<String, String> p) {
    return Container(
      key: ObjectKey(p),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Party #${i + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_parties.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => _parties.removeAt(i)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: p['name'],
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: requiredValidator,
                  onChanged: (v) => p['name'] = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: p['relation'],
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'S/O', child: Text('S/O')),
                    DropdownMenuItem(value: 'D/O', child: Text('D/O')),
                    DropdownMenuItem(value: 'W/O', child: Text('W/O')),
                  ],
                  onChanged: (v) => p['relation'] = v ?? 'S/O',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: p['father'],
                  decoration: const InputDecoration(
                    labelText: 'Father/Husband Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: requiredValidator,
                  onChanged: (v) => p['father'] = v,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: p['caste'],
                  decoration: const InputDecoration(
                    labelText: 'Caste',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => p['caste'] = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: p['address'],
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Complete Address *',
              border: OutlineInputBorder(),
            ),
            validator: requiredValidator,
            onChanged: (v) => p['address'] = v,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _parties.length; i++)
          _partyCard(i, _parties[i] as Map<String, String>),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => setState(() => _parties.add(newParty())),
            icon: const Icon(Icons.add),
            label: const Text('Add Party'),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: widget.data['type'] as String,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: '${widget.field.typeLabel ?? 'Party Type'} *',
            border: const OutlineInputBorder(),
          ),
          items: [
            for (final o in widget.field.options)
              DropdownMenuItem(value: o, child: Text(o)),
          ],
          onChanged: (v) => widget.data['type'] = v,
        ),
      ],
    );
  }
}
