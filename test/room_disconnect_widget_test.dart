import 'package:brilliant/main.dart' show PantallaTablero;
import 'package:brilliant/src/datos/niveles.dart';
import 'package:brilliant/src/servicios/auth_service.dart';
import 'package:brilliant/src/servicios/room_service.dart';
import 'package:brilliant/src/ui/tablero_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pausa la interfaz y permite votar para continuar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = _RoomService(_salaPausada());

    await tester.pumpWidget(
      MaterialApp(
        home: PantallaTablero(
          nivel: construirNiveles().first,
          roomService: service,
          sala: service.sala,
          usuario: 'host',
        ),
      ),
    );

    expect(find.textContaining('guest se desconectó'), findsOneWidget);
    final casilla = tester.widget<CasillaTablero>(
      find.byKey(const ValueKey('celda_0_0')),
    );
    expect(casilla.onTap, isNull);

    await tester.tap(find.text('Continuar sin el jugador'));
    await tester.pumpAndSettle();

    expect(service.votoRegistrado, isTrue);
    expect(find.text('Voto registrado'), findsOneWidget);
    expect(find.byIcon(Icons.pan_tool), findsWidgets);
  });
}

class _RoomService extends RoomService {
  RoomSnapshot sala;
  bool votoRegistrado = false;

  _RoomService(this.sala) : super(AuthService());

  @override
  Future<RoomSnapshot> consultar(String code) async => sala;

  @override
  Future<RoomSnapshot> votarContinuarSinJugador(String code) async {
    votoRegistrado = true;
    sala = RoomSnapshot(
      code: sala.code,
      level: sala.level,
      host: sala.host,
      phase: sala.phase,
      round: sala.round,
      dice: sala.dice,
      players: sala.players
          .map(
            (player) => RoomPlayer(
              username: player.username,
              ready: player.ready,
              submitted: player.submitted,
              score: player.score,
              connected: player.connected,
              eliminated: player.eliminated,
              votedToContinue:
                  player.username == 'host' || player.votedToContinue,
            ),
          )
          .toList(),
      allReady: sala.allReady,
      allSubmitted: sala.allSubmitted,
      cells: sala.cells,
      scores: sala.scores,
      paused: sala.paused,
      disconnectedUsername: sala.disconnectedUsername,
      pauseDeadline: sala.pauseDeadline,
      winner: sala.winner,
    );
    return sala;
  }
}

RoomSnapshot _salaPausada() => RoomSnapshot(
      code: 'ABC123',
      level: 1,
      host: 'host',
      phase: 'partida',
      round: 1,
      dice: const [2, 4],
      players: const [
        RoomPlayer(
          username: 'host',
          ready: true,
          submitted: false,
          score: 0,
          connected: true,
          eliminated: false,
          votedToContinue: false,
        ),
        RoomPlayer(
          username: 'guest',
          ready: true,
          submitted: false,
          score: 3,
          connected: false,
          eliminated: false,
          votedToContinue: false,
        ),
      ],
      allReady: true,
      allSubmitted: false,
      cells: List<dynamic>.filled(49, null),
      scores: const {'host': 0, 'guest': 3},
      paused: true,
      disconnectedUsername: 'guest',
      pauseDeadline: null,
      winner: null,
    );
