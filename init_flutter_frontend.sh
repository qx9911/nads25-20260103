#!/usr/bin/env bash
set -e

APP_NAME="frontend"
LIB_DIR="$APP_NAME/lib"

echo "📁 Creating Flutter frontend structure..."

mkdir -p $LIB_DIR/services
mkdir -p $LIB_DIR/pages
mkdir -p $LIB_DIR/widgets

# ---------------------------
# pubspec.yaml
# ---------------------------
cat > $APP_NAME/pubspec.yaml << 'EOF'
name: nads25_frontend
description: NADS25 Flutter Web
publish_to: "none"

environment:
  sdk: ">=3.2.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  flutter_secure_storage: ^9.0.0

flutter:
  uses-material-design: true
EOF

# ---------------------------
# lib/env.dart
# ---------------------------
cat > $LIB_DIR/env.dart << 'EOF'
const String API_BASE = "http://localhost:20010/api";
EOF

# ---------------------------
# lib/main.dart
# ---------------------------
cat > $LIB_DIR/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'pages/loading_page.dart';

void main() {
  runApp(const NADS25App());
}

class NADS25App extends StatelessWidget {
  const NADS25App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingPage(),
    );
  }
}
EOF

# ---------------------------
# services/auth_service.dart
# ---------------------------
cat > $LIB_DIR/services/auth_service.dart << 'EOF'
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../env.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();

  static Future<bool> login(String username, String password) async {
    final res = await http.post(
      Uri.parse("$API_BASE/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (res.statusCode != 200) return false;

    final data = jsonDecode(res.body);
    await _storage.write(key: "access_token", value: data["access_token"]);
    return true;
  }

  static Future<Map<String, dynamic>?> me() async {
    final token = await _storage.read(key: "access_token");
    if (token == null) return null;

    final res = await http.get(
      Uri.parse("$API_BASE/auth/me"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) return null;
    return jsonDecode(res.body)["user"];
  }

  static Future<void> logout() async {
    await _storage.delete(key: "access_token");
  }
}
EOF

# ---------------------------
# pages/loading_page.dart
# ---------------------------
cat > $LIB_DIR/pages/loading_page.dart << 'EOF'
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'admin_home.dart';
import 'user_home.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final user = await AuthService.me();

    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    if (user["role"] == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHome()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserHome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
EOF

# ---------------------------
# pages/login_page.dart
# ---------------------------
cat > $LIB_DIR/pages/login_page.dart << 'EOF'
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'admin_home.dart';
import 'user_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  Future<void> _login() async {
    final ok = await AuthService.login(
      _username.text,
      _password.text,
    );

    if (!ok) {
      setState(() => _error = "登入失敗");
      return;
    }

    final user = await AuthService.me();
    if (user == null) return;

    if (user["role"] == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHome()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserHome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("NADS25 Login", style: TextStyle(fontSize: 24)),
              TextField(
                controller: _username,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              TextField(
                controller: _password,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _login, child: const Text("Login")),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
EOF

# ---------------------------
# pages/admin_home.dart
# ---------------------------
cat > $LIB_DIR/pages/admin_home.dart << 'EOF'
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          )
        ],
      ),
      body: const Center(child: Text("Welcome Admin")),
    );
  }
}
EOF

# ---------------------------
# pages/user_home.dart
# ---------------------------
cat > $LIB_DIR/pages/user_home.dart << 'EOF'
import 'package:flutter/material.dart';

class UserHome extends StatelessWidget {
  const UserHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("User Home")),
    );
  }
}
EOF

echo "✅ Flutter frontend skeleton created in ./$APP_NAME"
echo "👉 Next steps:"
echo "   cd frontend"
echo "   flutter pub get"
echo "   flutter run -d web-server --web-port=20011 --web-hostname=0.0.0.0"
echo ""
echo "🌐 Open in browser:"
echo "   http://localhost:20011"
