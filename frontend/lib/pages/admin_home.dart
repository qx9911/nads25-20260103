import 'package:flutter/material.dart';
import '../widgets/top_bar.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopBar(),
      body: Center(
        child: Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
