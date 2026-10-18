import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brilliant/brilliant.dart';
import 'package:brilliant/main.dart' show BrilliantApp;

import './random_falso.dart';

void main() {
  testWidgets('camino feliz: preparar la partida, iniciarla y jugar dos '
      'turnos', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      BrilliantApp(random: RandomFalso([1, 4, 2, 0, 3, 1])),
    );

    String claveDe(Posicion p) => 'celda_${p.x}_${p.y}';

    Posicion posicionDe(CasillaTablero casilla) {
      final partes = (casilla.key! as ValueKey<String>).value.split('_');
      return Posicion(int.parse(partes[1]), int.parse(partes[2]));
    }

    CasillaTablero casillaEn(Posicion p) => tester
        .widget<CasillaTablero>(find.byKey(ValueKey(claveDe(p))));

    List<Posicion> casillasQue(bool Function(CasillaTablero) cumple) => tester
        .widgetList<CasillaTablero>(find.byType(CasillaTablero))
        .where(cumple)
        .map(posicionDe)
        .toList();

    Future<void> tocar(Finder finder) async {
      await tester.tap(finder);
      await tester.pump();
    }

    Future<void> tocarCasilla(Posicion p) =>
        tocar(find.byKey(ValueKey(claveDe(p))));
    Future<void> tocarNumeroDeLaMano(int indice) =>
        tocar(find.byKey(ValueKey('boton_mano_$indice')));
    Future<void> tocarDado(int indice) =>
        tocar(find.byKey(ValueKey('dado_$indice')));

    final botonColocar = find.widgetWithText(ElevatedButton, 'Colocar ficha');
    final botonIniciar = find.widgetWithText(ElevatedButton, 'Iniciar');

    bool habilitado(Finder boton) =>
        tester.widget<ElevatedButton>(boton).onPressed != null;

    String textoDelDado(int indice) => tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(ValueKey('dado_$indice')),
            matching: find.byType(Text),
          ),
        )
        .data!;

    bool dadoElegido(int indice) => tester
        .widget<CasillaDado>(find.byKey(ValueKey('dado_$indice')))
        .seleccionado;

    bool manoHabilitada(int indice) => tester
        .widget<BotonNumeroMano>(find.byKey(ValueKey('boton_mano_$indice')))
        .habilitado;

    final estrellas = casillasQue((c) => c.iluminada)
      ..sort((a, b) => a.y != b.y ? a.y.compareTo(b.y) : a.x.compareTo(b.x));

    expect(estrellas, hasLength(6), reason: 'se iluminan 6 casillas');
    expect(textoDelDado(0), '–', reason: 'aún no hay dados');
    expect(textoDelDado(1), '–', reason: 'aún no hay dados');
    expect(habilitado(botonIniciar), isFalse, reason: 'faltan números');
    for (var i = 0; i < 6; i++) {
      expect(manoHabilitada(i), isTrue, reason: 'la mano se puede usar');
    }

    for (var i = 0; i < 6; i++) {
      await tocarCasilla(estrellas[i]);
      await tocarNumeroDeLaMano(i); 
      await tocar(botonColocar);

      expect(
        casillaEn(estrellas[i]).valor,
        i + 1,
        reason: 'la casilla iluminada ${i + 1} muestra su número',
      );
      expect(
        habilitado(botonIniciar),
        i == 5,
        reason: '"Iniciar" solo se habilita al llenar la sexta casilla',
      );
    }

    await tocar(botonIniciar);

    expect(find.text('Partida iniciada'), findsOneWidget);
    expect(botonIniciar, findsNothing);
    expect(casillasQue((c) => c.iluminada), isEmpty,
        reason: 'las casillas iniciales ya no brillan');
    for (var i = 0; i < 6; i++) {
      expect(manoHabilitada(i), isFalse, reason: 'la mano se deshabilita');
      expect(casillaEn(estrellas[i]).valor, i + 1,
          reason: 'los números iniciales se conservan');
    }
    expect(find.text('Turno 1'), findsOneWidget);
    expect(textoDelDado(0), '2');
    expect(textoDelDado(1), '5');
    expect(dadoElegido(0), isFalse);
    expect(dadoElegido(1), isFalse);
    expect(habilitado(botonColocar), isFalse, reason: 'falta elegir');

    await tocarDado(0);
    expect(dadoElegido(0), isTrue);
    var propuestas = casillasQue((c) => c.propuesta);
    expect(propuestas, isNotEmpty);
    for (final p in propuestas) {
      expect(p.esAdyacenteA(estrellas[4]), isTrue,
          reason: 'el 2 se propone junto al 5');
      expect(casillaEn(p).numeroPreview, 2);
    }
    expect(habilitado(botonColocar), isFalse, reason: 'falta la casilla');

    final destinoTurno1 = propuestas.first;
    await tocarCasilla(destinoTurno1);
    expect(casillaEn(destinoTurno1).seleccionada, isTrue);
    expect(habilitado(botonColocar), isTrue);

    await tocar(botonColocar);
    expect(casillaEn(destinoTurno1).valor, 2);
    expect(casillasQue((c) => c.propuesta), isEmpty);
    expect(find.text('Turno 2'), findsOneWidget);
    expect(textoDelDado(0), '3');
    expect(textoDelDado(1), '1');
    expect(dadoElegido(0), isFalse);
    expect(habilitado(botonColocar), isFalse);

    await tocarDado(0);
    propuestas = casillasQue((c) => c.propuesta);
    expect(propuestas, isNotEmpty);
    for (final p in propuestas) {
      expect(p.esAdyacenteA(estrellas[0]), isTrue,
          reason: 'el 3 se propone junto al 1');
      expect(casillaEn(p).numeroPreview, 3);
    }

    await tocarDado(1);
    expect(dadoElegido(0), isFalse);
    expect(dadoElegido(1), isTrue);
    propuestas = casillasQue((c) => c.propuesta);
    expect(propuestas, isNotEmpty);
    for (final p in propuestas) {
      expect(p.esAdyacenteA(estrellas[2]), isTrue,
          reason: 'el 1 se propone junto al 3');
      expect(casillaEn(p).numeroPreview, 1);
    }

    final destinoTurno2 = propuestas.first;
    await tocarCasilla(destinoTurno2);
    await tocar(botonColocar);
    expect(casillaEn(destinoTurno2).valor, 1);
    expect(find.text('Turno 3'), findsOneWidget);
    expect(textoDelDado(0), '4');
    expect(textoDelDado(1), '2');

    expect(casillasQue((c) => c.valor != null), hasLength(8));
    for (var i = 0; i < 6; i++) {
      expect(casillaEn(estrellas[i]).valor, i + 1);
    }
    expect(casillaEn(destinoTurno1).valor, 2);
    expect(casillaEn(destinoTurno2).valor, 1);
  });
}