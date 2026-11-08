import 'dart:math';

import 'package:flutter/material.dart';

import 'brilliant.dart';
import 'src/datos/niveles.dart';
import 'src/ui/pantalla_seleccion_nivel.dart';
import 'src/servicios/auth_service.dart';
import 'src/ui/pantalla_auth.dart';

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

  const PantallaTablero({super.key, required this.nivel, this.random});

  @override
  State<PantallaTablero> createState() => _PantallaTableroState();
}

class _PantallaTableroState extends State<PantallaTablero> {
  late final TableroBloc _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = TableroBloc(
      Tablero.vacio(
        const {},
        tipoPorPosicion: widget.nivel.tipoPorPosicion,
        coloresUnificados: widget.nivel.coloresUnificados,
        posicionesIniciales: widget.nivel.posicionesIniciales,
      ),
      numerosEnMano: const [1, 2, 3, 4, 5, 6],
      random: widget.random,
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
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
                    PanelDados(
                      dados: estado.dados,
                      turno: estado.turno,
                      puntaje: estado.puntajeTotal,
                      indiceSeleccionado: estado.indiceDadoSeleccionado,
                      onDadoTocado: enTurnos
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
                          (!enTurnos || estado.puedeColocarFichaDelTurno)
                              ? () => _bloc.agregar(ColocarFicha())
                              : null,
                      onPasar:
                          enTurnos ? () => _bloc.agregar(PasarTurno()) : null,
                    ),
                  ],
                );
              },
            );

            final boton = Align(
              alignment: Alignment.centerLeft,
              child: BotonIniciar(bloc: _bloc),
            );

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
}
