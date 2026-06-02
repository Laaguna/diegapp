import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import '../database/form_dao.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider([FormDAO? dao]) : _dao = dao ?? FormDAO();

  final FormDAO _dao;

  String? _filterEvento;
  String? _filterEspecialista;
  DateTimeRange? _filterFecha;
  String? get filterEvento => _filterEvento;
  String? get filterEspecialista => _filterEspecialista;
  DateTimeRange? get filterFecha => _filterFecha;

  final List<String> _eventos = [];
  final List<String> _especialistas = [];
  List<String> get eventos => List.unmodifiable(_eventos);
  List<String> get especialistas => List.unmodifiable(_especialistas);

  DashboardStats _stats = DashboardStats.empty();
  DashboardStats get stats => _stats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool get hasActiveFilters =>
      (_filterEvento?.isNotEmpty ?? false) ||
      (_filterEspecialista?.isNotEmpty ?? false) ||
      _filterFecha != null;

  FormFilters get _currentFilters => FormFilters(
        evento: _filterEvento,
        especialista: _filterEspecialista,
        fechaInicio: _filterFecha == null
            ? null
            : _formatDate(_filterFecha!.start),
        fechaFin:
            _filterFecha == null ? null : _formatDate(_filterFecha!.end),
      );

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

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

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();
    try {
      _stats = await _dao.getDashboardStats(filters: _currentFilters);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setFilterEvento(String? value) async {
    _filterEvento = (value == null || value.isEmpty) ? null : value;
    await loadStats();
  }

  Future<void> setFilterEspecialista(String? value) async {
    _filterEspecialista = (value == null || value.isEmpty) ? null : value;
    await loadStats();
  }

  Future<void> setFilterFecha(DateTimeRange? value) async {
    _filterFecha = value;
    await loadStats();
  }

  Future<void> clearFilters() async {
    _filterEvento = null;
    _filterEspecialista = null;
    _filterFecha = null;
    await loadStats();
  }

  Future<void> refresh() async {
    await loadDistinctValues();
    await loadStats();
  }
}
