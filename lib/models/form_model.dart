import 'package:intl/intl.dart';

class FormModel {
  final int? id;
  final String fecha;
  final String especialista;
  final String evento;
  final String venue;
  final String mapa;
  final String taquilla;
  final String configuracionCanales;
  final String configuracionShow;
  final String tyc;
  final String imagenes;
  final String tarifas;
  final String holds;
  final String preventas;
  final String validadores;
  final String mapaSilleteria;
  final double cumplimientoNuevoVenue;
  final double cumplimientoNuevoEvento;
  final double cumplimientoModificables;
  final double total;
  final String createdAt;
  final String updatedAt;

  const FormModel({
    this.id,
    required this.fecha,
    required this.especialista,
    required this.evento,
    this.venue = '',
    this.mapa = '',
    this.taquilla = '',
    this.configuracionCanales = '',
    this.configuracionShow = '',
    this.tyc = '',
    this.imagenes = '',
    this.tarifas = '',
    this.holds = '',
    this.preventas = '',
    this.validadores = '',
    this.mapaSilleteria = '',
    this.cumplimientoNuevoVenue = 0.0,
    this.cumplimientoNuevoEvento = 0.0,
    this.cumplimientoModificables = 0.0,
    this.total = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FormModel.empty() {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final iso = now.toIso8601String();
    return FormModel(
      fecha: today,
      especialista: '',
      evento: '',
      createdAt: iso,
      updatedAt: iso,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'fecha': fecha,
      'especialista': especialista,
      'evento': evento,
      'venue': venue,
      'mapa': mapa,
      'taquilla': taquilla,
      'configuracion_canales': configuracionCanales,
      'configuracion_show': configuracionShow,
      'tyc': tyc,
      'imagenes': imagenes,
      'tarifas': tarifas,
      'holds': holds,
      'preventas': preventas,
      'validadores': validadores,
      'mapa_silleteria': mapaSilleteria,
      'cumplimiento_nuevo_venue': cumplimientoNuevoVenue,
      'cumplimiento_nuevo_evento': cumplimientoNuevoEvento,
      'cumplimiento_modificables': cumplimientoModificables,
      'total': total,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory FormModel.fromMap(Map<String, Object?> map) {
    return FormModel(
      id: map['id'] as int?,
      fecha: (map['fecha'] as String?) ?? '',
      especialista: (map['especialista'] as String?) ?? '',
      evento: (map['evento'] as String?) ?? '',
      venue: (map['venue'] as String?) ?? '',
      mapa: (map['mapa'] as String?) ?? '',
      taquilla: (map['taquilla'] as String?) ?? '',
      configuracionCanales: (map['configuracion_canales'] as String?) ?? '',
      configuracionShow: (map['configuracion_show'] as String?) ?? '',
      tyc: (map['tyc'] as String?) ?? '',
      imagenes: (map['imagenes'] as String?) ?? '',
      tarifas: (map['tarifas'] as String?) ?? '',
      holds: (map['holds'] as String?) ?? '',
      preventas: (map['preventas'] as String?) ?? '',
      validadores: (map['validadores'] as String?) ?? '',
      mapaSilleteria: (map['mapa_silleteria'] as String?) ?? '',
      cumplimientoNuevoVenue: (map['cumplimiento_nuevo_venue'] as num?)?.toDouble() ?? 0.0,
      cumplimientoNuevoEvento: (map['cumplimiento_nuevo_evento'] as num?)?.toDouble() ?? 0.0,
      cumplimientoModificables: (map['cumplimiento_modificables'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: (map['created_at'] as String?) ?? '',
      updatedAt: (map['updated_at'] as String?) ?? '',
    );
  }

  FormModel copyWith({
    int? id,
    String? fecha,
    String? especialista,
    String? evento,
    String? venue,
    String? mapa,
    String? taquilla,
    String? configuracionCanales,
    String? configuracionShow,
    String? tyc,
    String? imagenes,
    String? tarifas,
    String? holds,
    String? preventas,
    String? validadores,
    String? mapaSilleteria,
    double? cumplimientoNuevoVenue,
    double? cumplimientoNuevoEvento,
    double? cumplimientoModificables,
    double? total,
    String? createdAt,
    String? updatedAt,
  }) {
    return FormModel(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      especialista: especialista ?? this.especialista,
      evento: evento ?? this.evento,
      venue: venue ?? this.venue,
      mapa: mapa ?? this.mapa,
      taquilla: taquilla ?? this.taquilla,
      configuracionCanales: configuracionCanales ?? this.configuracionCanales,
      configuracionShow: configuracionShow ?? this.configuracionShow,
      tyc: tyc ?? this.tyc,
      imagenes: imagenes ?? this.imagenes,
      tarifas: tarifas ?? this.tarifas,
      holds: holds ?? this.holds,
      preventas: preventas ?? this.preventas,
      validadores: validadores ?? this.validadores,
      mapaSilleteria: mapaSilleteria ?? this.mapaSilleteria,
      cumplimientoNuevoVenue: cumplimientoNuevoVenue ?? this.cumplimientoNuevoVenue,
      cumplimientoNuevoEvento: cumplimientoNuevoEvento ?? this.cumplimientoNuevoEvento,
      cumplimientoModificables: cumplimientoModificables ?? this.cumplimientoModificables,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isNew => id == null;
}
