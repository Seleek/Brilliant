import 'dart:async';
import 'celda.dart';
import 'tablero.dart';

abstract class TableroEvento {}

class ColocarNumero extends TableroEvento {
  final Posicion posicion;
  final int valor;

  ColocarNumero(this.posicion, this.valor);
}

class SeleccionarCelda extends TableroEvento {
  final Posicion posicion;

  SeleccionarCelda(this.posicion);
}

class TableroEstado {
  final Tablero tablero;

  final bool bloqueadoPorValoresIniciales;

  final String? mensajeError;

  final Posicion? posicionSeleccionada;

  const TableroEstado({
    required this.tablero,
    required this.bloqueadoPorValoresIniciales,
    this.mensajeError,
    this.posicionSeleccionada,
  });
}

class TableroBloc{
  final Tablero _tablero;
  final _estadoController = StreamController<TableroEstado>.broadcast();

  late TableroEstado _estadoActual;

  Posicion? _posicionSeleccionada;

  TableroBloc(this._tablero) {
    _estadoActual = _construirEstado();
}

TableroEstado get estadoActual => _estadoActual;

Stream<TableroEstado> get estado => _estadoController.stream;

void agregar (TableroEvento evento) {
  if (evento is ColocarNumero) {
    _manejarColocarNumero(evento);
  } else if(evento is SeleccionarCelda) {
    _manejarSeleccionarCelda(evento);
  }
}

void _manejarSeleccionarCelda(SeleccionarCelda evento) {
  _posicionSeleccionada = evento.posicion;
  _actualizarEstado();
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
        posicionSeleccionada: _posicionSeleccionada,
      );
       void dispose() {
    _estadoController.close();
  }
}