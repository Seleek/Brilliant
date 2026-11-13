import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'brilliant.dart';
import 'src/datos/niveles.dart';
import 'src/ui/pantalla_seleccion_nivel.dart';
import 'src/ui/reglas_nivel_widget.dart';
import 'src/servicios/auth_service.dart';
import 'src/servicios/room_service.dart';
import 'src/ui/pantalla_auth.dart';
import 'src/ui/pantalla_sala.dart';

void main() {
  runApp(const BrilliantApp());
}

class BrilliantApp extends StatefulWidget {
  final Random? random;
  const BrilliantApp({super.key, this.random});

  @override
  State<BrilliantApp> createState() => _BrilliantAppState();
}

class _BrilliantAppState extends State<BrilliantApp> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brilliant',
      // Decidimos qué pantalla mostrar basándonos en si el usuario ya se autenticó
      home: _authService.isAuthenticated
          ? PantallaInicio(
              random: widget.random,
              authService: _authService,
              onLogout: () => setState(() {}),
            )
          : PantallaAuth(
              authService: _authService,
              onLoginExitoso: () => setState(() {}),
            ),
    );
  }
}

class PantallaInicio extends StatelessWidget {
  final Random? random;
  final AuthService authService;
  final VoidCallback onLogout;

  const PantallaInicio({
    super.key,
    this.random,
    required this.authService,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return PantallaSeleccionNivel(
      authService: authService,
      onLogout: onLogout,
      onMultijugador: () {
        final roomService = RoomService(authService);
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (salaContext) => PantallaSala(
              roomService: roomService,
              onSalaConectada: (sala) => Navigator.of(salaContext).push(
                MaterialPageRoute<void>(
                  builder: (_) => PantallaLobby(
                    roomService: roomService,
                    sala: sala,
                    usuario: authService.currentUser!,
                    random: random,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      onNivelElegido: (numeroNivel) {
        // Obtenemos todos los niveles de la lógica del juego
        final listaDeNiveles = construirNiveles();

        // Asociamos el botón presionado (1 al 4) con el índice de la lista (0 al 3)
        final index = (numeroNivel - 1).clamp(0, listaDeNiveles.length - 1);
        final nivelElegido = listaDeNiveles[index];

        // Ejecutamos la navegación para abrir el tablero de juego
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PantallaTablero(
              nivel: nivelElegido,
              random: random,
            ),
          ),
        );
      },
    );
  }
}

class PantallaTablero extends StatefulWidget {
  final Nivel nivel;

  final Random? random;
  final RoomService? roomService;
  final RoomSnapshot? sala;
  final String? usuario;
  final bool preparandoSala;

  const PantallaTablero({
    super.key,
    required this.nivel,
    this.random,
    this.roomService,
    this.sala,
    this.usuario,
    this.preparandoSala = false,
  });

  @override
  State<PantallaTablero> createState() => _PantallaTableroState();
}

class _PantallaTableroState extends State<PantallaTablero> {
  late final TableroBloc _bloc;
  Timer? _timerSala;
  Timer? _timerCuentaPausa;
  bool _enviandoJugada = false;
  bool _votandoContinuar = false;
  bool _forzarSincronizacion = false;
  bool _salidaConfirmada = false;
  DateTime _relojPausa = DateTime.now();
  String? _errorSala;
  RoomSnapshot? _salaActual;

  @override
  void initState() {
    super.initState();

    _bloc = TableroBloc(
      Tablero.vacio(
        const {},
        tipoPorPosicion: widget.nivel.tipoPorPosicion,
        coloresUnificados: widget.nivel.coloresUnificados,
        divisionesPorColumna: widget.nivel.divisionesPorColumna,
        divisionesPorFila: widget.nivel.divisionesPorFila,
        posicionesIniciales: widget.nivel.posicionesIniciales,
      ),
      numerosEnMano: const [1, 2, 3, 4, 5, 6],
      random: widget.random,
      dadosCompartidos: widget.roomService != null && !widget.preparandoSala,
    );
    if (widget.sala != null) _aplicarSala(widget.sala!);
    if (widget.roomService != null && !widget.preparandoSala) {
      _timerSala = Timer.periodic(
        const Duration(seconds: 2),
        (_) => _actualizarSala(),
      );
    }
  }

  @override
  void dispose() {
    _bloc.dispose();
    _timerSala?.cancel();
    _timerCuentaPausa?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: AppBar(title: Text('Brilliant — ${widget.nivel.nombre}')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dimensionDisponible =
                min(constraints.maxWidth, constraints.maxHeight) - 32;
            final anchoTablero =
                dimensionDisponible.clamp(0.0, 420.0).toDouble();
            final juegoBloqueado = widget.roomService != null &&
                !widget.preparandoSala &&
                (_salaActual?.paused != false ||
                    _salaActual?.phase != 'partida' ||
                    _salaActual?.player(widget.usuario ?? '')?.eliminated ==
                        true);
            final tablero = SizedBox(
              key: const ValueKey('tablero-responsive'),
              width: anchoTablero,
              child: TableroWidget(
                bloc: _bloc,
                tipoPorPosicion: widget.nivel.tipoPorPosicion,
                interactivo: !juegoBloqueado,
              ),
            );

            final panel = StreamBuilder<TableroEstado>(
              stream: _bloc.estado,
              initialData: _bloc.estadoActual,
              builder: (context, snapshot) {
                final estado = snapshot.data!;

                final enTurnos = estado.partidaIniciada;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.roomService != null &&
                        !widget.preparandoSala &&
                        _salaActual != null) ...[
                      const Text(
                        'Puntajes de la sala',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final jugador in _salaActual!.players)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              avatar: Icon(
                                !jugador.connected || jugador.eliminated
                                    ? Icons.wifi_off
                                    : jugador.submitted
                                        ? Icons.check_circle
                                        : Icons.person_outline,
                                size: 16,
                              ),
                              label: Text(
                                '${jugador.username}: ${jugador.score}'
                                '${jugador.eliminated || !jugador.connected ? ' · Desconectado' : ''}',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    PanelDados(
                      dados: estado.dados,
                      turno: estado.turno,
                      puntaje: estado.puntajeTotal,
                      indiceSeleccionado: estado.indiceDadoSeleccionado,
                      onDadoTocado: !juegoBloqueado &&
                              enTurnos &&
                              !estado.jugadaEnviada &&
                              !_enviandoJugada
                          ? (indice) => _bloc.agregar(SeleccionarDado(indice))
                          : null,
                    ),
                    const SizedBox(height: 16),
                    PanelMano(
                      numerosEnMano: estado.numerosEnMano,
                      mostrarNumeros: !enTurnos,
                      numerosHabilitados: !enTurnos,
                      indiceSeleccionado:
                          enTurnos ? null : estado.indiceNumeroSeleccionado,
                      onNumeroTocado: juegoBloqueado
                          ? null
                          : (indice) =>
                              _bloc.agregar(SeleccionarNumeroDeMano(indice)),
                      onColocarFicha: !juegoBloqueado &&
                              (!enTurnos || estado.puedeColocarFichaDelTurno) &&
                              !_enviandoJugada
                          ? widget.roomService != null &&
                                  !widget.preparandoSala &&
                                  enTurnos
                              ? () => _enviarJugada(pasada: false)
                              : () => _bloc.agregar(ColocarFicha())
                          : null,
                      onPasar: !juegoBloqueado &&
                              enTurnos &&
                              !estado.jugadaEnviada &&
                              !_enviandoJugada
                          ? widget.roomService != null
                              ? () => _enviarJugada(pasada: true)
                              : () => _bloc.agregar(PasarTurno())
                          : null,
                    ),
                  ],
                );
              },
            );

            final boton = _controlesInferiores();

            final esAncho = constraints.maxWidth >= 820;

            if (esAncho) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (_mostrarEstadoSala) ...[
                      _panelEstadoSala(),
                      const SizedBox(height: 12),
                    ],
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          tablero,
                          const SizedBox(width: 24),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 320),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ReglasNivelWidget(
                                        nivel: widget.nivel,
                                      ),
                                      const SizedBox(height: 16),
                                      panel,
                                      const SizedBox(height: 16),
                                      boton,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    if (_mostrarEstadoSala) ...[
                      SizedBox(
                        width: anchoTablero,
                        child: _panelEstadoSala(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    tablero,
                    const SizedBox(height: 16),
                    SizedBox(
                      width: anchoTablero,
                      child: ReglasNivelWidget(
                        nivel: widget.nivel,
                        expandible: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    panel,
                    const SizedBox(height: 16),
                    boton,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );

    return StreamBuilder<TableroEstado>(
      stream: _bloc.estado,
      initialData: _bloc.estadoActual,
      builder: (context, snapshot) {
        final partidaActiva = widget.roomService != null
            ? !widget.preparandoSala && _salaActual?.phase == 'partida'
            : snapshot.data!.partidaIniciada;
        return PopScope<void>(
          canPop: !partidaActiva || _salidaConfirmada,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _confirmarSalida(partidaActiva);
          },
          child: scaffold,
        );
      },
    );
  }

  Future<void> _confirmarSalida(bool partidaActiva) async {
    if (!partidaActiva) return;

    final salir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir de la partida?'),
        content: const Text(
          'Si sales ahora, perderás el progreso de esta partida.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Seguir jugando'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (salir == true && mounted) {
      setState(() => _salidaConfirmada = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  bool get _mostrarEstadoSala =>
      widget.roomService != null &&
      (_salaActual?.paused == true ||
          _salaActual?.phase == 'finalizada' ||
          _salaActual?.player(widget.usuario ?? '')?.eliminated == true);

  Widget _panelEstadoSala() {
    final sala = _salaActual!;
    final theme = Theme.of(context);
    final jugador = sala.player(widget.usuario ?? '');
    final Color color;
    final String mensaje;

    if (sala.phase == 'finalizada') {
      color = Colors.green.shade100;
      mensaje = sala.winner == null
          ? 'La partida terminó.'
          : sala.winner == widget.usuario
              ? '¡Ganaste! La partida terminó.'
              : 'La partida terminó. Ganó ${sala.winner}.';
    } else if (jugador?.eliminated == true) {
      color = Colors.red.shade100;
      mensaje = 'Quedaste desconectado y no puedes volver a esta partida.';
    } else {
      color = Colors.amber.shade100;
      final limite = sala.pauseDeadline;
      final restante =
          limite == null ? Duration.zero : limite.difference(_relojPausa);
      final segundos = restante.inSeconds.clamp(0, 5 * 60);
      final minutosTexto = (segundos ~/ 60).toString().padLeft(2, '0');
      final segundosTexto = (segundos % 60).toString().padLeft(2, '0');
      mensaje = '${sala.disconnectedUsername} se desconectó. '
          'La partida está pausada. Tiempo de espera: '
          '$minutosTexto:$segundosTexto.';
    }

    final votantes = sala.players
        .where(
          (player) =>
              player.connected &&
              !player.eliminated &&
              player.username != sala.disconnectedUsername,
        )
        .toList();
    final puedeVotar = sala.paused &&
        jugador != null &&
        jugador.connected &&
        !jugador.eliminated &&
        jugador.username != sala.disconnectedUsername;

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(mensaje, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (sala.paused) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final votante in votantes)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: Icon(
                        votante.votedToContinue
                            ? Icons.pan_tool
                            : Icons.person_outline,
                        size: 16,
                        color: votante.votedToContinue
                            ? theme.colorScheme.primary
                            : null,
                      ),
                      label: Text(votante.username),
                    ),
                ],
              ),
              if (puedeVotar) ...[
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _votandoContinuar || jugador.votedToContinue
                      ? null
                      : _votarContinuarSinJugador,
                  icon: const Icon(Icons.pan_tool),
                  label: Text(
                    jugador.votedToContinue
                        ? 'Voto registrado'
                        : 'Continuar sin el jugador',
                  ),
                ),
              ],
            ],
            if (_errorSala != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorSala!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _votarContinuarSinJugador() async {
    final sala = _salaActual;
    if (sala == null || _votandoContinuar) return;
    setState(() {
      _votandoContinuar = true;
      _errorSala = null;
    });
    try {
      _aplicarSala(
        await widget.roomService!.votarContinuarSinJugador(sala.code),
      );
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) setState(() => _errorSala = error.toString());
    } finally {
      if (mounted) setState(() => _votandoContinuar = false);
    }
  }

  Widget _controlesInferiores() {
    if (widget.roomService == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: BotonIniciar(bloc: _bloc),
      );
    }

    if (widget.preparandoSala) {
      return StreamBuilder<TableroEstado>(
        stream: _bloc.estado,
        initialData: _bloc.estadoActual,
        builder: (context, snapshot) {
          final estado = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: estado.puedeIniciarPartida && !_enviandoJugada
                    ? _marcarListo
                    : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Guardar tablero y marcarme listo'),
              ),
              if (!estado.puedeIniciarPartida)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Completa las seis casillas iniciales con números diferentes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              if (_enviandoJugada)
                const Center(child: CircularProgressIndicator()),
              if (_errorSala != null) _mensajeErrorSala(),
            ],
          );
        },
      );
    }

    return StreamBuilder<TableroEstado>(
      stream: _bloc.estado,
      initialData: _bloc.estadoActual,
      builder: (context, snapshot) {
        final estado = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _salaActual?.paused == true
                  ? 'Partida pausada.'
                  : _salaActual?.phase == 'finalizada'
                      ? 'Partida finalizada.'
                      : estado.jugadaEnviada
                          ? 'Jugada enviada. Esperando a los demás…'
                          : 'Ronda ${estado.turno}: elige un dado y juega.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (_enviandoJugada)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_errorSala != null) _mensajeErrorSala(),
          ],
        );
      },
    );
  }

  Widget _mensajeErrorSala() => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          _errorSala!,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );

  Future<void> _marcarListo() async {
    final service = widget.roomService!;
    final sala = _salaActual;
    if (sala == null) return;
    setState(() {
      _enviandoJugada = true;
      _errorSala = null;
    });
    try {
      await service.marcarListo(sala.code, _bloc.valoresCeldas);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _errorSala = error.toString());
    } finally {
      if (mounted) setState(() => _enviandoJugada = false);
    }
  }

  Future<void> _enviarJugada({required bool pasada}) async {
    final service = widget.roomService!;
    final sala = _salaActual;
    if (sala == null || _enviandoJugada) return;
    if (sala.paused ||
        sala.phase != 'partida' ||
        sala.player(widget.usuario ?? '')?.eliminated == true) {
      return;
    }
    final dadoSeleccionado = _bloc.estadoActual.indiceDadoSeleccionado;
    _bloc.agregar(pasada ? PasarTurno() : ColocarFicha());
    final estado = _bloc.estadoActual;
    if (estado.mensajeError != null) {
      setState(() => _errorSala = estado.mensajeError);
      return;
    }
    setState(() {
      _enviandoJugada = true;
      _errorSala = null;
    });
    try {
      final respuesta = await service.enviarJugada(
        sala.code,
        cells: _bloc.valoresCeldas,
        passed: pasada,
        selectedDie: dadoSeleccionado,
      );
      if (mounted) _aplicarSala(respuesta);
    } catch (error) {
      if (mounted) {
        setState(() => _errorSala = error.toString());
        _forzarSincronizacion = true;
        try {
          final actualizada = await service.consultar(sala.code);
          if (mounted) {
            _aplicarSala(actualizada);
          }
        } catch (errorSincronizacion) {
          if (mounted) {
            setState(() => _errorSala =
                '$error. No se pudo recuperar el estado: $errorSincronizacion');
          }
        }
      }
    } finally {
      if (mounted) setState(() => _enviandoJugada = false);
    }
  }

  Future<void> _actualizarSala() async {
    final service = widget.roomService;
    final sala = _salaActual;
    if (service == null || sala == null || _enviandoJugada) return;
    try {
      final actualizada = await service.consultar(sala.code);
      if (mounted) {
        _aplicarSala(actualizada);
        setState(() => _errorSala = null);
      }
    } catch (error) {
      if (mounted) setState(() => _errorSala = error.toString());
    }
  }

  void _aplicarSala(RoomSnapshot sala) {
    _actualizarRelojPausa(sala);
    final jugador = sala.player(widget.usuario ?? '');
    final anterior = _salaActual;
    final cambioTablero = _forzarSincronizacion ||
        anterior == null ||
        anterior.phase != sala.phase ||
        anterior.round != sala.round ||
        anterior.dice.toString() != sala.dice.toString() ||
        anterior.cells.toString() != sala.cells.toString() ||
        anterior.player(widget.usuario ?? '')?.submitted != jugador?.submitted;
    final cambioPuntaje = anterior == null ||
        anterior.scores.toString() != sala.scores.toString();
    _salaActual = sala;
    _forzarSincronizacion = false;
    final puntaje = sala.scores[widget.usuario] ?? jugador?.score ?? 0;
    if (!cambioTablero) {
      if (cambioPuntaje) _bloc.actualizarPuntajeRemoto(puntaje);
      return;
    }
    _bloc.aplicarInstantaneaRemota(
      sala.cells,
      partidaIniciada: sala.phase == 'partida',
      dados: sala.dice,
      ronda: sala.round,
      jugadaEnviada: jugador?.submitted ?? false,
      puntaje: puntaje,
    );
  }

  void _actualizarRelojPausa(RoomSnapshot sala) {
    if (sala.paused && sala.pauseDeadline != null) {
      _relojPausa = DateTime.now();
      _timerCuentaPausa ??= Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          if (mounted) setState(() => _relojPausa = DateTime.now());
        },
      );
    } else {
      _timerCuentaPausa?.cancel();
      _timerCuentaPausa = null;
    }
  }
}

class PantallaLobby extends StatefulWidget {
  final RoomService roomService;
  final RoomSnapshot sala;
  final String usuario;
  final Random? random;

  const PantallaLobby({
    super.key,
    required this.roomService,
    required this.sala,
    required this.usuario,
    this.random,
  });

  @override
  State<PantallaLobby> createState() => _PantallaLobbyState();
}

class _PantallaLobbyState extends State<PantallaLobby> {
  late RoomSnapshot _sala;
  Timer? _timer;
  bool _consultando = false;
  bool _ocupado = false;
  bool _abriendoPartida = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sala = widget.sala;
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _actualizar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _actualizar() async {
    if (_consultando || _abriendoPartida) return;
    _consultando = true;
    try {
      final sala = await widget.roomService.consultar(_sala.code);
      if (!mounted) return;
      if (sala.phase == 'partida') {
        await _abrirPartida(sala);
      } else {
        setState(() {
          _sala = sala;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      _consultando = false;
    }
  }

  Future<void> _prepararTablero() async {
    final listo = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => PantallaTablero(
          nivel: construirNiveles()[_sala.level - 1],
          random: widget.random,
          roomService: widget.roomService,
          sala: _sala,
          usuario: widget.usuario,
          preparandoSala: true,
        ),
      ),
    );
    if (listo == true) await _actualizar();
  }

  Future<void> _iniciarPartida() async {
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      final sala = await widget.roomService.iniciar(_sala.code);
      if (mounted) await _abrirPartida(sala);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _abrirPartida(RoomSnapshot sala) async {
    if (_abriendoPartida || !mounted) return;
    _abriendoPartida = true;
    _timer?.cancel();
    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => PantallaTablero(
          nivel: construirNiveles()[sala.level - 1],
          random: widget.random,
          roomService: widget.roomService,
          sala: sala,
          usuario: widget.usuario,
        ),
      ),
    );
  }

  Future<void> _salir() async {
    setState(() {
      _ocupado = true;
      _error = null;
    });
    try {
      await widget.roomService.salir(_sala.code);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jugador = _sala.player(widget.usuario);
    final anfitrion = _sala.host == widget.usuario;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sala de juego'),
        actions: [
          IconButton(
            tooltip: 'Salir de la sala',
            onPressed: _ocupado ? null : _salir,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        _sala.code,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text('Comparte este código para invitar'),
                      const SizedBox(height: 12),
                      Text('Nivel ${_sala.level} · 2 a 4 jugadores'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Jugadores (${_sala.players.length}/4)',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              for (final player in _sala.players)
                Card(
                  child: ListTile(
                    leading: Icon(
                      player.ready ? Icons.check_circle : Icons.person,
                      color: player.ready ? Colors.green : Colors.blueGrey,
                    ),
                    title: Text(
                      '${player.username}${player.username == _sala.host ? ' · anfitrión' : ''}',
                    ),
                    trailing: Text(player.ready ? 'Listo' : 'Preparando'),
                  ),
                ),
              const SizedBox(height: 16),
              if (jugador?.ready != true)
                FilledButton.icon(
                  onPressed: _ocupado ? null : _prepararTablero,
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Preparar mi tablero'),
                )
              else
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Tu tablero está listo'),
                  ),
                ),
              if (anfitrion) ...[
                const SizedBox(height: 12),
                FilledButton(
                  onPressed:
                      _ocupado || _sala.players.length < 2 || !_sala.allReady
                          ? null
                          : _iniciarPartida,
                  child: const Text('Iniciar partida'),
                ),
              ] else ...[
                const SizedBox(height: 12),
                const Text(
                  'El anfitrión podrá iniciar cuando haya al menos dos jugadores y todos estén listos.',
                  textAlign: TextAlign.center,
                ),
              ],
              if (_ocupado)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
