import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class UserManagePage extends StatefulWidget {
  const UserManagePage({super.key});

  @override
  State<UserManagePage> createState() => _UserManagePageState();
}

class _UserManagePageState extends State<UserManagePage> {
  bool loading = true;
  String error = '';
  List users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final token = await AuthService.getToken();
    if (token == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    try {
      final res = await http.get(
        Uri.parse('${AuthService.apiBase}/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          users = data['users'];
          loading = false;
        });
      } else if (res.statusCode == 401) {
        await AuthService.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        setState(() {
          error = 'HTTP ${res.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(child: Text(error));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, i) {
        final u = users[i];
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(u['username']),
          subtitle: Text(u['role']),
          trailing: Icon(
            u['is_active'] ? Icons.check_circle : Icons.block,
            color: u['is_active'] ? Colors.green : Colors.red,
          ),
        );
      },
    );
  }
}
