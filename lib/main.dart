import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'brilliant.dart';
import 'src/datos/niveles.dart';
import 'src/ui/pantalla_seleccion_nivel.dart';
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
  bool _enviandoJugada = false;
  bool _forzarSincronizacion = false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Brilliant — ${widget.nivel.nombre}')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tablero = SizedBox(
              width: 420,
              child: TableroWidget(
                bloc: _bloc,
                tipoPorPosicion: widget.nivel.tipoPorPosicion,
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
                                jugador.submitted
                                    ? Icons.check_circle
                                    : Icons.person_outline,
                                size: 16,
                              ),
                              label: Text(
                                '${jugador.username}: ${jugador.score}',
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
                      onDadoTocado: enTurnos &&
                              !estado.jugadaEnviada &&
                              !_enviandoJugada
                          ? (indice) => _bloc.agregar(SeleccionarDado(indice))
                          : null,
                    ),
                    const SizedBox(height: 16),
                    PanelMano(
                      numerosEnMano: estado.numerosEnMano,
                      numerosHabilitados: !enTurnos,
                      indiceSeleccionado:
                          enTurnos ? null : estado.indiceNumeroSeleccionado,
                      onNumeroTocado: (indice) =>
                          _bloc.agregar(SeleccionarNumeroDeMano(indice)),
                      onColocarFicha:
                          (!enTurnos || estado.puedeColocarFichaDelTurno) &&
                                  !_enviandoJugada
                              ? widget.roomService != null &&
                                      !widget.preparandoSala &&
                                      enTurnos
                                  ? () => _enviarJugada(pasada: false)
                                  : () => _bloc.agregar(ColocarFicha())
                              : null,
                      onPasar:
                          enTurnos && !estado.jugadaEnviada && !_enviandoJugada
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

            final esAncho = constraints.maxWidth >= 700;

            if (esAncho) {
              return Padding(
                padding: const EdgeInsets.all(16),
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
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              panel,
                              const SizedBox(height: 16),
                              boton,
                            ],
                          ),
                        ),
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
                    tablero,
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
              estado.jugadaEnviada
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
      if (mounted) _aplicarSala(actualizada);
    } catch (error) {
      if (mounted) setState(() => _errorSala = error.toString());
    }
  }

  void _aplicarSala(RoomSnapshot sala) {
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
