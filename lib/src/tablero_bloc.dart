import 'dart:async';
import 'dart:math';

import 'celda.dart';
import 'reglas/regla_todos_diferentes.dart';
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

class SeleccionarNumeroDeMano extends TableroEvento {
  final int indiceEnMano;

  SeleccionarNumeroDeMano(this.indiceEnMano);
}

class ColocarFicha extends TableroEvento {}

class IniciarPartida extends TableroEvento {}

class PasarTurno extends TableroEvento {}

class SeleccionarDado extends TableroEvento {
  final int indice;

  SeleccionarDado(this.indice);
}

class TableroEstado {
  final Tablero tablero;

  final bool bloqueadoPorValoresIniciales;

  final String? mensajeError;

  final Posicion? posicionSeleccionada;

  final List<int> numerosEnMano;

  final int? indiceNumeroSeleccionado;

  final bool partidaIniciada;

  final bool valoresInicialesValidos;

  final List<int> dados;

  final int turno;

  final int? indiceDadoSeleccionado;

  final Set<Posicion> casillasPropuestas;

  const TableroEstado({
    required this.tablero,
    required this.bloqueadoPorValoresIniciales,
    this.mensajeError,
    this.posicionSeleccionada,
    this.numerosEnMano = const [],
    this.indiceNumeroSeleccionado,
    this.partidaIniciada = false,
    this.valoresInicialesValidos = false,
    this.dados = const [],
    this.turno = 0,
    this.indiceDadoSeleccionado,
    this.casillasPropuestas = const {},
  });

  bool get puedeIniciarPartida => valoresInicialesValidos && !partidaIniciada;

  int? get numeroDelDadoSeleccionado {
    final indice = indiceDadoSeleccionado;
    return (indice != null && indice < dados.length) ? dados[indice] : null;
  }

  bool get puedeColocarFichaDelTurno {
    final casilla = posicionSeleccionada;
    return partidaIniciada &&
        indiceDadoSeleccionado != null &&
        casilla != null &&
        casillasPropuestas.contains(casilla);
  }
}

class TableroBloc {
  final Tablero _tablero;

  final List<int> _numerosEnMano;

  final _estadoController = StreamController<TableroEstado>.broadcast();

  late TableroEstado _estadoActual;

  Posicion? _posicionSeleccionada;

  int? _indiceNumeroSeleccionado;

  bool _partidaIniciada = false;

  final Random _random;

  int _turno = 0;

  List<int> _dados = const [];

  int? _indiceDadoSeleccionado;

  Set<Posicion> _casillasPropuestas = {};

  TableroBloc(
    this._tablero, {
    List<int> numerosEnMano = const [],
    Random? random,
  })  : _numerosEnMano = numerosEnMano,
        _random = random ?? Random() {
    _estadoActual = _construirEstado();
  }

  TableroEstado get estadoActual => _estadoActual;

  Stream<TableroEstado> get estado => _estadoController.stream;

  void agregar(TableroEvento evento) {
    if (evento is ColocarNumero) {
      _manejarColocarNumero(evento);
    } else if (evento is SeleccionarCelda) {
      _manejarSeleccionarCelda(evento);
    } else if (evento is SeleccionarNumeroDeMano) {
      _manejarSeleccionarNumeroDeMano(evento);
    } else if (evento is ColocarFicha) {
      _manejarColocarFicha();
    } else if (evento is IniciarPartida) {
      _manejarIniciarPartida();
    } else if (evento is PasarTurno) {
      _manejarPasarTurno();
    } else if (evento is SeleccionarDado) {
      _manejarSeleccionarDado(evento);
    }
  }

  void _manejarSeleccionarCelda(SeleccionarCelda evento) {
    if (_partidaIniciada) {

      if (_casillasPropuestas.contains(evento.posicion)) {
        _posicionSeleccionada = evento.posicion;
        _actualizarEstado();
      }
      return;
    }

    _posicionSeleccionada = evento.posicion;

    _indiceNumeroSeleccionado = _indiceNumeroPorDefecto();
    _actualizarEstado();
  }

  int? _indiceNumeroPorDefecto() {
    if (_numerosEnMano.isEmpty) return null;
    final indiceDelUno = _numerosEnMano.indexOf(1);
    return indiceDelUno != -1 ? indiceDelUno : 0;
  }

  void _manejarSeleccionarNumeroDeMano(SeleccionarNumeroDeMano evento) {

    if (_partidaIniciada) return;

    if (evento.indiceEnMano < 0 ||
        evento.indiceEnMano >= _numerosEnMano.length) {
      return;
    }
    _indiceNumeroSeleccionado = evento.indiceEnMano;
    _actualizarEstado();
  }

  void _manejarSeleccionarDado(SeleccionarDado evento) {
    if (!_partidaIniciada) return;
    if (evento.indice < 0 || evento.indice >= _dados.length) return;

    if (evento.indice == _indiceDadoSeleccionado) return;

    _indiceDadoSeleccionado = evento.indice;

    _posicionSeleccionada = null;
    _casillasPropuestas = _tablero.casillasVaciasAdyacentes();
    _actualizarEstado();
  }

  void _manejarColocarFicha() {
    if (_partidaIniciada) {
      _manejarColocarFichaDelTurno();
      return;
    }

    if (_posicionSeleccionada == null || _indiceNumeroSeleccionado == null) {
      _actualizarEstado(
        mensajeError: 'Selecciona primero una celda y un número',
      );
      return;
    }

    final valor = _numerosEnMano[_indiceNumeroSeleccionado!];
    final mensajeError =
        _intentarColocarValidado(_posicionSeleccionada!, valor);
    _actualizarEstado(mensajeError: mensajeError);
  }

  void _manejarColocarFichaDelTurno() {
    final indiceDado = _indiceDadoSeleccionado;
    final posicion = _posicionSeleccionada;

    if (indiceDado == null ||
        posicion == null ||
        !_casillasPropuestas.contains(posicion)) {
      _actualizarEstado(
        mensajeError: 'Elige un dado y una de las casillas propuestas',
      );
      return;
    }

    final mensajeError = _intentarColocarValidado(posicion, _dados[indiceDado]);
    if (mensajeError != null) {
      _actualizarEstado(mensajeError: mensajeError);
      return;
    }

    _iniciarNuevoTurno();
    _actualizarEstado();
  }

  void _manejarColocarNumero(ColocarNumero evento) {
    final mensajeError = _intentarColocarValidado(evento.posicion, evento.valor);
    _actualizarEstado(mensajeError: mensajeError);
  }

  String? _intentarColocarValidado(Posicion posicion, int valor) {
    final esPosicionInicial = _tablero.posicionesIniciales.contains(posicion);

    if (esPosicionInicial && _partidaIniciada) {
      return 'No puedes modificar los valores iniciales: la partida ya '
          'comenzó';
    }

    if (esPosicionInicial) {
      final valoresExistentes =
          _tablero.valoresIniciales(excluyendo: posicion);
      if (!cumpleReglaTodosDiferentes(valoresExistentes, valor)) {
        return 'Ese número ya lo usaste en otra casilla inicial';
      }
    }

    final exito = _tablero.intentarColocarNumero(posicion, valor);
    if (!exito) {
      return _tablero.bloqueadoPorValoresIniciales
          ? 'Primero debes completar los valores iniciales'
          : 'No se puede colocar ese número ahí';
    }
    return null;
  }

  void _manejarIniciarPartida() {

    if (_partidaIniciada) return;

    if (_tablero.bloqueadoPorValoresIniciales) {
      _actualizarEstado(
        mensajeError: 'Completa los valores iniciales antes de iniciar',
      );
      return;
    }

    if (!_tablero.valoresInicialesSonDiferentes) {
      _actualizarEstado(
        mensajeError: 'Los números iniciales deben ser todos diferentes',
      );
      return;
    }
    _partidaIniciada = true;
    _iniciarNuevoTurno(); // turno 1: primera tirada de dados
    _actualizarEstado();
  }

  void _manejarPasarTurno() {
    if (!_partidaIniciada) {
      _actualizarEstado(mensajeError: 'Primero debes iniciar la partida');
      return;
    }
    _iniciarNuevoTurno();
    _actualizarEstado();
  }

  void _iniciarNuevoTurno() {
    _turno++;
    _dados = List.unmodifiable([_tirarDado(), _tirarDado()]);

    _indiceDadoSeleccionado = null;
    _casillasPropuestas = {};
    _posicionSeleccionada = null;
  }

  int _tirarDado() => 1 + _random.nextInt(6);

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
        valoresInicialesValidos: !_tablero.bloqueadoPorValoresIniciales &&
            _tablero.valoresInicialesSonDiferentes,
        dados: _dados,
        turno: _turno,
        indiceDadoSeleccionado: _indiceDadoSeleccionado,
        casillasPropuestas: Set.unmodifiable(_casillasPropuestas),
      );

  void dispose() {
    _estadoController.close();
  }
}
