import 'package:flutter/material.dart';

class AddEmergencyContactDialog extends StatefulWidget {
  const AddEmergencyContactDialog({super.key});

  @override
  State<AddEmergencyContactDialog> createState() =>
      _AddEmergencyContactDialogState();
}

class _AddEmergencyContactDialogState extends State<AddEmergencyContactDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _contact = '';
  String _description = '';
  IconData _icon = Icons.local_hospital;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Emergency Contact'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter a name' : null,
                onSaved: (v) => _title = v ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter a phone number' : null,
                onSaved: (v) => _contact = v ?? '',
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (v) => _description = v ?? '',
              ),
              DropdownButtonFormField<IconData>(
                value: _icon,
                decoration: const InputDecoration(labelText: 'Icon'),
                items: const [
                  DropdownMenuItem(
                    value: Icons.local_hospital,
                    child: Text('Hospital'),
                  ),
                  DropdownMenuItem(value: Icons.person, child: Text('Person')),
                  DropdownMenuItem(value: Icons.phone, child: Text('Phone')),
                ],
                onChanged: (v) =>
                    setState(() => _icon = v ?? Icons.local_hospital),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _formKey.currentState?.save();
              Navigator.of(context).pop({
                'title': _title,
                'contact': _contact,
                'icon': _icon,
                'description': _description,
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
