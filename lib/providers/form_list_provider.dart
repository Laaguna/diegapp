import 'package:flutter/foundation.dart';
import '../database/form_dao.dart';
import '../models/form_model.dart';

class FormListProvider extends ChangeNotifier {
  FormListProvider([FormDAO? dao]) : _dao = dao ?? FormDAO();

  final FormDAO _dao;

  final List<FormModel> _forms = [];
  List<FormModel> get forms => List.unmodifiable(_forms);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _filterEspecialista;
  String? _filterEvento;
  String? _filterFecha;
  String? get filterEspecialista => _filterEspecialista;
  String? get filterEvento => _filterEvento;
  String? get filterFecha => _filterFecha;

  final List<String> _especialistas = [];
  final List<String> _eventos = [];
  List<String> get especialistas => List.unmodifiable(_especialistas);
  List<String> get eventos => List.unmodifiable(_eventos);

  bool get hasActiveFilters =>
      (_filterEspecialista?.isNotEmpty ?? false) ||
      (_filterEvento?.isNotEmpty ?? false) ||
      _filterFecha != null;

  FormFilters get _currentFilters => FormFilters(
        especialista: _filterEspecialista,
        evento: _filterEvento,
        fecha: _filterFecha,
      );

  Future<void> loadForms() async {
    _isLoading = true;
    notifyListeners();
    try {
      final loaded = await _dao.getAll(filters: _currentFilters);
      _forms
        ..clear()
        ..addAll(loaded);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDistinctValues() async {
    final esp = await _dao.getDistinctEspecialistas();
    final ev = await _dao.getDistinctEventos();
    _especialistas
      ..clear()
      ..addAll(esp);
    _eventos
      ..clear()
      ..addAll(ev);
    notifyListeners();
  }

  void setFilterEspecialista(String? value) {
    _filterEspecialista = (value == null || value.isEmpty) ? null : value;
    loadForms();
  }

  void setFilterEvento(String? value) {
    _filterEvento = (value == null || value.isEmpty) ? null : value;
    loadForms();
  }

  void setFilterFecha(String? value) {
    _filterFecha = value;
    loadForms();
  }

  void clearFilters() {
    _filterEspecialista = null;
    _filterEvento = null;
    _filterFecha = null;
    loadForms();
  }

  Future<void> deleteForm(int id) async {
    await _dao.delete(id);
    await loadForms();
  }

  Future<FormModel?> duplicateForm(int id) async {
    final original = await _dao.getById(id);
    if (original == null) return null;
    final copy = original.copyWith(
      id: null,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    final newId = await _dao.insert(copy);
    await loadForms();
    return copy.copyWith(id: newId);
  }
}
