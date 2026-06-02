# DiegApp 🏗️

App Flutter para gestión de formularios **Checklist ALTA — Creación de Eventos**.

> Formularios para tracking del proceso de creación de eventos, con checklist de cumplimiento, dashboard estadístico y exportación a PDF.

---

## ✨ Características

- **📋 Listado** — Filtros por especialista, evento y fecha. Tarjetas glass con progreso visual animado.
- **📝 Formulario** — Interfaz glassmorphism. Campos de texto agrupados con cálculo automático de cumplimiento.
- **📊 Dashboard** — Métricas con semáforo, donut/bar/line charts (fl_chart), top 5 de peor cumplimiento y tendencia mensual.
- **📄 PDF Export** — Reporte formal (carta) con datos generales, checklist por grupos y resumen de cumplimiento. Vista previa, compartir y guardar.
- **🌙 Dark/Light Mode** — Soporte nativo según el sistema.
- **🗄️ Modo offline** — Persistencia local con SQLite (sqflite).
- **✨ Animaciones** — Transiciones fade+slide entre pantallas, haptics, snackbar con deshacer.

## 🛠 Stack

| Capa | Tecnología |
|------|-----------|
| Framework | Flutter 3.27+ / Dart 3.6+ |
| State | Provider |
| DB | SQLite (sqflite) |
| PDF | `pdf` + `printing` |
| Charts | `fl_chart` |
| Compartir | `share_plus` |
| Navegación | `go_router` |

## 🚀 Instalación

```bash
flutter pub get
flutter run
```

## 🧪 Tests

```bash
flutter test
```

## 🏁 Plataformas

- Android (API 21+)
- iOS (15.0+)

## 📁 Estructura del proyecto

```
lib/
├── main.dart                       # Entry point
├── app.dart                        # MaterialApp + GoRouter + Providers
├── theme/
│   └── app_theme.dart              # Tema light/dark y colores glass
├── database/
│   ├── database_helper.dart        # Setup de SQLite
│   └── form_dao.dart               # CRUD + queries de dashboard
├── models/
│   └── form_model.dart             # Entidad principal
├── providers/
│   ├── form_provider.dart          # Estado del formulario en edición
│   ├── form_list_provider.dart     # Estado del listado + filtros
│   └── dashboard_provider.dart     # Estado del dashboard
├── views/
│   ├── list/
│   │   └── form_list_screen.dart   # Pantalla de listado
│   ├── form/
│   │   └── form_screen.dart        # Pantalla de crear/editar
│   ├── dashboard/
│   │   └── dashboard_screen.dart   # Pantalla de estadísticas
│   └── pdf/
│       └── pdf_preview_screen.dart # Vista previa y compartir PDF
├── widgets/
│   ├── glass_card.dart
│   ├── glass_scaffold.dart
│   ├── glass_section.dart
│   ├── glass_text_field.dart
│   ├── glass_button.dart
│   └── page_transitions.dart       # Transición fade + slide
└── utils/
    ├── calculations.dart           # Cálculo de cumplimiento
    └── pdf_export.dart             # Generación de PDF
test/
├── calculations_test.dart          # Tests de cálculos
├── form_model_test.dart            # Tests del modelo
├── form_screen_test.dart           # Test de flujo de formulario
└── widget/
    └── glass_card_test.dart        # Tests de widgets glass
```

## 🧮 Cálculo de cumplimiento

Los 12 campos del formulario se agrupan en 3 categorías:

- **Nuevo Venue** (3 campos): venue, mapa, taquilla
- **Nuevo Evento** (5 campos): configuración canales, show, T&C, imágenes, tarifas
- **Modificables** (4 campos): holds, preventas, validadores, mapa silletería

El porcentaje de cada grupo = `campos_rellenos / total_campos × 100`.
El `total` = `campos_rellenos_total / 12 × 100`.

**Semáforo:**

- 🟢 Verde ≥ 80%
- 🟡 Amarillo ≥ 50%
- 🔴 Rojo < 50%

---

## 📄 Licencia

MIT

> Desarrollado por [Laaguna](https://github.com/Laaguna)
