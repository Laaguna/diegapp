import 'package:flutter_test/flutter_test.dart';
import 'package:diegapp/models/form_model.dart';
import 'package:diegapp/utils/calculations.dart';

void main() {
  group('calculations', () {
    FormModel empty() => FormModel.empty();

    test('campos vacíos → 0%', () {
      final f = empty();
      expect(calcularCumplimientoNuevoVenue(f), 0.0);
      expect(calcularCumplimientoNuevoEvento(f), 0.0);
      expect(calcularCumplimientoModificables(f), 0.0);
      expect(calcularTotal(f), 0.0);
    });

    test('espacios en blanco se consideran vacíos', () {
      final f = empty().copyWith(
        venue: '   ',
        mapa: '\t\n',
        taquilla: 'Taquilla real',
      );
      expect(calcularCumplimientoNuevoVenue(f), closeTo(33.33, 0.01));
    });

    test('todos los campos de un grupo rellenos → 100%', () {
      final f = empty().copyWith(
        venue: 'A',
        mapa: 'B',
        taquilla: 'C',
      );
      expect(calcularCumplimientoNuevoVenue(f), 100.0);
    });

    test('total refleja los 12 campos', () {
      final f = empty().copyWith(
        venue: 'a',
        mapa: 'b',
        taquilla: 'c',
        configuracionCanales: 'd',
        configuracionShow: 'e',
        tyc: 'f',
        imagenes: 'g',
        tarifas: 'h',
        holds: 'i',
        preventas: 'j',
        validadores: 'k',
        mapaSilleteria: 'l',
      );
      expect(calcularTotal(f), 100.0);
    });

    test('total parcial: 6 de 12 → 50%', () {
      final f = empty().copyWith(
        venue: 'a',
        mapa: 'b',
        taquilla: 'c',
        configuracionCanales: 'd',
        configuracionShow: 'e',
        tyc: 'f',
      );
      expect(calcularTotal(f), 50.0);
    });
  });
}
