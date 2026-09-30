import 'package:flutter/material.dart';
import 'brilliant.dart';

void main() {
  runApp(const BrilliantApp());
}

class BrilliantApp extends StatelessWidget {
  const BrilliantApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brilliant',
      home: const PantallaTablero(),
    );
  }
}
 
class PantallaTablero extends StatefulWidget {
  const PantallaTablero({super.key});
 
  @override
  State<PantallaTablero> createState() => _PantallaTableroState();
}
 
class _PantallaTableroState extends State<PantallaTablero> {
  late final TableroBloc _bloc;
 
  @override
  void initState() {
    super.initState();
    _bloc = TableroBloc(Tablero.vacio(const {}));
  }
 
  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brilliant — tablero')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tablero = SizedBox(
              width: 420,
              child: TableroWidget(bloc: _bloc),
            );
            const panel = PanelMano(
              numerosEnMano: [1, 2, 3, 4, 5, 6],
              indiceSeleccionado: 1,
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
                          child: panel,
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