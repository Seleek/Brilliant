import 'package:flutter/material.dart';
import 'brilliant.dart';

void main() {
  runApp(const BrilliantApp());
}

class BrilliantApp extends StatelessWidget{
  const BrilliantApp ({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Brilliant',
      home: Scaffold(
        appBar: AppBar(title: const Text('Brilliant — tablero')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: TableroWidget(),
        ),
      ),
    );
  }
}