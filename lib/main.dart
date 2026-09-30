import 'package:flutter/material.dart';
import 'brilliant.dart';

void main() {
  runApp(const BrilliantApp());
}

class BrilliantApp extends StatelessWidget{
  const BrilliantApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brilliant',
      home: Scaffold(
        appBar: AppBar(title: const Text('Brilliant — tablero')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: const Column(
                  children: [
                    TableroWidget(),
                    SizedBox(height: 16),
                    PanelMano(
                      numerosEnMano: [1, 2, 2, 3, 4, 6],
                      indiceSeleccionado: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),    
      ),
    );
  }
}