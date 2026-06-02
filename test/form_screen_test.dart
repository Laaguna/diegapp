import 'package:diegapp/models/form_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diegapp/utils/calculations.dart';

void main() {
  test('flujo: crear → completar → verificar cumplimiento', () {
    final f = FormModel.empty().copyWith(
      especialista: 'Lagu',
      evento: 'Concierto',
      venue: 'V',
      mapa: 'M',
      taquilla: 'T',
    );
    expect(calcularCumplimientoNuevoVenue(f), 100.0);
    expect(calcularCumplimientoNuevoEvento(f), 0.0);
    expect(calcularCumplimientoModificables(f), 0.0);
    expect(calcularTotal(f), closeTo(25.0, 0.01));
  });

  test('formulario 100% completo', () {
    final f = FormModel.empty().copyWith(
      especialista: 'L',
      evento: 'E',
      venue: 'A',
      mapa: 'B',
      taquilla: 'C',
      configuracionCanales: 'D',
      configuracionShow: 'E',
      tyc: 'F',
      imagenes: 'G',
      tarifas: 'H',
      holds: 'I',
      preventas: 'J',
      validadores: 'K',
      mapaSilleteria: 'L',
    );
    expect(calcularTotal(f), 100.0);
    final values = cumplimientoValues(f);
    expect(values['total'], 100.0);
    expect(values['nuevo_venue'], 100.0);
    expect(values['nuevo_evento'], 100.0);
    expect(values['modificables'], 100.0);
  });
}
