import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/form_list_provider.dart';
import '../../providers/form_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/glass_section.dart';
import '../../widgets/glass_text_field.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key, this.formId});

  final int? formId;

  bool get isEditing => formId != null;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  bool _initialized = false;

  String _fmtDate(String raw) {
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    return DateFormat('dd/MM/yyyy').format(d);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    if (widget.isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<FormProvider>().load(widget.formId!);
      });
    }
  }

  Future<void> _pickDate() async {
    final provider = context.read<FormProvider>();
    final current = provider.current;
    if (current == null) return;
    final initial = DateTime.tryParse(current.fecha) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      provider.updateField('fecha', formatted);
    }
  }

  Future<void> _save() async {
    HapticFeedback.lightImpact();
    final provider = context.read<FormProvider>();
    final c = provider.current;
    if (c == null) return;
    if (c.especialista.trim().isEmpty || c.evento.trim().isEmpty) {
      HapticFeedback.heavyImpact();
      showAppSnackBar(
        context,
        const Text('Especialista y Evento son obligatorios'),
        duration: const Duration(seconds: 2),
      );
      return;
    }
    final wasNew = c.id == null;
    final id = await provider.save();
    if (!mounted) return;
    if (id != null) {
      HapticFeedback.mediumImpact();
      context.go('/form/$id');
      if (!mounted) return;
      showAppSnackBar(
        context,
        const Text('Formulario guardado ✅'),
        action: wasNew
            ? SnackBarAction(
                label: 'Deshacer',
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  final listProvider = context.read<FormListProvider>();
                  final router = GoRouter.of(context);
                  await listProvider.deleteForm(id);
                  if (!mounted) return;
                  router.go('/');
                },
              )
            : null,
      );
    }
  }

  Future<void> _deleteFromEdit(int id) async {
    final provider = context.read<FormProvider>();
    final form = provider.current;
    if (form == null) return;
    final confirmed = await confirmDelete(context, form);
    if (confirmed != true || !mounted) return;
    HapticFeedback.mediumImpact();
    await context.read<FormListProvider>().deleteForm(id);
    if (!mounted) return;
    context.go('/');
    if (!context.mounted) return;
    showAppSnackBar(context, const Text('Formulario eliminado'));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormProvider>(
      builder: (context, provider, _) {
        final c = provider.current;
        final title = c == null
            ? 'Cargando...'
            : (widget.isEditing
                ? (c.evento.isEmpty ? 'Editando' : 'Editando: ${c.evento}')
                : 'Nuevo Formulario');

        return GlassScaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => context.canPop() ? context.pop() : context.go('/'),
            ),
            actions: [
              if (widget.isEditing && c?.id != null)
                IconButton(
                  tooltip: 'Exportar PDF',
                  onPressed: () => context.push('/pdf-preview/${c!.id}'),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                ),
              if (widget.isEditing && c?.id != null)
                IconButton(
                  tooltip: 'Eliminar',
                  onPressed: () => _deleteFromEdit(c!.id!),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.dangerColor,
                  ),
                ),
              TextButton.icon(
                onPressed: provider.isSaving ? null : _save,
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text(
                  'Guardar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor:
                      AppTheme.primaryColor.withValues(alpha: 0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: c == null
              ? const Center(child: CircularProgressIndicator())
              : _buildForm(context, provider),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, FormProvider provider) {
    final c = provider.current!;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        children: [
          GlassSection(
            title: 'Información General',
            icon: Icons.info_outline,
            child: Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  borderRadius: 12,
                  child: Row(
                    children: [
                      const Text('📅', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'FECHA: ${_fmtDate(c.fecha)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _pickDate,
                        child: const Text('Cambiar'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  label: 'Especialista',
                  initialValue: c.especialista,
                  onChanged: (v) => provider.updateField('especialista', v),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  label: 'Evento',
                  initialValue: c.evento,
                  onChanged: (v) => provider.updateField('evento', v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassSection(
            title: 'Nuevo Venue',
            icon: Icons.stadium_outlined,
            child: Column(
              children: [
                GlassTextField(
                  label: 'Venue',
                  initialValue: c.venue,
                  onChanged: (v) => provider.updateField('venue', v),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  label: 'Mapa',
                  initialValue: c.mapa,
                  onChanged: (v) => provider.updateField('mapa', v),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  label: 'Taquilla',
                  initialValue: c.taquilla,
                  onChanged: (v) => provider.updateField('taquilla', v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassSection(
            title: 'Nuevo Evento',
            icon: Icons.event_outlined,
            child: Column(
              children: [
                GlassTextField(
                  label: 'Configuración Canales',
                  initialValue: c.configuracionCanales,
                  onChanged: (v) =>
                      provider.updateField('configuracionCanales', v),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  label: 'Configuración Show',
                  initialValue: c.configuracionShow,
                  onChanged: (v) =>
                      provider.updateField('configuracionShow', v),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  label: 'T&C',
                  initialValue: c.tyc,
                  onChanged: (v) => provider.updateField('tyc', v),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  label: 'Imágenes',
                  initialValue: c.imagenes,
                  onChanged: (v) => provider.updateField('imagenes', v),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  label: 'Tarifas',
                  initialValue: c.tarifas,
                  onChanged: (v) => provider.updateField('tarifas', v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassSection(
            title: 'Modificables',
            icon: Icons.build_outlined,
            child: Column(
              children: [
                GlassTextField(
                  label: 'Holds',
                  initialValue: c.holds,
                  onChanged: (v) => provider.updateField('holds', v),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  label: 'Preventas',
                  initialValue: c.preventas,
                  onChanged: (v) => provider.updateField('preventas', v),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  label: 'Validadores',
                  initialValue: c.validadores,
                  onChanged: (v) => provider.updateField('validadores', v),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  label: 'Mapa Silletería',
                  initialValue: c.mapaSilleteria,
                  onChanged: (v) =>
                      provider.updateField('mapaSilleteria', v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassSection(
            title: 'Cumplimiento',
            icon: Icons.bar_chart_outlined,
            padding: EdgeInsets.zero,
            child: _CumplimientoPanel(values: provider.cumplimientoValues),
          ),
          const SizedBox(height: 24),
          GlassButton(
            label: provider.isSaving ? 'Guardando...' : 'Guardar Formulario',
            icon: Icons.save_outlined,
            variant: GlassButtonVariant.primary,
            expand: true,
            onPressed: provider.isSaving ? null : _save,
          ),
        ],
      ),
    );
  }
}

class _CumplimientoPanel extends StatelessWidget {
  const _CumplimientoPanel({required this.values});

  final Map<String, double> values;

  @override
  Widget build(BuildContext context) {
    final entries = <_CumplEntry>[
      _CumplEntry(
          'Nuevo Venue', values['nuevo_venue'] ?? 0, Icons.stadium_outlined),
      _CumplEntry('Nuevo Evento', values['nuevo_evento'] ?? 0,
          Icons.event_outlined),
      _CumplEntry(
          'Modificables', values['modificables'] ?? 0, Icons.build_outlined),
      _CumplEntry('TOTAL', values['total'] ?? 0, Icons.flag_outlined,
          emphasize: true),
    ];

    return Column(
      children: [
        for (final e in entries) ...[
          _CumplimientoRow(entry: e),
          if (e != entries.last) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _CumplEntry {
  const _CumplEntry(this.label, this.value, this.icon, {this.emphasize = false});
  final String label;
  final double value;
  final IconData icon;
  final bool emphasize;
}

class _CumplimientoRow extends StatelessWidget {
  const _CumplimientoRow({required this.entry});
  final _CumplEntry entry;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.cumplimientoColor(entry.value);
    return Row(
      children: [
        Icon(entry.icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            entry.label,
            style: TextStyle(
              fontSize: entry.emphasize ? 15 : 13,
              fontWeight: entry.emphasize ? FontWeight.w700 : FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          width: 110,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: entry.value / 100),
            duration: const Duration(milliseconds: 350),
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: entry.emphasize ? 10 : 8,
              borderRadius: BorderRadius.circular(8),
              backgroundColor:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${entry.value.toStringAsFixed(0)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: entry.emphasize ? 15 : 13,
          ),
        ),
      ],
    );
  }
}
