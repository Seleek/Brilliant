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
      home: Scaffold(
        appBar: AppBar(title: const Text('Brilliant — tablero')),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const tablero = SizedBox(
                width: 420,
                child: TableroWidget(),
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
                    children: const [
                      tablero,
                      SizedBox(height: 16),
                      panel,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}