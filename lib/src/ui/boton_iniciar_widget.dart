import 'package:flutter/material.dart';

import '../tablero_bloc.dart';

class BotonIniciar extends StatelessWidget{

  final TableroBloc bloc;

const BotonIniciar({super.key, required this.bloc});
@override
  Widget build(BuildContext context){
    return StreamBuilder<TableroEstado>(
      stream: bloc.estado, 
      initialData: bloc.estadoActual,
      builder:(context, snapshot){
        final estado = snapshot.data!; 

        if(estado.partidaIniciada){
          return const Chip(
            avatar: Icon(Icons.check_circle, size: 18, color: Colors.green),
            label: Text('Partida iniciada'),
          );
        }

        return ElevatedButton(
          onPressed:
          estado.puedeIniciarPartida ? () => bloc.agregar(IniciarPartida()) : null,
          child: const Text('Iniciar'),
        );
      },
    );
  }
}