# CHANGELOG AI

## 2026-05-09 - Auditoría Completa Código vs Database

### Cambios Principales

#### 1. Auditoría de Database Supabase
- **Problema**: Schema.sql desactualizado, faltan tablas y columnas críticas
- **Solución**: Generado informe completo de auditoría (`AUDIT_REPORT.md`)
- **Tablas detectadas faltantes**: `notifications`, `premium_plans`
- **Columnas faltantes**: 20+ columnas en users, resources, maps
- **Índices faltantes**: 15+ índices para performance
- **RLS policies**: Actualizadas para seguridad correcta

#### 2. Migración SQL Creada
- Archivo: `backend/src/db/migrations/001_audit_fixes.sql`
- Crea tablas faltantes (notifications, premium_plans)
- Añade columnas faltantes (ALTER TABLE)
- Crea índices necesarios
- Configura RLS policies correctamente
- Seed data para premium_plans

#### 3. Schema Actualizado
- `backend/src/db/schema.sql` reescrito completamente
- Ahora refleja 100% el código actual
- Incluye todas las tablas, columnas, índices y policies

### Backend Changes
- `backend/src/db/schema.sql` - COMPLETAMENTE REESCRITO
- `backend/src/db/migrations/001_audit_fixes.sql` - NUEVO
- `backend/audit-supabase.js` - Script de auditoría

### Documentación
- `.claude/AUDIT_REPORT.md` - INFORME COMPLETO DE AUDITORÍA

### Commits
```
backend: chore: auditoría completa código vs database
backend: fix: schema.sql actualizado con todas las tablas
backend: feat: migración SQL para audit fixes
```

---

## 2026-05-09 - Planes Premium Dinámicos desde Supabase

### Cambios Principales

#### 1. Planes Premium Dinámicos en Panel Admin
- **Problema**: Los planes en el selector de usuarios estaban hardcodeados (`['MENSUAL', 'ANUAL', 'VITALICIO']`)
- **Solución**: Eliminado código hardcodeado, ahora usa `_plans` cargado desde `public.premium_plans`
- **Impacto**: Añadir/eliminar/editar planes en Supabase se refleja automáticamente sin tocar código Flutter

### Frontend Changes
- `apps/mobile/lib/screens/admin_screen.dart`:
  - Eliminados: `_planTypes = ['MENSUAL', 'ANUAL', 'VITALICIO']` y `_durations`
  - Eliminada lógica de mapeo fijo de planes (`if (plan == 'MENSUAL') planId = 'premium'`)
  - `_setPremium()` ahora usa `plan_name` directamente del plan seleccionado
  - `_buildUsersTab()` renderiza selector desde `_plans` cargado vía API
  - Selector muestra: `display_name` y `price_monthly` de cada plan real

### Commits
```
frontend: feat: planes premium dinámicos desde Supabase
frontend: refactor: eliminar código hardcodeado en admin_screen.dart
```

---

## 2026-05-09 - Admin Stats + Schema Resources + Notificaciones

### Cambios Principales

#### 1. Estadísticas Panel Admin (Datos Reales)
- **Problema**: Stats del admin mostraban ceros o valores hardcodeados
- **Solución**: Backend ahora consulta Supabase y calcula:
  - `total_resources`: COUNT(public.resources)
  - `total_users`: COUNT(public.users)
  - `total_downloads`: COUNT(public.downloads)
  - `total_maps`: COUNT(public.maps)
  - `premium_users`: Usuarios con is_premium=true y premium_plan != 'free'
  - `free_users`: Total - premium_users

#### 2. Corrección Columna `file_name` en Resources
- **Problema**: Tabla `public.resources` no tiene columna `file_name`, la columna correcta es `name`
- **Error**: `PostgrestException: could not find file_name on table resources`
- **Solución**: Reemplazar `file_name` por `name` en todas las consultas backend

#### 3. Notificaciones Locales Reales del Sistema
- Reescrito `notification_service.dart` completamente
- NOT usa Firebase/FCM - solo flutter_local_notifications
- Notificaciones aparecen como banner REAL del sistema incluso con app abierta
- Dos canales: normal (high) e instantáneo (max priority)
- Foreground polling cada 30 segundos
- Permisos Android 13+ solicitados runtime

#### 4. Logo y Branding
- Cambiado logo1.png por logo2.png en assets
- Splash screen usa logo2.png con animación mejorada
- Nombre cambiado de "alfazulu" a "AlfaZulu" (capitalización)

#### 5. Mejoras de UI
- Loading screen con animación de rotación y shimmer
- Título "ALFAZULU" en AppBar ahora visible completo (reducido letterSpacing)
- Splash screen más elaborada con efectos de glow y rotación

### Backend Changes
- `backend/src/routes/admin.js` - stats endpoint con conteo real de users, premium/free
- `backend/src/routes/downloads.js` - select('file_url, name') en vez de file_name
- `backend/src/routes/resources.js` - eliminado file_name de insert()
- `backend/src/services/driveSync.js` - eliminado file_name de update() e insert()
- `backend/src/db/schema.sql` - eliminada columna file_name

### Frontend Changes
- `apps/mobile/lib/services/notification_service.dart` - REESCRITO
- `apps/mobile/lib/main.dart` - Splash screen mejorada
- `apps/mobile/lib/screens/home_screen.dart` - letterSpacing reducido
- `apps/mobile/lib/screens/admin_screen.dart` - usa claves correctas del backend
- `apps/mobile/pubspec.yaml` - assets de logos añadidos
- `apps/mobile/web/manifest.json` - nombre actualizado
- `apps/mobile/web/index.html` - título actualizado
- `apps/mobile/android/app/src/main/AndroidManifest.xml` - label actualizado

### Commits
```
backend: fix: admin stats con datos reales de Supabase
backend: fix: columna file_name no existe en resources, usar name
frontend: feat: notificaciones locales reales del sistema
frontend: feat: splash screen mejorada con logo2
frontend: fix: visible completo ALFAZULU en AppBar
frontend: chore: cambiar nombre a AlfaZulu
```

---

## 2026-05-09 - Notificaciones Sistema y Mejoras UI

### Cambios Principales

#### 1. Corrección Columna `file_name` en Resources
- **Problema**: Tabla `public.resources` no tiene columna `file_name`, la columna correcta es `name`
- **Error**: `PostgrestException: could not find file_name on table resources`
- **Solución**: Reemplazar `file_name` por `name` en todas las consultas backend

#### 2. Notificaciones Locales Reales del Sistema
- Reescrito `notification_service.dart` completamente
- NOT usa Firebase/FCM - solo flutter_local_notifications
- Notificaciones aparecen como banner REAL del sistema incluso con app abierta
- Dos canales: normal (high) e instantáneo (max priority)
- Foreground polling cada 30 segundos
- Permisos Android 13+ solicitados runtime

#### 3. Logo y Branding
- Cambiado logo1.png por logo2.png en assets
- Splash screen usa logo2.png con animación mejorada
- Nombre cambiado de "alfazulu" a "AlfaZulu" (capitalización)

#### 4. Mejoras de UI
- Loading screen con animación de rotación y shimmer
- Título "ALFAZULU" en AppBar ahora visible completo (reducido letterSpacing)
- Splash screen más elaborada con efectos de glow y rotación

### Backend Changes
- `backend/src/routes/downloads.js` - select('file_url, name') en vez de file_name
- `backend/src/routes/resources.js` - eliminado file_name de insert()
- `backend/src/services/driveSync.js` - eliminado file_name de update() e insert()
- `backend/src/db/schema.sql` - eliminada columna file_name

### Frontend Changes
- `apps/mobile/lib/services/notification_service.dart` - REESCRITO
- `apps/mobile/lib/main.dart` - Splash screen mejorada
- `apps/mobile/lib/screens/home_screen.dart` - letterSpacing reducido
- `apps/mobile/pubspec.yaml` - assets de logos añadidos
- `apps/mobile/web/manifest.json` - nombre actualizado
- `apps/mobile/web/index.html` - título actualizado
- `apps/mobile/android/app/src/main/AndroidManifest.xml` - label actualizado

### Commits
```
backend: fix: columna file_name no existe en resources, usar name
frontend: feat: notificaciones locales reales del sistema
frontend: feat: splash screen mejorada con logo2
frontend: fix: visible completo ALFAZULU en AppBar
frontend: chore: cambiar nombre a AlfaZulu
```

---

## 2026-05-09 - Notificaciones Sistema y Mejoras UI

### Cambios Principales

#### 1. Notificaciones Locales Reales del Sistema
- Reescrito `notification_service.dart` completamente
- NOT usa Firebase/FCM - solo flutter_local_notifications
- Notificaciones aparecen como banner REAL del sistema incluso con app abierta
- Dos canales: normal (high) e instantáneo (max priority)
- Foreground polling cada 30 segundos
- Permisos Android 13+ solicitados runtime

#### 2. Logo y Branding
- Cambiado logo1.png por logo2.png en assets
- Splash screen usa logo2.png con animación mejorada
- Nombre cambiado de "alfazulu" a "AlfaZulu" (capitalización)

#### 3. Mejoras de UI
- Loading screen con animación de rotación y shimmer
- Título "ALFAZULU" en AppBar ahora visible completo (reducido letterSpacing)
- Splash screen más elaborada con efectos de glow y rotación

### Backend Changes
- Sin cambios en backend

### Frontend Changes
- `apps/mobile/lib/services/notification_service.dart` - REESCRITO
- `apps/mobile/lib/main.dart` - Splash screen mejorada
- `apps/mobile/lib/screens/home_screen.dart` - letterSpacing reducido
- `apps/mobile/pubspec.yaml` - assets de logos añadidos
- `apps/mobile/web/manifest.json` - nombre actualizado
- `apps/mobile/web/index.html` - título actualizado
- `apps/mobile/android/app/src/main/AndroidManifest.xml` - label actualizado

### Commits
```
frontend: feat: notificaciones locales reales del sistema
frontend: feat: splash screen mejorada con logo2
frontend: fix: visible completo ALFAZULU en AppBar
frontend: chore: cambiar nombre a AlfaZulu
```

---

## 2026-05-07 - Sesión Completa: Múltiples Fixes y Features

### Cambios Principales

#### 1. Eliminación de Favoritos
- Removido campo `favorites` de User model
- Removido campo `isFavorite` de Resource model
- Eliminados métodos `toggleFavorite` y `loadFavorites` de AppProvider
- Removidos botones de favoritos de resource_card.dart

#### 2. Pantalla de Descargas
- Creado `DownloadsScreen` para mostrar historial de descargas
- Backend: GET `/api/downloads/:user_id`
- Integrado en menú de ajustes

#### 3. Admin Plans - Precios Mensual/Vitalicio
- Actualizado schema `premium_plans`: `price_monthly` y `price_lifetime`
- Admin puede editar ambos precios por plan
- Premium screen muestra precio según selección (mensual/vitalicio)

#### 4. Acerca de Profesional
- Actualizado dialog con información de producción
- Muestra versión, backend, database
- Copyright 2026 AlfaZulu

#### 5. Categorías Dinámicas
- HomeScreen ya no tiene categorías hardcoded
- Las categorías se cargan desde backend
- Se actualizan dinámicamente

#### 6. Plan Actual en Perfil
- AppProvider.refreshUser() para obtener datos actualizados
- Se refresca al cargar sesión desde backend

### Backend Changes
- `backend/src/routes/admin.js`: 
  - POST /categories, DELETE /categories/:name
  - GET /users, PUT /users/:id
  - GET /resources, DELETE /resources/:id
  - Stats con count real de premium/free users
  - Soporte price_monthly/price_lifetime en planes

- `backend/src/routes/users.js`:
  - GET /:id para obtener usuario por ID

- `backend/src/routes/downloads.js`:
  - GET /:user_id para historial de descargas

- `backend/premium_plans.sql`:
  - Actualizado schema con price_monthly y price_lifetime

### Frontend Changes
- `apps/mobile/lib/models/user.dart` - Sin favorites
- `apps/mobile/lib/models/resource.dart` - Sin isFavorite
- `apps/mobile/lib/providers/app_provider.dart` - refreshUser(), sin toggleFavorite
- `apps/mobile/lib/widgets/resource_card.dart` - Sin botón favoritos
- `apps/mobile/lib/screens/home_screen.dart` - Categorías dinámicas
- `apps/mobile/lib/screens/premium_screen.dart` - Precios según periodo
- `apps/mobile/lib/screens/settings_screen.dart` - Acerca de actualizado, link a descargas
- `apps/mobile/lib/screens/downloads_screen.dart` - NUEVA
- `apps/mobile/lib/screens/admin_screen.dart` - CRUD planes con ambos precios

### Commits
```
backend: feat: admin endpoints para categorias, recursos y usuarios
backend: feat: endpoint para obtener descargas de usuario
frontend: feat: eliminar favoritos y mejoras UI
frontend: feat: pantalla de descargas funcional
frontend: fix: admin plans con precios mensual y vitalicio
```
