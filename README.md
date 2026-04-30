# 🎾 Tennis String & Tune

> Aplicación para la gestión operativa y analítica de un taller de encordado y personalización de raquetas de tenis

![Flutter](https://img.shields.io/badge/Flutter-3.29+-02569B?logo=flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi&logoColor=black)
![License](https://img.shields.io/badge/License-Academic-blue)

---

## 📋 Descripción

**Tennis String & Tune** es una aplicación móvil multiplataforma (iOS, Android y Web) desarrollada como Trabajo de Fin de Grado del Ciclo Formativo de Grado Superior en **Desarrollo de Aplicaciones Multiplataforma (DAM)**.

El sistema digitaliza la operativa diaria de un taller especializado en encordado y personalización de raquetas de tenis, centralizando la gestión de clientes, raquetas, catálogo de cuerdas y órdenes de servicio. Incorpora además un dashboard analítico en Power BI conectado en tiempo real a la base de datos.

| | |
|---|---|
| **Alumno** | Sergio Moro Secilla |
| **Tutora** | Olga M. Moreno Martín |
| **Centro** | Ciclo DAM — Curso 2025–2026 |
| **Máster** | Data Analytics (complementario) |

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────┐
│              CAPA DE PRESENTACIÓN                    │
│         Flutter 3.29+ (iOS · Android · Web)          │
│    go_router · Material Design 3 · flutter_riverpod  │
└────────────────────┬────────────────────────────────┘
                     │ REST API / JWT
┌────────────────────▼────────────────────────────────┐
│                CAPA DE DATOS                         │
│           Supabase (BaaS)                            │
│    PostgreSQL · Auth JWT · Row Level Security        │
└────────────────────┬────────────────────────────────┘
                     │ REST API
┌────────────────────▼────────────────────────────────┐
│              CAPA ANALÍTICA                          │
│           Power BI Desktop/Service                   │
│    Modelo en estrella · DAX · 3 páginas de KPIs      │
└─────────────────────────────────────────────────────┘
```

---

## ✨ Funcionalidades

### Gestión operativa (Flutter)
- 🔐 **Autenticación** — Login seguro con JWT y redirección automática vía `go_router`
- 👥 **Clientes** — CRUD completo con búsqueda en tiempo real y detalle de historial
- 🎾 **Raquetas** — Gestión embebida en la ficha del cliente, múltiples raquetas por cliente
- 🧵 **Cuerdas** — Catálogo con borrado lógico, soporte de encordado híbrido (main/cross)
- 📋 **Órdenes de servicio** — Listado agrupado por estado, cambio rápido de estado, marcado de cobro
- 📊 **Dashboard operativo** — KPIs en tiempo real (servicios hoy, pendientes, en proceso, ingresos mes)

### Analítica (Power BI)
- Conexión en tiempo real a Supabase vía REST API
- **3 páginas:** Resumen Operativo · Análisis de Clientes · Análisis de Materiales
- **12 medidas DAX:** Total Ingresos, Ticket Medio, Tiempo Medio Entrega, Clientes Recurrentes...
- Modelo en estrella con `ordenes_servicio` como tabla de hechos

---

## 🛠️ Stack tecnológico

| Capa | Tecnología | Versión |
|------|-----------|---------|
| Frontend | Flutter | 3.29+ |
| Navegación | go_router | 14.8.1 |
| Estado | flutter_riverpod | 2.6.1 |
| Backend/DB | Supabase (PostgreSQL) | 2.8.4 |
| Analítica | Power BI Desktop/Service | — |
| Tests | flutter_test + mocktail | 1.0.4 |

---

## 🗄️ Modelo de datos

```
CLIENTES ──< RAQUETAS
    │
    └──< ORDENES_SERVICIO >── CUERDAS (main)
                          >── CUERDAS (cross)
```

El modelo incluye 4 tablas con esquema en estrella optimizado para Power BI:
- `clientes` — datos de contacto del cliente
- `raquetas` — pertenece a un cliente, tensiones habituales main/cross
- `cuerdas` — catálogo con borrado lógico (`activo`)
- `ordenes_servicio` — tabla de hechos con servicios booleanos, estados y timestamps

El script completo de creación está en [`/sql/schema.sql`](sql/schema.sql).

---

## 🚀 Instalación y despliegue

### Requisitos previos

- Flutter SDK 3.29+
- Cuenta en [Supabase](https://supabase.com)
- Chrome (para build web)
- macOS + Xcode 15+ (solo para build iOS)

### 1. Clonar el repositorio

```bash
git clone https://github.com/sergiomorosecilla/Tennis-String-Tune.git
cd Tennis-String-Tune
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Supabase

Edita `lib/supabase_config.dart` con tus credenciales:

```dart
class SupabaseConfig {
  static Future<void> init() async {
    await Supabase.initialize(
      url:     'https://<project-ref>.supabase.co',
      anonKey: '<anon-public-key>',
    );
  }
}
```

### 4. Inicializar la base de datos

Ejecuta [`/sql/schema.sql`](sql/schema.sql) en el SQL Editor de Supabase.

Opcionalmente, ejecuta [`/sql/seed.sql`](sql/seed.sql) para cargar datos de prueba.

### 5. Ejecutar la aplicación

```bash
# Web (recomendado para desarrollo)
flutter run -d chrome

# Windows desktop
flutter run -d windows
```

### 6. Build para producción

```bash
# Web
flutter build web --release

# iOS (requiere macOS + Xcode)
flutter build ios --release

# Android
flutter build apk --release
flutter build appbundle --release   # Google Play Store
```

---

## 🧪 Tests

El proyecto incluye tres niveles de testing:

```bash
# Tests unitarios (modelos y validaciones)
flutter test test/unit/ > test/resultados_unit.txt

# Tests de integración (CRUD contra Supabase)
flutter test test/integration/ > test/resultados_integracion.txt

# Tests de UI (widgets)
flutter test test/ui/ > test/resultados_ui.txt

# Todos los tests
flutter test
```

### Cobertura

| Nivel | Casos | Cobertura objetivo |
|-------|-------|-------------------|
| Unitarios (UT01–UT09) | 13 tests | 80% modelos y validaciones |
| Integración (IT01–IT09) | 6 tests | CRUD completo 4 módulos |
| UI (UI01–UI05) | 5 tests | Flujos críticos de usuario |

---

## 📊 Dashboard Power BI

El archivo [`analytics/TennisStringTune_Dashboard.pbix`](analytics/TennisStringTune_Dashboard.pbix) contiene el dashboard analítico con conexión en tiempo real a Supabase vía REST API.

**KPIs incluidos:**
- Servicios hoy / Órdenes por estado
- Total Ingresos / Ingresos Cobrados / Ticket Medio
- Tiempo Medio de Entrega (días)
- Top Clientes por Ingresos
- Cuerdas más utilizadas (main/cross)
- Clientes Recurrentes

Para actualizar los datos: **Inicio → Actualizar** en Power BI Desktop.

---

## 📁 Estructura del proyecto

```
Tennis-String-Tune/
├── lib/
│   ├── main.dart
│   ├── supabase_config.dart
│   ├── router.dart
│   ├── models/
│   │   ├── cliente.dart
│   │   ├── raqueta.dart
│   │   ├── cuerda.dart
│   │   └── orden_servicio.dart
│   ├── services/
│   │   ├── cliente_service.dart
│   │   ├── raqueta_service.dart
│   │   ├── cuerda_service.dart
│   │   └── orden_servicio_service.dart
│   └── screens/
│       ├── login_screen.dart
│       ├── home_screen.dart
│       ├── clientes_screen.dart
│       ├── cliente_detail_screen.dart
│       ├── cliente_form_screen.dart
│       ├── raqueta_form_screen.dart
│       ├── cuerdas_screen.dart
│       ├── cuerda_form_screen.dart
│       ├── ordenes_screen.dart
│       └── orden_form_screen.dart
├── test/
│   ├── unit/
│   ├── integration/
│   ├── ui/
│   └── resultados_*.txt
├── sql/
│   ├── schema.sql
│   └── seed.sql
├── analytics/
│   └── TennisStringTune_Dashboard.pbix
├── assets/
│   └── images/
│       └── logo_tennis_string_tune.png
└── pubspec.yaml
```

---

## 🔒 Seguridad

- Autenticación mediante **JWT** gestionado por Supabase Auth
- **Row Level Security (RLS)** activo en todas las tablas
- Acceso de lectura adicional para Power BI mediante políticas `anon` de solo lectura
- Las credenciales de Supabase se configuran localmente y no se incluyen en el repositorio

---

## 📈 Planificación

El desarrollo se organizó en **8 sprints** siguiendo metodología Scrum adaptada:

| Sprint | Contenido | Duración |
|--------|-----------|----------|
| 0 | Anteproyecto + configuración entorno | 1 semana |
| 1 | Arquitectura Flutter–Supabase + auth | 2 semanas |
| 2 | Módulo Clientes completo | 2 semanas |
| 3 | Entrega memoria 50% | 1 semana |
| 4 | Módulos Servicios + estados | 2 semanas |
| 5 | Estabilización + UX/UI | 1 semana |
| 6 | Dashboard Power BI | 1 semana |
| 7 | Documentación + defensa | 1 semana |

Kanban y Gantt: [GitHub Projects](https://github.com/users/sergiomorosecilla/projects/5/views/1)

---

## 🔮 Evolución futura

- Cálculo automático de precio total basado en catálogo
- Notificaciones push al cliente cuando la raqueta está lista
- Soporte multi-taller con multitenancy (`taller_id`)
- Portal web público para clientes con seguimiento de órdenes
- Pasarela de pago integrada
- Modelo SaaS para encordadores profesionales

---

## 📚 Bibliografía

- Flutter: https://docs.flutter.dev
- Supabase: https://supabase.com/docs
- Power BI: https://learn.microsoft.com/power-bi
- PostgreSQL: https://www.postgresql.org/docs
- go_router: https://pub.dev/packages/go_router

---

## 📄 Licencia

Proyecto académico desarrollado para el TFG del Ciclo DAM 2025–2026.  
Todos los derechos reservados © 2026 Sergio Moro Secilla.
