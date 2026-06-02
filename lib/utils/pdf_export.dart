import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/form_model.dart';
import 'calculations.dart';

class PdfExport {
  PdfExport._();

  static Future<List<int>> generate(FormModel form) async {
    final doc = pw.Document(
      title: 'DiegApp — ${form.evento.isEmpty ? "Formulario" : form.evento}',
      author: 'DiegApp',
    );

    final generatedAt =
        DateFormat("dd/MM/yyyy HH:mm").format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(
          marginLeft: PdfPageFormat.inch,
          marginRight: PdfPageFormat.inch,
          marginTop: PdfPageFormat.inch,
          marginBottom: PdfPageFormat.inch,
        ),
        header: (ctx) => ctx.pageNumber == 1
            ? pw.SizedBox.shrink()
            : _pageHeader(form),
        footer: (ctx) => _pageFooter(ctx, generatedAt),
        build: (ctx) => [
          _buildHeader(),
          pw.SizedBox(height: 6),
          _buildDecorativeLine(),
          pw.SizedBox(height: 18),
          _buildDatosGenerales(form),
          pw.SizedBox(height: 18),
          _buildChecklist(form),
          pw.SizedBox(height: 18),
          _buildResumenCumplimiento(form),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DiegApp',
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xFF4F46E5),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Checklist ALTA — Creación de Eventos',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDecorativeLine() {
    return pw.Container(
      height: 1.5,
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF4F46E5),
      ),
    );
  }

  static pw.Widget _buildDatosGenerales(FormModel form) {
    return _section(
      title: 'Datos Generales',
      child: pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(1),
          1: pw.FlexColumnWidth(2),
        },
        border: pw.TableBorder.symmetric(
          inside: pw.BorderSide(
            color: PdfColors.grey300,
            width: 0.5,
          ),
        ),
        children: [
          _dataRow('Fecha', _formatDate(form.fecha)),
          _dataRow(
              'Especialista',
              form.especialista.isEmpty
                  ? '—'
                  : form.especialista),
          _dataRow('Evento', form.evento.isEmpty ? '—' : form.evento),
        ],
      ),
    );
  }

  static pw.TableRow _dataRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  static pw.Widget _buildChecklist(FormModel form) {
    final groups = _groupFields(form);
    return _section(
      title: 'Checklist',
      child: pw.Column(
        children: [
          for (var i = 0; i < groups.length; i++) ...[
            _groupTable(groups[i].$1, groups[i].$2),
            if (i < groups.length - 1) pw.SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  static List<(String, List<(String, String)>)> _groupFields(FormModel form) {
    return [
      (
        'Nuevo Venue',
        [
          ('VENUE', form.venue),
          ('MAPA', form.mapa),
          ('TAQUILLA', form.taquilla),
        ],
      ),
      (
        'Nuevo Evento',
        [
          ('CONFIGURACIÓN CANALES', form.configuracionCanales),
          ('CONFIGURACIÓN SHOW', form.configuracionShow),
          ('T&C', form.tyc),
          ('IMÁGENES', form.imagenes),
          ('TARIFAS', form.tarifas),
        ],
      ),
      (
        'Modificables',
        [
          ('HOLDS', form.holds),
          ('PREVENTAS', form.preventas),
          ('VALIDADORES', form.validadores),
          ('MAPA SILLETERÍA', form.mapaSilleteria),
        ],
      ),
    ];
  }

  static pw.Widget _groupTable(
    String title,
    List<(String, String)> rows,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromInt(0xFF4F46E5),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Table(
          columnWidths: const {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(3),
          },
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _cell('Campo', isHeader: true),
                _cell('Valor', isHeader: true),
              ],
            ),
            for (final r in rows)
              pw.TableRow(
                children: [
                  _cell(r.$1),
                  _cell(r.$2.isEmpty ? '—' : r.$2),
                ],
              ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _cell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildResumenCumplimiento(FormModel form) {
    final nv = calcularCumplimientoNuevoVenue(form);
    final ne = calcularCumplimientoNuevoEvento(form);
    final mod = calcularCumplimientoModificables(form);
    final total = calcularTotal(form);
    return _section(
      title: 'Resumen de Cumplimiento',
      child: pw.Table(
        columnWidths: const {
          0: pw.FlexColumnWidth(3),
          1: pw.FlexColumnWidth(1),
        },
        border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
        children: [
          _summaryRow('Nuevo Venue', nv, emphasize: false),
          _summaryRow('Nuevo Evento', ne, emphasize: false),
          _summaryRow('Modificables', mod, emphasize: false),
          _summaryRow('TOTAL', total, emphasize: true),
        ],
      ),
    );
  }

  static pw.TableRow _summaryRow(
    String label,
    double value, {
    required bool emphasize,
  }) {
    return pw.TableRow(
      decoration: pw.BoxDecoration(
        color: emphasize ? PdfColors.grey200 : PdfColors.white,
      ),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: emphasize
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
              fontSize: emphasize ? 12 : 11,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            '${value.toStringAsFixed(0)}%',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: _pdfColorForValue(value),
              fontSize: emphasize ? 12 : 11,
            ),
          ),
        ),
      ],
    );
  }

  static PdfColor _pdfColorForValue(double v) {
    if (v < 50) return PdfColor.fromInt(0xFFEF4444);
    if (v < 80) return PdfColor.fromInt(0xFFF59E0B);
    return PdfColor.fromInt(0xFF22C55E);
  }

  static pw.Widget _section({
    required String title,
    required pw.Widget child,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 8),
        child,
      ],
    );
  }

  static pw.Widget _pageHeader(FormModel form) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 6),
      margin: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
        ),
      ),
      child: pw.Text(
        form.evento.isEmpty ? 'DiegApp — Formulario' : 'DiegApp — ${form.evento}',
        style: const pw.TextStyle(
          fontSize: 9,
          color: PdfColors.grey700,
        ),
      ),
    );
  }

  static pw.Widget _pageFooter(pw.Context ctx, String generatedAt) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey400, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generado el $generatedAt por DiegApp',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            'Página ${ctx.pageNumber} de ${ctx.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(String raw) {
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    return DateFormat('dd/MM/yyyy').format(d);
  }
}
