import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:password_manager/features/ui/techno_background.dart';
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

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label.toUpperCase(),
      prefixIcon: Icon(icon),
      labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.5), letterSpacing: 2, fontSize: 12),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: const Color(0xFF00FFC2).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00FFC2), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  TextStyle get _inputStyle => const TextStyle(
        color: Color(0xFF00FFC2),
        fontFamily: 'Courier',
        fontWeight: FontWeight.bold,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('NEW ENTRY'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: TechnoBackground(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  style: _inputStyle,
                  cursorColor: const Color(0xFFD600FF),
                  decoration:
                      _buildInputDecoration('Title', Icons.label_outline),
                  validator: (v) => v!.isEmpty ? 'FIELD REQUIRED' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  style: _inputStyle,
                  cursorColor: const Color(0xFFD600FF),
                  decoration:
                      _buildInputDecoration('Username', Icons.person_outline),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  style: _inputStyle,
                  cursorColor: const Color(0xFFD600FF),
                  decoration:
                      _buildInputDecoration('Password', Icons.vpn_key_outlined),
                  obscureText: false,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _urlController,
                  style: _inputStyle,
                  cursorColor: const Color(0xFFD600FF),
                  decoration: _buildInputDecoration('URL / Host', Icons.link),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  style: _inputStyle,
                  cursorColor: const Color(0xFFD600FF),
                  decoration: _buildInputDecoration(
                      'Secure Notes', Icons.note_outlined),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FFC2),
                      foregroundColor: const Color(0xFF050510),
                      elevation: 20,
                      shadowColor: const Color(0xFF00FFC2),
                    ),
                    child: const Text('ENCRYPT & SAVE',
                        style: TextStyle(letterSpacing: 2)),
                  ),
                ),
              ],
            ),
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
