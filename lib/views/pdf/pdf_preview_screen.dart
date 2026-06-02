import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../database/form_dao.dart';
import '../../models/form_model.dart';
import '../../utils/pdf_export.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';

class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({super.key, this.formId});

  final int? formId;

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  final _dao = FormDAO();
  Uint8List? _bytes;
  FormModel? _form;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.formId;
    if (id == null) {
      setState(() => _error = 'ID inválido');
      return;
    }
    try {
      final form = await _dao.getById(id);
      if (form == null) {
        setState(() => _error = 'Formulario no encontrado');
        return;
      }
      final bytes = await PdfExport.generate(form);
      if (!mounted) return;
      setState(() {
        _form = form;
        _bytes = Uint8List.fromList(bytes);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Error al generar PDF: $e');
    }
  }

  String _safeFileName() {
    final name = _form?.evento.isNotEmpty == true
        ? _form!.evento
        : 'formulario';
    return 'diegapp_${name.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_')}.pdf';
  }

  Future<void> _share() async {
    final bytes = _bytes;
    if (bytes == null) return;
    await Printing.sharePdf(bytes: bytes, filename: _safeFileName());
  }

  Future<void> _save() async {
    final bytes = _bytes;
    if (bytes == null) return;
    await Printing.sharePdf(bytes: bytes, filename: _safeFileName());
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Vista Previa PDF'),
        actions: [
          if (_bytes != null) ...[
            IconButton(
              tooltip: 'Compartir',
              onPressed: _share,
              icon: const Icon(Icons.share_outlined),
            ),
            IconButton(
              tooltip: 'Guardar / Imprimir',
              onPressed: _save,
              icon: const Icon(Icons.save_alt_outlined),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_bytes == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generando PDF…'),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_form != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Text('📄', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _form!.evento.isEmpty
                          ? 'Formulario #${_form!.id}'
                          : _form!.evento,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: PdfPreview(
            build: (format) async => _bytes!,
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowSharing: false,
            allowPrinting: false,
            pdfFileName: _safeFileName(),
          ),
        ),
      ],
    );
  }
}
