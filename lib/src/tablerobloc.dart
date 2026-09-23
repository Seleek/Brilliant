import 'dart:async';
import 'celda.dart';
import 'tablero.dart';

abstract class TableroEvento {}

class ColocarNumero extends TableroEvento {
  final Posicion posicion;
  final int valor;

  ColocarNumero(this.posicion, this.valor);
}

class TableroEstado {
  final Tablero tablero;

  final String? mensajeError;

  const TableroEstado({
    required this.tablero,
    required this.bloqueadoPorValoresIniciales,
    this.mensajeError,
  })
}

class TableroBloc{
  final Tablero _tablero;
  final _estadoController = StreamController<TableroEstado>.broadcast();

  late TableroEstado _estadoActual;

  TableroBloc(this._tablero) {
    _estadoActual = _construirEstado();
}

TableroEstado get estadoActual => _estadoActual;

Stream<TableroEstado> get estadoStream => _estadoController.stream;

void agregar (TableroEvento evento) {
  if (evento is ColocarNumero) {
    _manejarColocarNumero(evento);
  }
}

void _manejarColocarNumero (ColocarNumero evento){
  final exito = _tablero.intentarColocarNumero(evento.posicion, evento.valor);

  final mensajeError = exito
  ? null
  : (_tablero.bloqueadoPorValoresIniciales 
  ? 'Primero debes completar los valores iniciales'
  : 'No coloques el numero ahi mdfk');

  _actualizarEstado(mensajeError: mensajeError);
}

void _actualizarEstado({String? mensajeError}) {
    _estadoActual = _construirEstado(mensajeError: mensajeError);
    _estadoController.add(_estadoActual);
  }
 
  TableroEstado _construirEstado({String? mensajeError}) => TableroEstado(
        tablero: _tablero,
        bloqueadoPorValoresIniciales: _tablero.bloqueadoPorValoresIniciales,
        mensajeError: mensajeError,
      );
       void dispose() {
    _estadoController.close();
  }
}