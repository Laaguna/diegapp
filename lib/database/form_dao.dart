import 'package:sqflite/sqflite.dart';
import '../models/form_model.dart';
import 'database_helper.dart';
import '../utils/calculations.dart';

class FormFilters {
  const FormFilters({
    this.especialista,
    this.evento,
    this.fecha,
  });

  final String? especialista;
  final String? evento;
  final String? fecha;

  bool get isEmpty =>
      (especialista == null || especialista!.isEmpty) &&
      (evento == null || evento!.isEmpty) &&
      fecha == null;
}

class DashboardStats {
  const DashboardStats({
    required this.totalForms,
    required this.promedioTotal,
    required this.completados,
    required this.pendientes,
    required this.promedioPorEspecialista,
    required this.promedioPorGrupo,
  });

  final int totalForms;
  final double promedioTotal;
  final int completados;
  final int pendientes;
  final Map<String, double> promedioPorEspecialista;
  final Map<String, double> promedioPorGrupo;
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
    if (forms.isEmpty) {
      return const DashboardStats(
        totalForms: 0,
        promedioTotal: 0,
        completados: 0,
        pendientes: 0,
        promedioPorEspecialista: {},
        promedioPorGrupo: {},
      );
    }

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

    return DashboardStats(
      totalForms: total,
      promedioTotal: sumTotal / total,
      completados: completados,
      pendientes: total - completados,
      promedioPorEspecialista: promedioPorEsp,
      promedioPorGrupo: {
        'Nuevo Venue': sumVenue / total,
        'Nuevo Evento': sumEvento / total,
        'Modificables': sumModif / total,
      },
    );
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
