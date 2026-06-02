import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../database/form_dao.dart';
import '../../models/form_model.dart';
import '../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';
import '../../widgets/glass_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().refresh();
    });
  }

  Future<void> _pickDateRange() async {
    final provider = context.read<DashboardProvider>();
    final initial = provider.filterFecha ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 90)),
          end: DateTime.now(),
        );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: initial,
    );
    if (picked != null) {
      await provider.setFilterFecha(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refrescar',
            onPressed: () => context.read<DashboardProvider>().refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.stats.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _FiltersBar(
                    onPickDate: _pickDateRange,
                    onClear: provider.hasActiveFilters
                        ? () => provider.clearFilters()
                        : null,
                  ),
                  const SizedBox(height: 16),
                  if (provider.stats.isEmpty)
                    const _EmptyDashboard()
                  else ...[
                    _MetricCards(stats: provider.stats),
                    const SizedBox(height: 16),
                    _ChartRow(stats: provider.stats),
                    const SizedBox(height: 16),
                    _StackedBarCard(stats: provider.stats),
                    const SizedBox(height: 16),
                    _MonthlyTrendCard(stats: provider.stats),
                    const SizedBox(height: 16),
                    _TopPeorCumplimiento(
                      forms: provider.stats.peorCumplimiento,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({required this.onPickDate, this.onClear});

  final VoidCallback onPickDate;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, provider, _) {
        return GlassCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _AutocompleteField(
                      label: 'EVENTO',
                      value: provider.filterEvento ?? '',
                      suggestions: provider.eventos,
                      onChanged: (v) => provider.setFilterEvento(v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _AutocompleteField(
                      label: 'ESPECIALISTA',
                      value: provider.filterEspecialista ?? '',
                      suggestions: provider.especialistas,
                      onChanged: (v) => provider.setFilterEspecialista(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('📅', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.filterFecha == null
                          ? 'Rango: cualquier fecha'
                          : 'Rango: ${_fmtDate(provider.filterFecha!.start)} → ${_fmtDate(provider.filterFecha!.end)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onPickDate,
                    child: const Text('Elegir'),
                  ),
                  if (provider.filterFecha != null)
                    IconButton(
                      tooltip: 'Limpiar rango',
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => provider.setFilterFecha(null),
                    ),
                ],
              ),
              if (onClear != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onClear,
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

  String _fmtDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);
}

class _AutocompleteField extends StatelessWidget {
  const _AutocompleteField({
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          borderRadius: 12,
          child: TextField(
            controller: textController,
            focusNode: focusNode,
            onChanged: onChanged,
            cursorColor: Theme.of(context).colorScheme.primary,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              floatingLabelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
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

class _MetricCards extends StatelessWidget {
  const _MetricCards({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.cumplimientoColor(stats.promedioTotal);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: GlassSection(
            title: 'Promedio Total',
            icon: Icons.emoji_events_outlined,
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: stats.promedioTotal),
                    duration: const Duration(milliseconds: 700),
                    builder: (context, v, _) => Text(
                      '${v.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: color,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _semaforo(stats.promedioTotal),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: GlassSection(
            title: 'Formularios',
            icon: Icons.list_alt_outlined,
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    '${stats.eventosCompletados} / ${stats.totalForms}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'completados',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _semaforo(double v) {
    if (v >= 80) return '🟢 Excelente';
    if (v >= 50) return '🟡 Aceptable';
    return '🔴 Bajo';
  }
}

class _ChartRow extends StatelessWidget {
  const _ChartRow({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GlassSection(
            title: 'Estado',
            icon: Icons.donut_large_outlined,
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 200,
              child: _DonaChart(stats: stats),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassSection(
            title: 'Por Especialista',
            icon: Icons.bar_chart_outlined,
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 200,
              child: _EspecialistasChart(stats: stats),
            ),
          ),
        ),
      ],
    );
  }
}

class _DonaChart extends StatelessWidget {
  const _DonaChart({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.totalForms == 0) {
      return const Center(child: Text('Sin datos'));
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: [
                  PieChartSectionData(
                    value: stats.eventosCompletados.toDouble(),
                    color: const Color(0xFF4CAF50),
                    title: '${stats.eventosCompletados}',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    radius: 32,
                  ),
                  PieChartSectionData(
                    value: stats.eventosPendientes.toDouble(),
                    color: const Color(0xFFFF9800),
                    title: '${stats.eventosPendientes}',
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    radius: 32,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 2,
            alignment: WrapAlignment.center,
            children: const [
              _LegendDot(color: Color(0xFF4CAF50), label: 'Completados'),
              _LegendDot(color: Color(0xFFFF9800), label: 'Pendientes'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _EspecialistasChart extends StatelessWidget {
  const _EspecialistasChart({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final entries = stats.promedioPorEspecialista.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    if (entries.isEmpty) {
      return const Center(child: Text('Sin datos'));
    }
    final maxVal = entries
        .map((e) => e.value)
        .fold<double>(100, (a, b) => b > a ? b : a);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxVal,
          minY: 0,
          barGroups: [
            for (var i = 0; i < entries.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: entries[i].value,
                    width: 14,
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        scheme.primary.withValues(alpha: 0.5),
                        scheme.primary,
                      ],
                    ),
                  ),
                ],
              ),
          ],
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: maxVal / 2,
                getTitlesWidget: (v, meta) => Text(
                  '${v.toInt()}',
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  final name = entries[i].key;
                  final short = name.length > 6
                      ? '${name.substring(0, 6)}…'
                      : name;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      short,
                      style: const TextStyle(fontSize: 9),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StackedBarCard extends StatelessWidget {
  const _StackedBarCard({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return GlassSection(
      title: '% Cumplimiento por Grupo',
      icon: Icons.stacked_bar_chart_outlined,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
        child: Column(
          children: [
            for (final entry in stats.promedioPorGrupo.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _StackedBar(
                  label: entry.key,
                  value: entry.value,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StackedBar extends StatelessWidget {
  const _StackedBar({required this.label, required this.value});
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.cumplimientoColor(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)}%',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value / 100),
          duration: const Duration(milliseconds: 600),
          builder: (context, v, _) => ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.08),
                ),
                FractionallySizedBox(
                  widthFactor: v.clamp(0.0, 1.0),
                  child: Container(
                    height: 12,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthlyTrendCard extends StatelessWidget {
  const _MonthlyTrendCard({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return GlassSection(
      title: 'Tendencia Mensual',
      icon: Icons.show_chart,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 220,
        child: stats.tendenciaMensual.isEmpty
            ? const Center(child: Text('Sin datos'))
            : Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                child: _LineChart(trend: stats.tendenciaMensual),
              ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.trend});
  final List<MonthlyTrend> trend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spots = [
      for (var i = 0; i < trend.length; i++)
        FlSpot(i.toDouble(), trend[i].promedio),
    ];
    final maxY = trend
        .map((t) => t.promedio)
        .fold<double>(100, (a, b) => b > a ? b : a);
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (v) => FlLine(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.08),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: maxY / 4,
              getTitlesWidget: (v, meta) => Text(
                '${v.toInt()}',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= trend.length) {
                  return const SizedBox.shrink();
                }
                final parts = trend[i].label.split(' ');
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    parts.first,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: scheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.primary.withValues(alpha: 0.3),
                  scheme.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPeorCumplimiento extends StatelessWidget {
  const _TopPeorCumplimiento({required this.forms});
  final List<FormModel> forms;

  @override
  Widget build(BuildContext context) {
    if (forms.isEmpty) return const SizedBox.shrink();
    return GlassSection(
      title: 'Top 5 — Peor Cumplimiento',
      icon: Icons.warning_amber_outlined,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final f in forms)
            _PeorRow(form: f),
        ],
      ),
    );
  }
}

class _PeorRow extends StatelessWidget {
  const _PeorRow({required this.form});
  final FormModel form;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.cumplimientoColor(form.total);
    return InkWell(
      onTap: () => context.push('/form/${form.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    form.evento.isEmpty ? 'Sin nombre' : form.evento,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${form.total.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              form.especialista.isEmpty
                  ? 'Sin especialista'
                  : form.especialista,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: form.total / 100),
              duration: const Duration(milliseconds: 500),
              builder: (context, v, _) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.08),
                    ),
                    FractionallySizedBox(
                      widthFactor: v.clamp(0.0, 1.0),
                      child: Container(
                        height: 8,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Text('📊', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            'Sin datos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'No hay formularios para mostrar. Crea el primero desde la lista.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
