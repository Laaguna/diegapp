import 'package:flutter/material.dart';
import '../models/form_model.dart';
import '../theme/app_theme.dart';

void showAppSnackBar(
  BuildContext context,
  Widget content, {
  SnackBarAction? action,
  Duration duration = const Duration(seconds: 3),
  Color? backgroundColor,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: content,
      action: action,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
    ),
  );
}

Future<bool?> confirmDelete(BuildContext context, FormModel form) {
  return showDialog<bool>(
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
}
