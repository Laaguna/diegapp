import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'diegapp.db';
  static const int _dbVersion = 1;
  static const String tableForms = 'forms';

  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableForms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        especialista TEXT NOT NULL,
        evento TEXT NOT NULL,
        venue TEXT DEFAULT '',
        mapa TEXT DEFAULT '',
        taquilla TEXT DEFAULT '',
        configuracion_canales TEXT DEFAULT '',
        configuracion_show TEXT DEFAULT '',
        tyc TEXT DEFAULT '',
        imagenes TEXT DEFAULT '',
        tarifas TEXT DEFAULT '',
        holds TEXT DEFAULT '',
        preventas TEXT DEFAULT '',
        validadores TEXT DEFAULT '',
        mapa_silleteria TEXT DEFAULT '',
        cumplimiento_nuevo_venue REAL DEFAULT 0.0,
        cumplimiento_nuevo_evento REAL DEFAULT 0.0,
        cumplimiento_modificables REAL DEFAULT 0.0,
        total REAL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_forms_fecha ON $tableForms(fecha)',
    );
    await db.execute(
      'CREATE INDEX idx_forms_especialista ON $tableForms(especialista)',
    );
    await db.execute(
      'CREATE INDEX idx_forms_evento ON $tableForms(evento)',
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
