# DiegApp 🏗️

App Flutter para gestión de formularios **Checklist ALTA — Creación de Eventos**.

> Formularios para tracking del proceso de creación de eventos, con checklist de cumplimiento, dashboard estadístico y exportación a PDF.

---

## ✨ Características

- **📋 Listado** — Filtros por especialista, evento y fecha. Tarjetas glass con progreso visual.
- **📝 Formulario** — Interfaz glassmorphism iOS. Campos de texto agrupados con cálculo automático de cumplimiento.
- **📊 Dashboard** — Estadísticas: promedio total, completados vs pendientes, top 5 peor cumplimiento, tendencia mensual.
- **📄 PDF Export** — Generación de reporte formal con todos los campos y resumen.
- **🌙 Dark/Light Mode** — Soporte nativo.

## 🛠 Stack

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter 3.27+ / Dart 3.6+ |
| State | Provider |
| DB | SQLite (sqflite) |
| PDF | pdf + printing |
| Charts | fl_chart |
| Navegación | GoRouter |

## 📁 Estructura

```
lib/
├── main.dart
├── app.dart
├── theme/
├── database/
├── models/
├── providers/
├── views/
│   ├── list/          # FormListScreen
│   ├── form/          # FormScreen
│   ├── dashboard/     # DashboardScreen
│   └── pdf/           # PdfPreviewScreen
├── widgets/           # GlassCard, GlassScaffold, GlassTextField, etc.
└── utils/             # Calculations, PDF generation
```

## 🚀 Inicio rápido

```bash
flutter pub get
flutter run
```

## 🏁 Plataformas

- Android (API 21+)
- iOS (15.0+)

---

> Desarrollado por [Laaguna](https://github.com/Laaguna)
