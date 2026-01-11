import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'models/password_model.dart';
import 'vault_provider.dart';

class AddPasswordScreen extends ConsumerStatefulWidget {
  const AddPasswordScreen({super.key});

  @override
  ConsumerState<AddPasswordScreen> createState() => _AddPasswordScreenState();
}

class _AddPasswordScreenState extends ConsumerState<AddPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: false, // Often useful to see it when adding
              ),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(labelText: 'URL'),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newPass = PasswordModel(
        id: const Uuid().v4(),
        title: _titleController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        url: _urlController.text,
        notes: _notesController.text,
      );

      ref.read(vaultProvider.notifier).addPassword(newPass);
      Navigator.pop(context);
    }
  }
}
