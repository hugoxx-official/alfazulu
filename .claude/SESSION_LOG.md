# SESSION LOG

## 2026-05-09 - Planes Premium Dinámicos

### Prompt
Corregir la gestión de planes premium en Ajustes Admin para que cargue planes desde `public.premium_plans` en lugar de usar listas hardcodeadas.

### Cambios
1. **Eliminado código hardcodeado en `admin_screen.dart`**:
   - Eliminados: `_planTypes = ['MENSUAL', 'ANUAL', 'VITALICIO']` y `_durations = ['1 mes', '6 meses', '1 año', 'Vitalicio']`
   - Eliminada lógica de mapeo fijo (`if (plan == 'MENSUAL') planId = 'premium'`)
   
2. **Selector dinámico**:
   - `_buildUsersTab()` ahora renderiza opciones desde `_plans` cargado vía API
   - Cada opción muestra: `display_name` y `price_monthly` del plan real
   - Al seleccionar, se usa `plan_name` directamente sin mapeos

3. **Funcionamiento**:
   - Añadir/eliminar/editar planes en `public.premium_plans` se refleja automáticamente
   - No requiere modificar código Flutter ni recompilar

### Archivos
- `apps/mobile/lib/screens/admin_screen.dart` (líneas 1178-1264 modificadas)

### Commit
```
frontend: feat: planes premium dinámicos desde Supabase
```

---

## 2026-05-09 - Corrección Schema Resources + Notificaciones

### Prompt 1
Corregir sistema de notificaciones para que muestre notificaciones REALES del sistema Android incluso con app abierta, sin usar Firebase/FCM.

### Prompt 2
Error: `PostgrestException: could not find file_name on table resources`
Detectar estructura REAL de public.resources y corregir consultas con columnas inexistentes.

### Cambios
1. **Schema Resources**:
   - Columna `file_name` NO existe en tabla real
   - Columna correcta es `name`
   - Corregidos 4 archivos backend

2. **Notificaciones**:
   - Reescrito `notification_service.dart` completamente
   - flutter_local_notifications con importancia HIGH/MAX
   - Dos canales: `alfazulu_notifications` (high) y `alfazulu_instant` (max)
   - Foreground polling cada 30 segundos
   - Permisos Android 13+ solicitados runtime
   - NOT usando Firebase/FCM

3. **Mejoras de UI**:
   - Splash screen con animación de rotación y shimmer
   - Logo2.png en assets y splash
   - Título "ALFAZULU" visible completo en AppBar (letterSpacing: 4 → 2)
   - Nombre app: "alfazulu" → "AlfaZulu"

### Archivos Backend Corregidos
- `backend/src/routes/downloads.js` - select('file_url, name')
- `backend/src/routes/resources.js` - eliminado file_name de insert
- `backend/src/services/driveSync.js` - eliminado file_name de update/insert
- `backend/src/db/schema.sql` - eliminada columna file_name

### Tests
- Pendiente: Probar notificaciones en foreground
- Pendiente: Verificar permisos Android 13+
- Pendiente: flutter analyze

### Pendientes
- Validar tablas TGCF con PDF oficial

### Commit
```
Feature: Notificaciones sistema + UI mejoras + fix schema resources
Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
```

---

## 2026-05-09 - Notificaciones Sistema + UI Mejoras

### Prompt
Corregir sistema de notificaciones para que muestre notificaciones REALES del sistema Android incluso con app abierta, sin usar Firebase/FCM.

### Cambios
1. Reescrito `notification_service.dart` completamente:
   - flutter_local_notifications con importancia HIGH/MAX
   - Dos canales: `alfazulu_notifications` (high) y `alfazulu_instant` (max)
   - Foreground polling cada 30 segundos
   - Permisos Android 13+ solicitados runtime
   - NOT usando Firebase/FCM

2. Mejoras de UI:
   - Splash screen con animación de rotación y shimmer
   - Logo2.png en assets y splash
   - Título "ALFAZULU" visible completo en AppBar (letterSpacing: 4 → 2)
   - Nombre app: "alfazulu" → "AlfaZulu"

3. Archivos actualizados:
   - web/manifest.json, web/index.html
   - AndroidManifest.xml (label)
   - pubspec.yaml (assets de logos)

### Tests
- Pendiente: Probar notificaciones en foreground
- Pendiente: Verificar permisos Android 13+
- Pendiente: flutter analyze

### Pendientes
- Validar tablas TGCF con PDF oficial

### Commit
```
Feature: Notificaciones sistema + UI mejoras
Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
```

---

## 2026-05-07 - Premium Cards + Responsive Grid

### Prompt
Fix visual problems with resource cards (inconsistent sizes, content cutting, poor padding, bad alignment, too much dead space, floating buttons) and implement responsive grid.

### Cambios
1. Rewrite completo de `resource_card.dart`:
   - MouseRegion para hover detection
   - AnimatedContainer con scale transform (1.02x)
   - Dynamic shadows (elevation 2→8, red tint)
   - Neon border (opacity 0.3→0.8, width 1→2)
   - Thumbnail 160px desktop con gradient overlay
   - Dual badges (file type + category)
   - Content layout estructurado con padding 14px

2. Responsive grid en `home_screen.dart`:
   - SliverLayoutBuilder para detectar ancho
   - Mobile (<600px): 2 cols, 16px padding, 12px spacing
   - Tablet (600-1200px): 3 cols, 24px padding, 16px spacing
   - Desktop (>1200px): 4 cols, 32px padding, 20px spacing
   - childAspectRatio: 0.75→0.8→0.85

### Tests
- Pendiente: Probar en mobile, tablet, desktop breakpoints
- Pendiente: Verificar hover effects en web

### Pendientes
- Testing en diferentes dispositivos
- Optimización de rendimiento si es necesaria

### Commit
```
Feature: Premium cards with responsive grid
Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>
```

### Push
- git push origin master - Exitoso
