import 'dart:html' as html;

class AuthService {
  static const String apiBase = 'http://192.168.16.240:20010';

  static void setSession({
    required String token,
  }) {
    html.window.localStorage['access_token'] = token;
  }

  static Future<String?> getToken() async {
    return html.window.localStorage['access_token'];
  }

  static Future<void> logout() async {
    html.window.localStorage.remove('access_token');
  }

  static bool isLoggedIn() {
    return html.window.localStorage.containsKey('access_token');
  }
}
