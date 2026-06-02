import 'package:flutter/foundation.dart';
import '../database/form_dao.dart';
import '../models/form_model.dart';
import '../utils/calculations.dart' as calc;

class FormProvider extends ChangeNotifier {
  FormProvider([FormDAO? dao]) : _dao = dao ?? FormDAO();

  final FormDAO _dao;

  FormModel? _current;
  FormModel? get current => _current;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Map<String, double> _cumplimientoValues = const {};
  Map<String, double> get cumplimientoValues => _cumplimientoValues;

  void _recalculate() {
    final c = _current;
    if (c == null) {
      _cumplimientoValues = const {};
    } else {
      _cumplimientoValues = calc.cumplimientoValues(c);
    }
  }

  void createNew() {
    _current = FormModel.empty();
    _recalculate();
    notifyListeners();
  }

  Future<void> load(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _current = await _dao.getById(id);
      _recalculate();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateField(String field, String value) {
    final c = _current;
    if (c == null) return;
    FormModel updated = switch (field) {
      'fecha' => c.copyWith(fecha: value),
      'especialista' => c.copyWith(especialista: value),
      'evento' => c.copyWith(evento: value),
      'venue' => c.copyWith(venue: value),
      'mapa' => c.copyWith(mapa: value),
      'taquilla' => c.copyWith(taquilla: value),
      'configuracionCanales' => c.copyWith(configuracionCanales: value),
      'configuracionShow' => c.copyWith(configuracionShow: value),
      'tyc' => c.copyWith(tyc: value),
      'imagenes' => c.copyWith(imagenes: value),
      'tarifas' => c.copyWith(tarifas: value),
      'holds' => c.copyWith(holds: value),
      'preventas' => c.copyWith(preventas: value),
      'validadores' => c.copyWith(validadores: value),
      'mapaSilleteria' => c.copyWith(mapaSilleteria: value),
      _ => c,
    };
    _current = updated;
    _recalculate();
    notifyListeners();
  }

  Future<int?> save() async {
    final c = _current;
    if (c == null) return null;
    _isSaving = true;
    notifyListeners();
    try {
      if (c.id == null) {
        return await _dao.insert(c);
      }
      await _dao.update(c);
      return c.id;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> delete() async {
    final c = _current;
    if (c?.id == null) return;
    await _dao.delete(c!.id!);
    _current = null;
    notifyListeners();
  }
}
