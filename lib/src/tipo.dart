import 'package:flutter/material.dart';
import 'reglas/regla_todos_diferentes.dart';
import 'reglas/regla_todos_iguales.dart';
import 'reglas/regla_zona_verde.dart';
import 'reglas/regla_morado.dart';
import 'reglas/regla_rango.dart';

abstract class Tipo{
  Color get color;

  String get descripcion;

  bool esPosibleAgregar(List<int> actuales, int posible);

  Map<int, int> get puntuaciones;
}

class TipoRojo extends Tipo {
  final Map<int, int> _puntuaciones;

  TipoRojo({Map<int, int>? puntuaciones})
      : _puntuaciones = puntuaciones ?? const {1: 6, 2: 4, 3: 2};

  @override
  Color get color => const Color(0xFFF44336);
 
  @override
  String get descripcion => 'Todos los números deben ser diferentes';
 
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      cumpleReglaTodosDiferentes(actuales, posible);
 
  
  @override
  Map<int, int> get puntuaciones => _puntuaciones;
}

class TipoAmarillo extends Tipo {
  final Map<int, int> _puntuaciones;

  TipoAmarillo({Map<int, int>? puntuaciones})
      : _puntuaciones = puntuaciones ?? const {1: 8, 2: 6, 3: 4};

 @override
  Color get color => const Color(0xFFFFEB3B);
 
  @override
  String get descripcion => 'Todos los números deben ser diferentes';
 
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      cumpleReglaTodosDiferentes(actuales, posible);
 
  @override
  Map<int, int> get puntuaciones => _puntuaciones;
}

class TipoAzul extends Tipo {
  final Map<int, int> _puntuaciones;

  TipoAzul({Map<int, int>? puntuaciones})
      : _puntuaciones = puntuaciones ?? const {1: 7, 2: 5, 3: 3};

  @override
  Color get color => const Color(0xFF2196F3);
 
  @override
  String get descripcion => 'Todos los números deben de ser iguales';
 
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      cumpleReglaTodosIguales(actuales, posible);
 
  @override
  Map<int, int> get puntuaciones => _puntuaciones;
}

class TipoVerde extends Tipo {
  final Map<int, int> _puntuaciones;

  TipoVerde({Map<int, int>? puntuaciones})
      : _puntuaciones = puntuaciones ?? const {1: 4, 2: 3, 3: 2};

  @override
  Color get color => const Color(0xFF4CAF50);
 
  @override
  String get descripcion =>
      'Sin restricciones, se puede escribir cualquier número';
 
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      cumpleReglaZonaVerde(actuales, posible);
 
  @override
  Map<int, int> get puntuaciones => _puntuaciones;
}

class TipoMorado extends Tipo {
  final Map<int, int> _puntuaciones;

  TipoMorado({Map<int, int>? puntuaciones})
      : _puntuaciones = puntuaciones ?? const {1: 6, 2: 4, 3: 2};

  @override
  Color get color => const Color(0xFF9C27B0);
 
  @override
  String get descripcion => 'Máximo 2 números diferentes en la zona';
 
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      cumpleReglaMoradoMaximoDosDiferentes(actuales, posible);
 
  @override
  Map<int, int> get puntuaciones => _puntuaciones;
}

class TipoGris extends Tipo {
  final Map<int, int> _puntuaciones;

  TipoGris({Map<int, int>? puntuaciones})
      : _puntuaciones = puntuaciones ?? const {1: 3, 2: 2, 3: 1};

  @override
  Color get color => const Color(0xFFBDBDBD);

  @override
  String get descripcion => 'Todos los números deben de ser iguales';

  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      cumpleReglaTodosIguales(actuales, posible);

  @override
  Map<int, int> get puntuaciones => _puntuaciones;
}


class TipoNaranja extends Tipo {
  final int minimo;
  final int maximo;
  final Map<int, int> _puntuaciones;

  TipoNaranja({
    required this.minimo,
    required this.maximo,
    Map<int, int>? puntuaciones,
  })  : assert(minimo <= maximo, 'El rango naranja debe tener minimo <= maximo'),
        _puntuaciones = puntuaciones ?? const {1: 6, 2: 4, 3: 3};

  @override
  Color get color => const Color(0xFFFF9800);

  @override
  String get descripcion => 'Solo números del $minimo al $maximo';

  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      cumpleReglaRango(actuales, posible, minimo: minimo, maximo: maximo);

  @override
  Map<int, int> get puntuaciones => _puntuaciones;
}

 