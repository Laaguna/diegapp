import 'package:flutter/material.dart' show DateTimeRange;
import 'package:sqflite/sqflite.dart';
import '../models/form_model.dart';
import 'database_helper.dart';
import '../utils/calculations.dart';

class FormFilters {
  const FormFilters({
    this.especialista,
    this.evento,
    this.fecha,
    this.fechaInicio,
    this.fechaFin,
  });

  final String? especialista;
  final String? evento;
  final String? fecha;
  final String? fechaInicio;
  final String? fechaFin;

  bool get isEmpty =>
      (especialista == null || especialista!.isEmpty) &&
      (evento == null || evento!.isEmpty) &&
      fecha == null &&
      fechaInicio == null &&
      fechaFin == null;
}

class MonthlyTrend {
  const MonthlyTrend({required this.year, required this.month, required this.promedio});
  final int year;
  final int month;
  final double promedio;

  String get label {
    const meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${meses[month - 1]} $year';
  }
}

class DashboardStats {
  const DashboardStats({
    required this.totalForms,
    required this.promedioTotal,
    required this.eventosCompletados,
    required this.eventosPendientes,
    required this.promedioPorEspecialista,
    required this.promedioPorGrupo,
    required this.tendenciaMensual,
    required this.peorCumplimiento,
  });

  factory DashboardStats.empty() => const DashboardStats(
        totalForms: 0,
        promedioTotal: 0,
        eventosCompletados: 0,
        eventosPendientes: 0,
        promedioPorEspecialista: {},
        promedioPorGrupo: {},
        tendenciaMensual: [],
        peorCumplimiento: [],
      );

  final int totalForms;
  final double promedioTotal;
  final int eventosCompletados;
  final int eventosPendientes;
  final Map<String, double> promedioPorEspecialista;
  final Map<String, double> promedioPorGrupo;
  final List<MonthlyTrend> tendenciaMensual;
  final List<FormModel> peorCumplimiento;

  bool get isEmpty => totalForms == 0;
}

class FormDAO {
  FormDAO([DatabaseHelper? helper])
      : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  Future<Database> get _db async => _helper.database;

  Future<int> insert(FormModel form) async {
    final recalculated = form.copyWith(
      updatedAt: DateTime.now().toIso8601String(),
    );
    final withCumpl = _applyCumplimiento(recalculated);
    final db = await _db;
    return db.insert(DatabaseHelper.tableForms, withCumpl.toMap());
  }

  Future<int> update(FormModel form) async {
    if (form.id == null) {
      throw ArgumentError('Cannot update a form without id');
    }
    final recalculated = form.copyWith(
      updatedAt: DateTime.now().toIso8601String(),
    );
    final withCumpl = _applyCumplimiento(recalculated);
    final db = await _db;
    return db.update(
      DatabaseHelper.tableForms,
      withCumpl.toMap(),
      where: 'id = ?',
      whereArgs: [form.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete(
      DatabaseHelper.tableForms,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<FormModel?> getById(int id) async {
    final db = await _db;
    final rows = await db.query(
      DatabaseHelper.tableForms,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return FormModel.fromMap(rows.first);
  }

  Future<List<FormModel>> getAll({FormFilters filters = const FormFilters()}) async {
    final db = await _db;
    final where = <String>[];
    final args = <Object?>[];
    if (filters.especialista != null && filters.especialista!.isNotEmpty) {
      where.add('especialista = ?');
      args.add(filters.especialista);
    }
    if (filters.evento != null && filters.evento!.isNotEmpty) {
      where.add('evento = ?');
      args.add(filters.evento);
    }
    if (filters.fecha != null) {
      where.add('fecha = ?');
      args.add(filters.fecha);
    }
    if (filters.fechaInicio != null) {
      where.add('fecha >= ?');
      args.add(filters.fechaInicio);
    }
    if (filters.fechaFin != null) {
      where.add('fecha <= ?');
      args.add(filters.fechaFin);
    }
    final rows = await db.query(
      DatabaseHelper.tableForms,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'fecha DESC, id DESC',
    );
    return rows.map(FormModel.fromMap).toList();
  }

  Future<List<String>> getDistinctEspecialistas() async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT DISTINCT especialista FROM ${DatabaseHelper.tableForms} '
      'WHERE especialista <> "" ORDER BY especialista ASC',
    );
    return rows.map((r) => r['especialista'] as String).toList();
  }

  Future<List<String>> getDistinctEventos() async {
    final db = await _db;
    final rows = await db.rawQuery(
      'SELECT DISTINCT evento FROM ${DatabaseHelper.tableForms} '
      'WHERE evento <> "" ORDER BY evento ASC',
    );
    return rows.map((r) => r['evento'] as String).toList();
  }

  Future<DashboardStats> getDashboardStats({
    FormFilters filters = const FormFilters(),
  }) async {
    final forms = await getAll(filters: filters);
    if (forms.isEmpty) return DashboardStats.empty();

    final total = forms.length;
    final sumTotal = forms.fold<double>(0, (acc, f) => acc + f.total);
    final sumVenue =
        forms.fold<double>(0, (acc, f) => acc + f.cumplimientoNuevoVenue);
    final sumEvento =
        forms.fold<double>(0, (acc, f) => acc + f.cumplimientoNuevoEvento);
    final sumModif =
        forms.fold<double>(0, (acc, f) => acc + f.cumplimientoModificables);
    final completados = forms.where((f) => f.total >= 80).length;

    final byEsp = <String, List<double>>{};
    for (final f in forms) {
      byEsp.putIfAbsent(f.especialista, () => []).add(f.total);
    }
    final promedioPorEsp = byEsp.map(
      (k, v) => MapEntry(k, v.reduce((a, b) => a + b) / v.length),
    );

    final tendencia = _computeMonthlyTrend(forms);
    final peor = _computePeorCumplimiento(forms, limit: 5);

    return DashboardStats(
      totalForms: total,
      promedioTotal: sumTotal / total,
      eventosCompletados: completados,
      eventosPendientes: total - completados,
      promedioPorEspecialista: promedioPorEsp,
      promedioPorGrupo: {
        'Nuevo Venue': sumVenue / total,
        'Nuevo Evento': sumEvento / total,
        'Modificables': sumModif / total,
      },
      tendenciaMensual: tendencia,
      peorCumplimiento: peor,
    );
  }

  Future<Map<String, double>> getPromedioPorEspecialista({
    FormFilters filters = const FormFilters(),
  }) async {
    final forms = await getAll(filters: filters);
    final byEsp = <String, List<double>>{};
    for (final f in forms) {
      byEsp.putIfAbsent(f.especialista, () => []).add(f.total);
    }
    return byEsp.map(
      (k, v) => MapEntry(k, v.reduce((a, b) => a + b) / v.length),
    );
  }

  Future<Map<String, double>> getPromedioPorGrupo({
    FormFilters filters = const FormFilters(),
  }) async {
    final forms = await getAll(filters: filters);
    if (forms.isEmpty) return const {};
    final n = forms.length;
    final sumVenue =
        forms.fold<double>(0, (acc, f) => acc + f.cumplimientoNuevoVenue);
    final sumEvento =
        forms.fold<double>(0, (acc, f) => acc + f.cumplimientoNuevoEvento);
    final sumModif =
        forms.fold<double>(0, (acc, f) => acc + f.cumplimientoModificables);
    return {
      'Nuevo Venue': sumVenue / n,
      'Nuevo Evento': sumEvento / n,
      'Modificables': sumModif / n,
    };
  }

  Future<List<MonthlyTrend>> getTendenciaMensual({
    FormFilters filters = const FormFilters(),
  }) async {
    final forms = await getAll(filters: filters);
    return _computeMonthlyTrend(forms);
  }

  Future<List<FormModel>> getPeorCumplimiento({
    FormFilters filters = const FormFilters(),
    int limit = 5,
  }) async {
    final forms = await getAll(filters: filters);
    return _computePeorCumplimiento(forms, limit: limit);
  }

  List<MonthlyTrend> _computeMonthlyTrend(List<FormModel> forms) {
    if (forms.isEmpty) return const [];
    final grouped = <String, List<double>>{};
    final order = <String>[];
    for (final f in forms) {
      final fecha = DateTime.tryParse(f.fecha);
      if (fecha == null) continue;
      final key = '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}';
      if (!grouped.containsKey(key)) order.add(key);
      grouped.putIfAbsent(key, () => []).add(f.total);
    }
    order.sort();
    return order.map((key) {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final values = grouped[key]!;
      final avg = values.reduce((a, b) => a + b) / values.length;
      return MonthlyTrend(year: year, month: month, promedio: avg);
    }).toList();
  }

  List<FormModel> _computePeorCumplimiento(
    List<FormModel> forms, {
    int limit = 5,
  }) {
    final sorted = [...forms]..sort((a, b) => a.total.compareTo(b.total));
    return sorted.take(limit).toList();
  }

  FormModel _applyCumplimiento(FormModel form) {
    return form.copyWith(
      cumplimientoNuevoVenue: calcularCumplimientoNuevoVenue(form),
      cumplimientoNuevoEvento: calcularCumplimientoNuevoEvento(form),
      cumplimientoModificables: calcularCumplimientoModificables(form),
      total: calcularTotal(form),
    );
  }
}

extension FormFiltersFromDateRange on FormFilters {
  static FormFilters fromDateTimeRange({
    String? especialista,
    String? evento,
    DateTimeRange? range,
  }) {
    if (range == null) {
      return FormFilters(
        especialista: especialista,
        evento: evento,
      );
    }
    final start = '${range.start.year.toString().padLeft(4, '0')}-'
        '${range.start.month.toString().padLeft(2, '0')}-'
        '${range.start.day.toString().padLeft(2, '0')}';
    final end = '${range.end.year.toString().padLeft(4, '0')}-'
        '${range.end.month.toString().padLeft(2, '0')}-'
        '${range.end.day.toString().padLeft(2, '0')}';
    return FormFilters(
      especialista: especialista,
      evento: evento,
      fechaInicio: start,
      fechaFin: end,
    );
  }
}
