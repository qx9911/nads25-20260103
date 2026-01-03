import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/top_bar.dart';
import '../widgets/left_bar.dart';
import '../widgets/foot_bar.dart';

class UserEditPage extends StatefulWidget {
  final Map<String, dynamic>? user; // null = 新增

  const UserEditPage({super.key, this.user});

  @override
  State<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;

  String _role = 'user';
  bool _isActive = true;
  bool _saving = false;

  static const String apiBase = 'http://localhost:20010/api';

  bool get isEdit => widget.user != null;

  @override
  void initState() {
    super.initState();
    _usernameCtrl =
        TextEditingController(text: widget.user?['username'] ?? '');
    _nameCtrl = TextEditingController(text: widget.user?['name'] ?? '');
    _emailCtrl = TextEditingController(text: widget.user?['email'] ?? '');
    _passwordCtrl = TextEditingController();
    _role = widget.user?['role'] ?? 'user';
    _isActive = widget.user?['is_active'] == 0 ? false : true;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final token = html.window.localStorage['access_token'];
    if (token == null) return;

    final body = {
      'username': _usernameCtrl.text.trim(),
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'role': _role,
      'is_active': _isActive ? 1 : 0,
    };

    if (!isEdit) {
      body['password'] = _passwordCtrl.text;
    }

    final uri = isEdit
        ? Uri.parse('$apiBase/users/${widget.user!['id']}')
        : Uri.parse('$apiBase/users');

    final res = await (isEdit
        ? http.put(uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body))
        : http.post(uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body)));

    setState(() => _saving = false);

    if (res.statusCode == 200 || res.statusCode == 201) {
      if (context.mounted) {
        Navigator.of(context).pop(true); // 回傳成功
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('儲存失敗 (${res.statusCode})')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopBar(),
      body: Row(
        children: [
          LeftBar(),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          Text(
                            isEdit ? '編輯使用者' : '新增使用者',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          _field(_usernameCtrl, '帳號', enabled: !isEdit),
                          _field(_nameCtrl, '姓名'),
                          _field(_emailCtrl, 'Email'),

                          if (!isEdit)
                            _field(_passwordCtrl, '密碼',
                                obscure: true, required: true),

                          const SizedBox(height: 12),

                          DropdownButtonFormField<String>(
                            value: _role,
                            items: const [
                              DropdownMenuItem(
                                  value: 'admin', child: Text('Admin')),
                              DropdownMenuItem(
                                  value: 'user', child: Text('User')),
                            ],
                            onChanged: (v) => setState(() => _role = v!),
                            decoration:
                                const InputDecoration(labelText: '角色'),
                          ),

                          SwitchListTile(
                            title: const Text('啟用帳號'),
                            value: _isActive,
                            onChanged: (v) => setState(() => _isActive = v),
                          ),

                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: _saving ? null : _submit,
                            child: Text(_saving ? '儲存中...' : '儲存'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                FootBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {bool obscure = false, bool required = true, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        enabled: enabled,
        obscureText: obscure,
        validator: (v) =>
            required && (v == null || v.isEmpty) ? '必填' : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
