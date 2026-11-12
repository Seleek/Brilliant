import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _configuredApiBaseUrl =
      String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_configuredApiBaseUrl.isNotEmpty) return _configuredApiBaseUrl;

    final host = Uri.base.host;
    if (host.isEmpty || host == 'localhost' || host == '127.0.0.1') {
      return 'http://localhost:8080/api';
    }

    return Uri(
      scheme: 'http',
      host: host,
      port: 8080,
      path: '/api',
    ).toString();
  }

  static String get baseUrl => '$apiBaseUrl/auth';

  String? _jwtToken;
  String? _currentUser;

  String? get currentUser => _currentUser;
  bool get isAuthenticated => _jwtToken != null;
  Map<String, String> get authenticatedHeaders {
    final token = _jwtToken;
    if (token == null) throw Exception('No autenticado');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> registrar(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Error al registrar usuario');
    }
  }

  Future<void> iniciarSesion(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      _jwtToken = body['token'];
      _currentUser = body['username'];
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Error al iniciar sesión');
    }
  }

  Future<void> borrarCuenta() async {
    if (_jwtToken == null) throw Exception('No autenticado');

    final response = await http.delete(
      Uri.parse('$baseUrl/delete-account'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_jwtToken',
      },
    );

    if (response.statusCode == 200) {
      _jwtToken = null;
      _currentUser = null;
    } else {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Error al borrar la cuenta');
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (_) {
      // Ignorar errores de red en logout si el servidor no responde
    } finally {
      _jwtToken = null;
      _currentUser = null;
    }
  }
}
