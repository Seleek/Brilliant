import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class RoomPlayer {
  final String username;
  final bool ready;
  final bool submitted;
  final int score;

  const RoomPlayer({
    required this.username,
    required this.ready,
    required this.submitted,
    required this.score,
  });

  factory RoomPlayer.fromJson(Map<String, dynamic> json) => RoomPlayer(
        username: json['username'] as String,
        ready: json['ready'] == true,
        submitted: json['submitted'] == true,
        score: json['score'] as int? ?? 0,
      );
}

class RoomSnapshot {
  final String code;
  final int level;
  final String host;
  final String phase;
  final int round;
  final List<int> dice;
  final List<RoomPlayer> players;
  final bool allReady;
  final bool allSubmitted;
  final List<dynamic> cells;
  final Map<String, int> scores;

  const RoomSnapshot({
    required this.code,
    required this.level,
    required this.host,
    required this.phase,
    required this.round,
    required this.dice,
    required this.players,
    required this.allReady,
    required this.allSubmitted,
    required this.cells,
    required this.scores,
  });

  factory RoomSnapshot.fromJson(Map<String, dynamic> json) => RoomSnapshot(
        code: json['code'] as String,
        level: json['level'] as int,
        host: json['host'] as String,
        phase: json['phase'] as String,
        round: json['round'] as int? ?? 0,
        dice: (json['dice'] as List<dynamic>? ?? const [])
            .map((value) => value as int)
            .toList(),
        players: (json['players'] as List<dynamic>? ?? const [])
            .map(
              (player) => RoomPlayer.fromJson(
                Map<String, dynamic>.from(player as Map),
              ),
            )
            .toList(),
        allReady: json['allReady'] == true,
        allSubmitted: json['allSubmitted'] == true,
        cells: List<dynamic>.from(json['cells'] as List<dynamic>? ?? const []),
        scores: (json['scores'] as Map<String, dynamic>? ?? const {})
            .map((key, value) => MapEntry(key, value as int)),
      );

  RoomPlayer? player(String username) {
    for (final player in players) {
      if (player.username == username) return player;
    }
    return null;
  }
}

class RoomService {
  static const String _baseUrl = '${AuthService.apiBaseUrl}/rooms';
  final AuthService _authService;

  RoomService(this._authService);

  Future<RoomSnapshot> crearSala(int level) =>
      _post('/create', {'level': level});

  Future<RoomSnapshot> unirse(String code) => _post('/join', {'code': code});

  Future<RoomSnapshot> consultar(String code) =>
      _get('/${Uri.encodeComponent(code)}');

  Future<RoomSnapshot> marcarListo(String code, List<int?> cells) =>
      _post('/${Uri.encodeComponent(code)}/ready', {'cells': cells});

  Future<RoomSnapshot> iniciar(String code) =>
      _post('/${Uri.encodeComponent(code)}/start', const {});

  Future<RoomSnapshot> enviarJugada(
    String code, {
    required List<int?> cells,
    required bool passed,
    int? selectedDie,
  }) =>
      _post('/${Uri.encodeComponent(code)}/move', {
        'cells': cells,
        'passed': passed,
        'selectedDie': selectedDie,
      });

  Future<void> salir(String code) async {
    final response =
        await _request('POST', '/${Uri.encodeComponent(code)}/leave', const {});
    final body = _parseBody(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['error'] ?? 'No se pudo salir de la sala');
    }
  }

  Future<RoomSnapshot> _get(String path) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: _authService.authenticatedHeaders,
    );
    return _parseSnapshot(response);
  }

  Future<RoomSnapshot> _post(String path, Map<String, dynamic> body) async {
    final response = await _request('POST', path, body);
    return _parseSnapshot(response);
  }

  Future<http.Response> _request(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = _authService.authenticatedHeaders;
    switch (method) {
      case 'POST':
        return http.post(uri, headers: headers, body: jsonEncode(body));
      default:
        throw ArgumentError.value(method, 'method', 'Método no compatible');
    }
  }

  RoomSnapshot _parseSnapshot(http.Response response) {
    final body = _parseBody(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(body['error'] ?? 'Error de sala');
    }
    return RoomSnapshot.fromJson(body);
  }

  Map<String, dynamic> _parseBody(http.Response response) {
    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw Exception('El servidor devolvió una respuesta inválida');
    }
    if (decoded is! Map<String, dynamic>) {
      throw Exception('El servidor devolvió una respuesta inválida');
    }
    return decoded;
  }
}
