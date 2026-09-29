import 'package:flutter/material.dart';
import '../tablero.dart';

class TableroView extends StatelessWidget{
  const TableroView({super.key});

  @override
  Widget build(BuildContext context){
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black),
          left: BorderSide(color: Colors.black),
        ),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: Tablero.tamano * Tablero.tamano,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: Tablero.tamano,
          childAspectRatio: 1,
        ),
        itemBuilder:(context, index) => const _CeldaDelineada(),
      ),
    );
  }
}

class _CeldaDelineada extends StatelessWidget{
  const _CeldaDelineada();

  @override
  Widget build(BuildContext context){
    return const DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black),
          right: BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}