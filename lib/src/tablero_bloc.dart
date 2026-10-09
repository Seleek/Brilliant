import 'dart:async';
import 'celda.dart';
import 'tablero.dart';
import 'reglas/regla_todos_diferentes.dart';

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

class SeleccionarNumeroDeMano extends TableroEvento {
  final int indiceEnMano;

  SeleccionarNumeroDeMano(this.indiceEnMano);
}

class ColocarFicha extends TableroEvento{}

class   IniciarPartida extends TableroEvento{}

class TableroEstado {
  final Tablero tablero;

  final bool bloqueadoPorValoresIniciales;

  final String? mensajeError;

  final Posicion? posicionSeleccionada;

  final List<int> numerosEnMano;

  final int? indiceNumeroSeleccionado;

  final bool partidaIniciada;

  const TableroEstado({
    required this.tablero,
    required this.bloqueadoPorValoresIniciales,
    this.mensajeError,
    this.posicionSeleccionada,
    this.numerosEnMano = const [],
    this.indiceNumeroSeleccionado,
    this.partidaIniciada = false,
  });

  bool get puedeIniciarPartida =>
  !bloqueadoPorValoresIniciales && !partidaIniciada;
}

class TableroBloc{
  final Tablero _tablero;
  final List<int> _numerosEnMano;

  final _estadoController = StreamController<TableroEstado>.broadcast();

  late TableroEstado _estadoActual;

  Posicion? _posicionSeleccionada;

  int? _indiceNumeroSeleccionado;

  bool _partidaIniciada = false;

  TableroBloc(this._tablero, {List<int> numerosEnMano = const []})
      : _numerosEnMano = numerosEnMano {
    _estadoActual = _construirEstado();
}

TableroEstado get estadoActual => _estadoActual;

Stream<TableroEstado> get estado => _estadoController.stream;

void agregar (TableroEvento evento) {
  if (evento is ColocarNumero) {
    _manejarColocarNumero(evento);
  } else if(evento is SeleccionarCelda) {
    _manejarSeleccionarCelda(evento);
  }else if(evento is SeleccionarNumeroDeMano) {
    _manejarSeleccionarNumeroDeMano(evento);
  } else if(evento is ColocarFicha) {
    _manejarColocarFicha();
  } else if(evento is IniciarPartida) {
    _manejarIniciarPartida();
  }
}

void _manejarSeleccionarCelda(SeleccionarCelda evento) {
  _posicionSeleccionada = evento.posicion;
  _actualizarEstado();
}

int? _indiceNumeroPorDefecto(){
  if(_numerosEnMano.isEmpty) return null;
  final indiceDelUno = _numerosEnMano.indexOf(1);
  return indiceDelUno != -1 ? indiceDelUno : 0;
}

void _manejarSeleccionarNumeroDeMano(SeleccionarNumeroDeMano evento){
  if(evento.indiceEnMano < 0 || evento.indiceEnMano >= _numerosEnMano.length){
    return;
  }
  _indiceNumeroSeleccionado = evento.indiceEnMano;
  _actualizarEstado();
}

void _manejarColocarFicha(){
  if(_posicionSeleccionada == null || _indiceNumeroSeleccionado == null){
    _actualizarEstado(mensajeError: 'Selecciona primero una celda y un numero',);
    return;
  }

  final valor = _numerosEnMano[_indiceNumeroSeleccionado!];
  final exito = _tablero.intentarColocarNumero(_posicionSeleccionada!, valor);

  final mensajeError = exito
  ? null
  : (_tablero.bloqueadoPorValoresIniciales
  ? 'Primero debes completar los valores iniciales'
  : 'No coloques el numero ahi mdfk');

  _actualizarEstado(mensajeError: mensajeError);
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

String? _intentarColocarValidado(Posicion posicion, int valor){
  final esPosicionInicial = _tablero.posicionesIniciales.contains(posicion); 

  if(esPosicionInicial && _partidaIniciada){
    return 'No puedes modificar los valores';
  }

  if(esPosicionInicial){
    final valoresExistentes = 
    _tablero.valoresIniciales(excluyendo: posicion);

    if(!cumpleReglaTodosDiferentes(valoresExistentes, valor)){
      return 'No puedes repetir valores iniciales';
    }
  }
}

void _manejarIniciarPartida(){ 
  if(_tablero.bloqueadoPorValoresIniciales){
    _actualizarEstado(mensajeError: 'Completa primero los valores iniciales');
    return;
  }
  _partidaIniciada=true;
  _actualizarEstado();
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
        numerosEnMano: _numerosEnMano,
        indiceNumeroSeleccionado: _indiceNumeroSeleccionado,
        partidaIniciada: _partidaIniciada,
      );
       void dispose() {
    _estadoController.close();
  }
}