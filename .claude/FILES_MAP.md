# FILES MAP

## Frontend Flutter

### apps/mobile/lib/providers/app_provider.dart
- **Función**: Estado global de la app, usuario, recursos, mapas
- **Dependencias**: http, shared_preferences, models
- **API**: https://backend-api-production-0cd8.up.railway.app/api
- **Advertencias**: Timeout de 5s en SharedPreferences

### apps/mobile/lib/widgets/resource_card.dart
- **Función**: Card premium de recursos con hover effects
- **Dependencias**: models/resource.dart, app_provider
- **Features**: Scale animation, neon border, dynamic shadows
- **Advertencias**: MouseRegion solo funciona en web/desktop

### apps/mobile/lib/screens/home_screen.dart
- **Función**: Grid principal de recursos
- **Dependencias**: resource_card.dart, app_provider
- **Features**: Responsive grid (2/3/4 cols), SliverLayoutBuilder
- **Advertencias**: SliverLayoutBuilder requiere Flutter 3.x

### apps/mobile/lib/screens/premium_screen.dart
- **Función**: Selección de planes premium
- **Dependencias**: app_provider, http
- **Features**: Monthly/lifetime, Bizum, plan filtering
- **Advertencias**: Filtra planes por plan actual del usuario

### apps/mobile/lib/screens/admin_screen.dart
- **Función**: Panel de administración
- **Dependencias**: app_provider, http
- **Features**: Users tab, Plans tab, stats reales, planes dinámicos desde premium_plans
- **Advertencias**: Requiere login admin con bcrypt. Planes se cargan dinámicamente desde API (no hardcodeados)

### apps/mobile/lib/screens/settings_screen.dart
- **Función**: Ajustes y perfil de usuario
- **Dependencias**: app_provider
- **Features**: Premium badge, días restantes, plan display
- **Advertencias**: Color coding de días (verde >7, naranja <7, rojo 0)

### apps/mobile/lib/screens/notifications_screen.dart
- **Función**: Lista de notificaciones del usuario
- **Dependencias**: app_provider, http, notification_service
- **Features**: Filtro no leídas, marcar como leída, delete, tipos (premium, upload, admin)
- **Advertencias**: Requiere tabla `notifications` en Supabase

### apps/mobile/lib/models/user.dart
- **Función**: Modelo de usuario
- **Campos**: id, username, isPremium, premiumPlan, subscriptionEnd
- **Advertencias**: Requiere columnas is_premium, premium_plan, subscription_end en users table

### apps/mobile/lib/models/resource.dart
- **Función**: Modelo de recurso
- **Campos**: id, name, title, category, fileType, fileSize, thumbnailUrl, downloadUrl, isPremium, driveFileId, downloadCount, createdAt
- **Advertencias**: Requiere columnas title, file_type, thumbnail_url, download_url, is_premium en resources table

### apps/mobile/lib/models/map.dart
- **Función**: Modelo de mapa (extiende Resource)
- **Campos**: id, name, category, fileType, fileSize, scale, region, coordinates, createdAt
- **Advertencias**: Requiere columnas map_type, file_type, file_size, region, scale en maps table

### apps/mobile/lib/services/notification_service.dart
- **Función**: Servicio de notificaciones locales del sistema
- **Dependencias**: flutter_local_notifications, permission_handler, shared_preferences
- **Features**: Foreground polling 30s, canales high/max priority, permisos Android 13+
- **Advertencias**: NO usa Firebase/FCM, solo notificaciones locales

## Backend Node.js

### backend/src/server.js
- **Función**: Servidor Express + CORS
- **Config**: CORS methods ['GET','POST','PUT','PATCH','DELETE','OPTIONS']

### backend/src/routes/admin.js
- **Función**: Endpoints admin (login, stats, plans CRUD, premium-request, notify-all)
- **Features**: Telegram notifications, stats reales, gestión usuarios, gestión recursos
- **Endpoints**: 
  - POST /login, GET /stats
  - GET/POST/PUT/DELETE /plans
  - GET/POST/PUT/DELETE /resources
  - GET/PUT /users, POST /users/:id/premium, POST /users/:id/assign-plan
  - GET/POST/PUT/DELETE /maps
  - POST /premium-request, POST /notify-all

### backend/src/routes/resources.js
- **Función**: Endpoints de recursos
- **Features**: Favoritos por usuario, búsqueda, upload con multer
- **Endpoints**: GET /, POST /, GET /:id, DELETE /:id, POST /:id/favorite, GET /favorites/:user_id
- **Schema**: resources (id, name, title, category, file_type, file_url, file_size, mime_type, thumbnail_url, download_url, is_premium, downloads, drive_file_id, created_at)

### backend/src/routes/users.js
- **Función**: Gestión de usuarios
- **Features**: Telegram log en premium assignment
- **Endpoints**: POST / (crear), GET / (listar), GET /:id, PATCH /:id/premium

### backend/src/routes/downloads.js
- **Función**: Registro de descargas
- **Features**: Descargas por usuario, join con resources
- **Endpoints**: POST / (registrar), GET / (listar), GET /:user_id (por usuario)
- **Schema**: downloads (id, user_id, resource_id, downloaded_at)

### backend/src/routes/maps.js
- **Función**: Gestión de mapas
- **Features**: Upload a Supabase Storage, metadata completa
- **Endpoints**: GET /, POST /, PUT /:id, DELETE /:id, POST /upload
- **Schema**: maps (id, name, description, file_url, thumbnail_url, map_type, file_type, file_size, region, scale, created_at)

### backend/src/routes/notifications.js
- **Función**: Gestión de notificaciones
- **Features**: Filtro por user_id, unread_only, mark as read
- **Endpoints**: GET / (listar), PUT /:id/read, PUT /read-all, DELETE /:id
- **Schema**: notifications (id, user_id, title, message, type, is_read, created_at)

### backend/src/routes/stats.js
- **Función**: Estadísticas detalladas
- **Features**: Descargas por recurso, total usuarios, descargas hoy
- **Endpoints**: GET /

### backend/src/services/driveSync.js
- **Función**: Sincronización con Google Drive
- **Features**: Sync automático cada hora, detección de categoría por nombre
- **Advertencias**: Requiere GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REFRESH_TOKEN

### backend/src/services/premiumExpiration.js
- **Función**: Verificación de expiración premium
- **Features**: Cron diario 3AM, notificaciones de caducidad, log a Telegram
- **Advertencias**: Requiere tabla notifications

### backend/src/db/schema.sql
- **Función**: Schema completo de Supabase
- **Tablas**: users, resources, maps, downloads, notifications, premium_plans
- **Features**: RLS policies, índices, triggers, seed data
- **Estado**: ACTUALIZADO 2026-05-09 (100% alineado con código)

### backend/src/db/migrations/001_audit_fixes.sql
- **Función**: Migración para corregir inconsistencias detectadas en auditoría
- **Crea**: Tablas notifications, premium_plans
- **Añade**: Columnas faltantes en users, resources, maps
- **Índices**: 15+ índices nuevos
- **RLS**: Policies actualizadas
- **Seed**: Datos iniciales para premium_plans

### backend/audit-supabase.js
- **Función**: Script de auditoría de database
- **Features**: Compara código vs schema real, detecta columnas faltantes
- **Uso**: `node audit-supabase.js`

## Database Supabase

### Tablas

#### users
| Columna | Tipo | Required | Descripción |
|---------|------|----------|-------------|
| id | UUID | SÍ | Primary key |
| username | TEXT | SÍ | Unique |
| is_admin | BOOLEAN | SÍ | Rol de administrador |
| password_hash | TEXT | NO | Hash bcrypt |
| is_premium | BOOLEAN | SÍ | Estado premium |
| premium_plan | TEXT | NO | Nombre del plan |
| subscription_end | TIMESTAMP | NO | Fin de suscripción |
| favorites | UUID[] | NO | Array de IDs de recursos |
| created_at | TIMESTAMP | SÍ | Creación |
| updated_at | TIMESTAMP | SÍ | Última actualización |

#### resources
| Columna | Tipo | Required | Descripción |
|---------|------|----------|-------------|
| id | UUID | SÍ | Primary key |
| name | TEXT | SÍ | Nombre interno |
| title | TEXT | SÍ | Título para UI |
| category | TEXT | SÍ | Categoría |
| description | TEXT | NO | Descripción |
| file_type | TEXT | SÍ | Tipo de archivo |
| file_url | TEXT | SÍ | URL de descarga |
| file_size | BIGINT | NO | Tamaño en bytes |
| mime_type | TEXT | NO | MIME type |
| thumbnail_url | TEXT | NO | URL de thumbnail |
| download_url | TEXT | NO | URL alternativa |
| is_premium | BOOLEAN | SÍ | Flag premium |
| downloads | INTEGER | NO | Contador |
| drive_file_id | TEXT | NO | ID en Google Drive |
| created_at | TIMESTAMP | SÍ | Creación |

#### maps
| Columna | Tipo | Required | Descripción |
|---------|------|----------|-------------|
| id | UUID | SÍ | Primary key |
| name | TEXT | SÍ | Nombre |
| description | TEXT | NO | Descripción |
| file_url | TEXT | SÍ | URL del archivo |
| thumbnail_url | TEXT | NO | Thumbnail |
| map_type | TEXT | NO | Tipo de mapa |
| file_type | TEXT | NO | Tipo de archivo |
| file_size | BIGINT | NO | Tamaño |
| region | TEXT | NO | Región geográfica |
| scale | TEXT | NO | Escala |
| created_at | TIMESTAMP | SÍ | Creación |

#### downloads
| Columna | Tipo | Required | Descripción |
|---------|------|----------|-------------|
| id | UUID | SÍ | Primary key |
| user_id | UUID | SÍ | FK → users(id) |
| resource_id | UUID | SÍ | FK → resources(id) |
| downloaded_at | TIMESTAMP | SÍ | Fecha de descarga |

#### notifications
| Columna | Tipo | Required | Descripción |
|---------|------|----------|-------------|
| id | UUID | SÍ | Primary key |
| user_id | UUID | SÍ | FK → users(id) |
| title | TEXT | SÍ | Título |
| message | TEXT | SÍ | Mensaje |
| type | TEXT | SÍ | premium/upload/admin/info |
| is_read | BOOLEAN | SÍ | Estado de lectura |
| created_at | TIMESTAMP | SÍ | Creación |

#### premium_plans
| Columna | Tipo | Required | Descripción |
|---------|------|----------|-------------|
| id | UUID | SÍ | Primary key |
| plan_name | TEXT | SÍ | Nombre interno (unique) |
| display_name | TEXT | SÍ | Nombre para UI |
| price_monthly | TEXT | SÍ | Precio mensual |
| price_lifetime | TEXT | SÍ | Precio vitalicio |
| color | TEXT | SÍ | Color hex |
| features | TEXT[] | SÍ | Ventajas |
| limitations | TEXT[] | SÍ | Limitaciones |
| is_active | BOOLEAN | SÍ | Visible |
| sort_order | INTEGER | SÍ | Orden |
| created_at | TIMESTAMP | SÍ | Creación |
| updated_at | TIMESTAMP | SÍ | Actualización |

### Índices

| Tabla | Columna(s) | Propósito |
|-------|------------|-----------|
| users | username | Login |
| users | is_premium | Stats |
| resources | category | Filtro |
| resources | created_at DESC | Ordenamiento |
| resources | name | Búsqueda |
| resources | is_premium | Filtro premium |
| resources | (category, is_premium) | Filtro combinado |
| maps | created_at DESC | Ordenamiento |
| maps | region | Búsqueda |
| downloads | resource_id | Join |
| downloads | user_id | Por usuario |
| downloads | downloaded_at DESC | Ordenamiento |
| notifications | user_id | Por usuario |
| notifications | (user_id, is_read) WHERE is_read=false | No leídas |
| notifications | created_at DESC | Ordenamiento |
| premium_plans | is_active WHERE is_active=true | Activos |
| premium_plans | sort_order | Orden |

### RLS Policies

| Tabla | Operación | Policy |
|-------|-----------|--------|
| users | SELECT | Public read |
| users | INSERT | Authenticated |
| users | UPDATE | Own user |
| resources | SELECT | Public |
| resources | ALL | Admin |
| maps | SELECT | Public |
| maps | ALL | Admin |
| downloads | SELECT | Public |
| downloads | INSERT | Public |
| notifications | SELECT | Public |
| notifications | INSERT | System |
| notifications | UPDATE | Own user |
| notifications | DELETE | Own user |
| premium_plans | SELECT | Public (active only) |
| premium_plans | ALL | Admin |

### Storage Buckets

| Bucket | Público | Uso |
|--------|---------|-----|
| maps | SÍ | Upload de mapas (KML, KMZ, GPX, PDF, GeoTIFF) |

## Índices de Documentos

| Documento | Ubicación | Descripción |
|-----------|-----------|-------------|
| AUDIT_REPORT.md | .claude/ | Informe completo de auditoría |
| CHANGELOG_AI.md | .claude/ | Historial de cambios AI |
| SESSION_LOG.md | .claude/ | Log de sesiones de trabajo |
| ERRORS_SOLVED.md | .claude/ | Errores solucionados |
| schema.sql | backend/src/db/ | Schema completo de Supabase |
| 001_audit_fixes.sql | backend/src/db/migrations/ | Migración de auditoría |
