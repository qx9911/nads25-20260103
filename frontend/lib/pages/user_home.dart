import 'package:flutter/material.dart';

class UserHome extends StatelessWidget {
  final String user;

  const UserHome({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NADS25 User')),
      body: Center(
        child: Text(
          'User Home\nUser: $user',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
