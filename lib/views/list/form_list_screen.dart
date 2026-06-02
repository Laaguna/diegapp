import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/form_model.dart';
import '../../providers/form_list_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';

class FormListScreen extends StatefulWidget {
  const FormListScreen({super.key});

  @override
  State<FormListScreen> createState() => _FormListScreenState();
}

class _FormListScreenState extends State<FormListScreen> {
  bool _filtersExpanded = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FormListProvider>();
      provider.loadForms();
      provider.loadDistinctValues();
    });
  }

  Future<void> _pickFilterDate() async {
    final provider = context.read<FormListProvider>();
    final initial = provider.filterFecha != null
        ? DateTime.tryParse(provider.filterFecha!) ?? DateTime.now()
        : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      provider.setFilterFecha(DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  Future<void> _showActions(FormModel form) async {
    final provider = context.read<FormListProvider>();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Duplicar formulario'),
                onTap: () async {
                  Navigator.of(sheetCtx).pop();
                  final dup = await provider.duplicateForm(form.id!);
                  if (!mounted) return;
                  if (dup != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Duplicado como #${dup.id}')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Exportar PDF'),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  context.push('/pdf-preview/${form.id}');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppTheme.dangerColor),
                title: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppTheme.dangerColor),
                ),
                onTap: () async {
                  Navigator.of(sheetCtx).pop();
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('¿Eliminar formulario?'),
                      content: Text(
                        'Se eliminará "${form.evento.isEmpty ? 'Sin nombre' : form.evento}". Esta acción no se puede deshacer.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dCtx).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(dCtx).pop(true),
                          child: const Text(
                            'Eliminar',
                            style: TextStyle(color: AppTheme.dangerColor),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await provider.deleteForm(form.id!);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: const Text('DiegApp'),
        actions: [
          IconButton(
            tooltip: _filtersExpanded ? 'Ocultar filtros' : 'Mostrar filtros',
            onPressed: () =>
                setState(() => _filtersExpanded = !_filtersExpanded),
            icon: Icon(
              _filtersExpanded ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Nuevo formulario',
            onPressed: () => context.push('/form'),
            icon: const Icon(Icons.add_circle_outline),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<FormListProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _filtersExpanded
                    ? _FiltersPanel(
                        onPickDate: _pickFilterDate,
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(child: _buildBody(context, provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, FormListProvider provider) {
    if (provider.isLoading && provider.forms.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.forms.isEmpty) {
      return _EmptyState(
        hasFilters: provider.hasActiveFilters,
        onCreate: () => context.push('/form'),
        onClearFilters: provider.clearFilters,
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadForms();
        await provider.loadDistinctValues();
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: provider.forms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final form = provider.forms[i];
          return _FormCard(
            form: form,
            onTap: () => context.push('/form/${form.id}'),
            onLongPress: () => _showActions(form),
          );
        },
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({required this.onPickDate});

  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Consumer<FormListProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AutocompleteFilterChip(
                label: 'ESPECIALISTA',
                value: provider.filterEspecialista ?? '',
                suggestions: provider.especialistas,
                onChanged: (v) {
                  if (v == null || v.isEmpty) {
                    provider.setFilterEspecialista(null);
                  } else {
                    provider.setFilterEspecialista(v);
                  }
                },
              ),
              const SizedBox(height: 8),
              _AutocompleteFilterChip(
                label: 'EVENTO',
                value: provider.filterEvento ?? '',
                suggestions: provider.eventos,
                onChanged: (v) {
                  if (v == null || v.isEmpty) {
                    provider.setFilterEvento(null);
                  } else {
                    provider.setFilterEvento(v);
                  }
                },
              ),
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                borderRadius: 12,
                child: Row(
                  children: [
                    const Text('📅', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        provider.filterFecha == null
                            ? 'FECHA: cualquier fecha'
                            : 'FECHA: ${provider.filterFecha}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onPickDate,
                      child: const Text('Elegir'),
                    ),
                    if (provider.filterFecha != null)
                      IconButton(
                        tooltip: 'Limpiar fecha',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => provider.setFilterFecha(null),
                      ),
                  ],
                ),
              ),
              if (provider.hasActiveFilters) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: provider.clearFilters,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Limpiar filtros'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AutocompleteFilterChip extends StatelessWidget {
  const _AutocompleteFilterChip({
    required this.label,
    required this.value,
    required this.suggestions,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> suggestions;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      focusNode: FocusNode(),
      optionsBuilder: (TextEditingValue tv) {
        final query = tv.text.toLowerCase();
        if (query.isEmpty) return suggestions;
        return suggestions
            .where((s) => s.toLowerCase().contains(query))
            .take(8);
      },
      onSelected: onChanged,
      fieldViewBuilder:
          (context, textController, focusNode, onFieldSubmitted) {
        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          borderRadius: 12,
          child: TextField(
            controller: textController,
            focusNode: focusNode,
            onChanged: onChanged,
            cursorColor: Theme.of(context).colorScheme.primary,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              floatingLabelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 320),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final opt = options.elementAt(i);
                  return ListTile(
                    dense: true,
                    title: Text(opt),
                    onTap: () => onSelected(opt),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.form,
    required this.onTap,
    required this.onLongPress,
  });

  final FormModel form;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.cumplimientoColor(form.total);
    final title = form.evento.isEmpty ? 'Sin nombre' : form.evento;
    return GestureDetector(
      onLongPress: onLongPress,
      child: GlassCard(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${form.fecha}  ·  ${form.especialista.isEmpty ? 'Sin especialista' : form.especialista}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: form.total / 100),
                        duration: const Duration(milliseconds: 400),
                        builder: (context, v, _) => LinearProgressIndicator(
                          value: v,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(8),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${form.total.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasFilters,
    required this.onCreate,
    required this.onClearFilters,
  });

  final bool hasFilters;
  final VoidCallback onCreate;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📋', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                hasFilters
                    ? 'Sin resultados con esos filtros'
                    : 'No hay formularios aún',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                hasFilters
                    ? 'Prueba limpiando los filtros para ver todos los registros.'
                    : '¡Crea tu primero!',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              if (hasFilters)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Limpiar filtros'),
                )
              else
                ElevatedButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: const Text('Crear formulario'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
