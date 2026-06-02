import '../models/form_model.dart';

({int rellenos, int total}) _contarRellenos(List<String> values) {
  var rellenos = 0;
  for (final v in values) {
    if (v.trim().isNotEmpty) rellenos++;
  }
  return (rellenos: rellenos, total: values.length);
}

double _porcentaje(int rellenos, int total) {
  if (total == 0) return 0.0;
  return (rellenos / total) * 100.0;
}

double calcularCumplimientoNuevoVenue(FormModel f) {
  final r = _contarRellenos([f.venue, f.mapa, f.taquilla]);
  return _porcentaje(r.rellenos, r.total);
}

double calcularCumplimientoNuevoEvento(FormModel f) {
  final r = _contarRellenos([
    f.configuracionCanales,
    f.configuracionShow,
    f.tyc,
    f.imagenes,
    f.tarifas,
  ]);
  return _porcentaje(r.rellenos, r.total);
}

double calcularCumplimientoModificables(FormModel f) {
  final r = _contarRellenos([
    f.holds,
    f.preventas,
    f.validadores,
    f.mapaSilleteria,
  ]);
  return _porcentaje(r.rellenos, r.total);
}

double calcularTotal(FormModel f) {
  final all = [
    f.venue,
    f.mapa,
    f.taquilla,
    f.configuracionCanales,
    f.configuracionShow,
    f.tyc,
    f.imagenes,
    f.tarifas,
    f.holds,
    f.preventas,
    f.validadores,
    f.mapaSilleteria,
  ];
  final r = _contarRellenos(all);
  return _porcentaje(r.rellenos, r.total);
}

Map<String, double> cumplimientoValues(FormModel f) {
  return {
    'nuevo_venue': calcularCumplimientoNuevoVenue(f),
    'nuevo_evento': calcularCumplimientoNuevoEvento(f),
    'modificables': calcularCumplimientoModificables(f),
    'total': calcularTotal(f),
  };
}
