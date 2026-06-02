import 'package:flutter_test/flutter_test.dart';
import 'package:diegapp/models/form_model.dart';

void main() {
  group('FormModel', () {
    test('empty() crea con fecha de hoy', () {
      final f = FormModel.empty();
      expect(f.id, isNull);
      expect(f.fecha, isNotEmpty);
      expect(f.especialista, '');
      expect(f.evento, '');
      expect(f.createdAt, isNotEmpty);
      expect(f.updatedAt, isNotEmpty);
    });

    test('empty() → isNew es true', () {
      expect(FormModel.empty().isNew, isTrue);
    });

    test('copyWith solo cambia los campos provistos', () {
      final base = FormModel.empty().copyWith(
        especialista: 'Lagu',
        evento: 'Concierto X',
      );
      final updated = base.copyWith(venue: 'Movistar Arena');
      expect(updated.especialista, 'Lagu');
      expect(updated.evento, 'Concierto X');
      expect(updated.venue, 'Movistar Arena');
      expect(updated.mapa, '');
    });

    test('toMap / fromMap roundtrip', () {
      final f = FormModel.empty().copyWith(
        id: 42,
        especialista: 'Lagu',
        evento: 'Test',
        venue: 'V',
        mapa: 'M',
        taquilla: 'T',
        configuracionCanales: 'CC',
        configuracionShow: 'CS',
        tyc: 'TYC',
        imagenes: 'IMG',
        tarifas: r'$$',
        holds: 'H',
        preventas: 'P',
        validadores: 'VAL',
        mapaSilleteria: 'MS',
        cumplimientoNuevoVenue: 100.0,
        cumplimientoNuevoEvento: 80.0,
        cumplimientoModificables: 50.0,
        total: 75.0,
        createdAt: '2024-01-01T00:00:00.000',
        updatedAt: '2024-01-02T00:00:00.000',
      );
      final map = f.toMap();
      final restored = FormModel.fromMap(map);
      expect(restored.id, 42);
      expect(restored.especialista, 'Lagu');
      expect(restored.evento, 'Test');
      expect(restored.venue, 'V');
      expect(restored.cumplimientoNuevoVenue, 100.0);
      expect(restored.cumplimientoNuevoEvento, 80.0);
      expect(restored.cumplimientoModificables, 50.0);
      expect(restored.total, 75.0);
      expect(restored.createdAt, '2024-01-01T00:00:00.000');
    });

    test('fromMap maneja campos null con defaults', () {
      final restored = FormModel.fromMap(<String, Object?>{
        'fecha': '2024-06-01',
        'especialista': 'X',
        'evento': 'Y',
        'created_at': 'x',
        'updated_at': 'y',
      });
      expect(restored.id, isNull);
      expect(restored.venue, '');
      expect(restored.cumplimientoNuevoVenue, 0.0);
      expect(restored.total, 0.0);
    });

    test('isNew es false si tiene id', () {
      final f = FormModel.empty().copyWith(id: 1);
      expect(f.isNew, isFalse);
    });
  });
}
