import 'reglas/regla_todos_diferentes.dart';
import 'reglas/regla_todos_iguales.dart';
import 'reglas/regla_zona_verde.dart';
import 'reglas/regla_morado.dart';

abstract class Tipo{
  Color get color;

  String get descripcion;

  bool esPosibleAgregar(List<int> actuales, int posible);

  Map<int, int> get puntuaciones;
}

class TipoRojo extends Tipo{
  @override
  Color get color => const Color(0xFFF44336);
 
  @override
  String get descripcion => 'Todos los números deben ser diferentes';
 
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      cumpleReglaTodosDiferentes(actuales, posible);
 
  
  @override
  Map<int, int> get puntuaciones => const{
        1: 6,
        2: 4,
        3: 2,
      };
}

class TipoAmarillo extends Tipo {
 @override
  Color get color => const Color(0xFFFFEB3B);
 
  @override
  String get descripcion => 'Todos los números deben ser diferentes';
 
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      cumpleReglaTodosDiferentes(actuales, posible);
 
  @override
  Map<int, int> get puntuaciones => const {1: 8, 2: 6, 3: 4};
}

class TipoAzul extends Tipo {
  @override
  Color get color => const Color(0xFF2196F3);
 
  @override
  String get descripcion => 'Todos los números deben de ser iguales';
 
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      cumpleReglaTodosIguales(actuales, posible);
 
  /// Único tipo con valores confirmados directamente por el usuario.
  @override
  Map<int, int> get puntuaciones => const {
        1: 7,
        2: 5,
        3: 3,
      };
}

class TipoVerde extends Tipo {
  @override
  Color get color => const Color(0xFF4CAF50);
 
  @override
  String get descripcion =>
      'Sin restricciones, se puede escribir cualquier número';
 
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      cumpleReglaZonaVerde(actuales, posible);
 
  @override
  Map<int, int> get puntuaciones => const {1: 4, 2: 3, 3: 2};
}

class TipoMorado extends Tipo {
  @override
  Color get color => const Color(0xFF9C27B0);
 
  @override
  String get descripcion => 'Máximo 2 números diferentes en la zona';
 
  @override
  bool esPosibleAgregar(List<int> actuales, int posible) =>
      cumpleReglaMoradoMaximoDosDiferentes(actuales, posible);
 
  @override
  Map<int, int> get puntuaciones => const {1: 6, 2: 4, 3: 2};
}
 