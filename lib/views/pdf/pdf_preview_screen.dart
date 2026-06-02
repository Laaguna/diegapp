import 'package:flutter/material.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glass_scaffold.dart';

class PdfPreviewScreen extends StatelessWidget {
  const PdfPreviewScreen({super.key, this.formId});

  final int? formId;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(title: const Text('Vista Previa PDF')),
      body: Center(
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📄', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                'Generar PDF',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Próximamente — Sprint 5\nForm ID: ${formId ?? '-'}',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
