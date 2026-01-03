import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/top_bar.dart';
import '../widgets/left_bar.dart';
import '../widgets/foot_bar.dart';

class UserManagePage extends StatefulWidget {
  const UserManagePage({super.key});

  @override
  State<UserManagePage> createState() => _UserManagePageState();
}

class _UserManagePageState extends State<UserManagePage> {
  bool loading = true;
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => loading = true);

    try {
      final res = await AuthService.authGet('/api/users');

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        users = List<Map<String, dynamic>>.from(data);
      } else {
        users = [];
      }
    } catch (_) {
      users = [];
    }

    setState(() => loading = false);
  }

  void _openEdit(Map<String, dynamic> user) {
    Navigator.pushNamed(
      context,
      '/user-edit',
      arguments: user,
    ).then((_) => _loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: Row(
              children: [
                const LeftBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: loading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '使用者管理',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: users.isEmpty
                                    ? const Center(
                                        child: Text(
                                          '目前沒有可顯示的使用者資料',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        child: DataTable(
                                          columns: const [
                                            DataColumn(label: Text('帳號')),
                                            DataColumn(label: Text('姓名')),
                                            DataColumn(label: Text('角色')),
                                            DataColumn(label: Text('狀態')),
                                            DataColumn(label: Text('操作')),
                                          ],
                                          rows: users.map((u) {
                                            final active =
                                                u['is_active'] == true;
                                            return DataRow(cells: [
                                              DataCell(Text(u['username'] ?? '')),
                                              DataCell(Text(u['name'] ?? '')),
                                              DataCell(Text(u['role'] ?? '')),
                                              DataCell(Text(
                                                active ? '啟用' : '停用',
                                                style: TextStyle(
                                                  color: active
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              )),
                                              DataCell(
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      _openEdit(u),
                                                  child: const Text('編輯'),
                                                ),
                                              ),
                                            ]);
                                          }).toList(),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
          const FootBar(),
        ],
      ),
    );
  }
}
