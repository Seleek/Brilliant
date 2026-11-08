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
      title: 'Brilliant',
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
    required this.onLogout,});

  Future<void> _confirmarBorrarCuenta(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text('¿Estás seguro de que deseas eliminar tu cuenta de forma permanente?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await authService.borrarCuenta();
        onLogout();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }


  @override
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Brilliant - ${authService.currentUser}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: 'Borrar Cuenta',
            onPressed: () => _confirmarBorrarCuenta(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              authService.cerrarSesion();
              onLogout();
            },
          ),
        ],
      ),
      body: PantallaSeleccionNivel(
        niveles: construirNiveles(),
        onNivelElegido: (nivel) => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PantallaTablero(nivel: nivel, random: random),
          ),
        ),
      ),
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
                      onPasar: enTurnos
                          ? () => _bloc.agregar(PasarTurno())
                          : null,
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