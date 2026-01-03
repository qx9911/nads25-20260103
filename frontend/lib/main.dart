import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load(); // 若你 env.dart 是 async
  runApp(const Nads25App());
}

class Nads25App extends StatelessWidget {
  const Nads25App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NADS25',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
      ),
      home: const AuthGate(), // ⭐ 關鍵：只交給 AuthGate
    );
  }
}
