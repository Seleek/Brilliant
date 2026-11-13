import 'dart:convert';

import 'package:http/http.dart' as http;

import 'server_discovery_stub.dart'
    if (dart.library.io) 'server_discovery_io.dart' as server_discovery;

class AuthService {
  static const String _configuredApiBaseUrl =
      String.fromEnvironment('API_BASE_URL');
  static const int _apiPort = 8080;
  static String? _discoveredHost;
  static Future<void>? _discovery;

  static String get apiBaseUrl {
    if (_configuredApiBaseUrl.isNotEmpty) return _configuredApiBaseUrl;

    final discoveredHost = _discoveredHost;
    if (discoveredHost != null) {
      return Uri(
        scheme: 'http',
        host: discoveredHost,
        port: _apiPort,
        path: '/api',
      ).toString();
    }

    final host = Uri.base.host;
    if (host.isEmpty ||
        host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '::1') {
      return 'http://localhost:$_apiPort/api';
    }

    return Uri(
      scheme: 'http',
      host: host,
      port: _apiPort,
      path: '/api',
    ).toString();
  }

  static String get baseUrl => '$apiBaseUrl/auth';

  static Future<void> prepareApiConnection() async {
    if (_configuredApiBaseUrl.isNotEmpty ||
        !server_discovery.serverDiscoverySupported) {
      return;
    }

    final host = Uri.base.host;
    if (host.isNotEmpty &&
        host != 'localhost' &&
        host != '127.0.0.1' &&
        host != '::1') {
      return;
    }
    if (_discoveredHost != null) return;

    final discovery = _discovery ??= _findServer();
    await discovery;
  }

  static Future<void> _findServer() async {
    try {
      final host = await server_discovery.discoverServerHost(
        port: _apiPort,
        timeout: const Duration(seconds: 2),
      );
      if (host == null) {
        throw Exception(
          'No se encontró el servidor Brilliant en la red local. '
          'Verifica que esté encendido y que el firewall permita UDP 8080.',
        );
      }
      _discoveredHost = host;
    } finally {
      _discovery = null;
    }
  }

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
    await prepareApiConnection();
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
    await prepareApiConnection();
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
    await prepareApiConnection();

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
