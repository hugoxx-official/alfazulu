# AUDITORÍA COMPLETA: Código vs Database Supabase

**Fecha:** 2026-05-09  
**Estado:** Documento generado automáticamente

---

## 1. TABLAS REQUERIDAS POR EL CÓDIGO

### Tablas detectadas en el código backend/frontend:

| Tabla | Archivos que la usan | Operaciones |
|-------|---------------------|-------------|
| `users` | admin.js, users.js, resources.js, app_provider.dart | SELECT, INSERT, UPDATE, DELETE |
| `resources` | admin.js, resources.js, driveSync.js, app_provider.dart | SELECT, INSERT, UPDATE, DELETE |
| `maps` | admin.js, maps.js, app_provider.dart | SELECT, INSERT, UPDATE, DELETE |
| `downloads` | admin.js, downloads.js, stats.js | SELECT, INSERT |
| `notifications` | admin.js, notifications.js, premiumExpiration.js | SELECT, INSERT, UPDATE, DELETE |
| `premium_plans` | admin.js, premium_screen.dart | SELECT, INSERT, UPDATE, DELETE |
| `categories` | admin.js (inline en resources) | SELECT (derivado de resources.category) |

### Storage Buckets requeridos:
- `maps` - usado en maps.js para upload de archivos

---

## 2. COLUMNAS REQUERIDAS VS SCHEMA ACTUAL

### Tabla: `users`

**Columnas usadas en el código:**

| Columna | Tipo | Usado en | Required |
|---------|------|----------|----------|
| `id` | UUID | TODOS | SÍ |
| `username` | TEXT | TODOS | SÍ |
| `is_admin` | BOOLEAN | admin.js:39 | SÍ |
| `password_hash` | TEXT | admin.js:28-32 | SÍ |
| `password` | TEXT | admin.js:30 (fallback) | NO |
| `is_premium` | BOOLEAN | TODOS | SÍ |
| `premium_plan` | TEXT | TODOS | SÍ |
| `subscription_end` | TIMESTAMP | TODOS | SÍ |
| `favorites` | TEXT[] (array) | resources.js:134-163 | SÍ |
| `created_at` | TIMESTAMP | admin.js:420 | SÍ |
| `updated_at` | TIMESTAMP | premiumExpiration.js:41 | NO |

**Schema actual (schema.sql):**
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**❌ COLUMNAS FALTANTES:**
- `is_admin`
- `password_hash`
- `is_premium`
- `premium_plan`
- `subscription_end`
- `favorites`
- `updated_at`

---

### Tabla: `resources`

**Columnas usadas en el código:**

| Columna | Tipo | Usado en | Required |
|---------|------|----------|----------|
| `id` | UUID | TODOS | SÍ |
| `name` | TEXT | resources.js, driveSync.js | SÍ |
| `title` | TEXT | admin.js:646, Resource.fromJson | SÍ |
| `category` | TEXT | TODOS | SÍ |
| `description` | TEXT | resources.js | NO |
| `file_url` | TEXT | downloads.js:25, driveSync.js:66 | SÍ |
| `file_size` | BIGINT | resources.js:74 | NO |
| `mime_type` | TEXT | resources.js:75 | NO |
| `file_type` | TEXT | Resource.dart, admin.js:650 | SÍ |
| `thumbnail_url` | TEXT | Resource.dart, admin.js:653 | NO |
| `download_url` | TEXT | Resource.dart, admin.js:652 | NO |
| `is_premium` | BOOLEAN | admin.js:654 | SÍ |
| `downloads` | INTEGER | stats.js | NO |
| `drive_file_id` | TEXT | Resource.dart | NO |
| `download_count` | INTEGER | Resource.dart | NO |
| `created_at` | TIMESTAMP | TODOS | SÍ |

**Schema actual (schema.sql):**
```sql
CREATE TABLE resources (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  file_url TEXT NOT NULL,
  file_size BIGINT,
  mime_type TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**❌ COLUMNAS FALTANTES:**
- `title` (usada en admin.js y frontend)
- `file_type` (usada en frontend y admin)
- `thumbnail_url` (usada en frontend)
- `download_url` (usada en frontend)
- `is_premium` (usada en admin)
- `downloads` (usada en stats)

**⚠️ INCONSISTENCIAS:**
- El código usa `name` y `title` indistintamente (admin.js:646 inserta ambos)
- Frontend espera `title` pero backend inserta `name`

---

### Tabla: `maps`

**Columnas usadas en el código:**

| Columna | Tipo | Usado en | Required |
|---------|------|----------|----------|
| `id` | UUID | TODOS | SÍ |
| `name` | TEXT | maps.js, MapResource.dart | SÍ |
| `description` | TEXT | maps.js | NO |
| `file_url` | TEXT | maps.js | SÍ |
| `thumbnail_url` | TEXT | maps.js | NO |
| `map_type` | TEXT | maps.js:150,178 | SÍ |
| `file_type` | TEXT | maps.js:40 | SÍ |
| `file_size` | BIGINT | maps.js:40 | SÍ |
| `region` | TEXT | maps.js:40 | NO |
| `scale` | TEXT | maps.js:40 | NO |
| `created_at` | TIMESTAMP | admin.js:579 | SÍ |

**Schema actual (schema.sql):**
```sql
CREATE TABLE maps (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  file_url TEXT NOT NULL,
  thumbnail_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**❌ COLUMNAS FALTANTES:**
- `map_type`
- `file_type`
- `file_size`
- `region`
- `scale`

---

### Tabla: `downloads`

**Columnas usadas en el código:**

| Columna | Tipo | Usado en | Required |
|---------|------|----------|----------|
| `id` | UUID | TODOS | SÍ |
| `user_id` | UUID | downloads.js | SÍ |
| `resource_id` | UUID | downloads.js | SÍ |
| `downloaded_at` | TIMESTAMP | downloads.js:45, stats.js:35 | SÍ |

**Schema actual (schema.sql):**
```sql
CREATE TABLE downloads (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  resource_id UUID REFERENCES resources(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

**⚠️ INCONSISTENCIAS:**
- El código usa `downloaded_at` pero el schema tiene `created_at`
- downloads.js:45 ordena por `downloaded_at`
- stats.js:35 filtra por `downloaded_at`

---

### Tabla: `notifications`

**Columnas usadas en el código:**

| Columna | Tipo | Usado en | Required |
|---------|------|----------|----------|
| `id` | UUID | TODOS | SÍ |
| `user_id` | UUID | notifications.js, admin.js | SÍ |
| `title` | TEXT | notifications.js, admin.js | SÍ |
| `message` | TEXT | notifications.js, admin.js | SÍ |
| `type` | TEXT | notifications.js, admin.js | SÍ |
| `is_read` | BOOLEAN | notifications.js | SÍ |
| `created_at` | TIMESTAMP | TODOS | SÍ |

**Schema actual (schema.sql):**
```
❌ NO EXISTE EN EL SCHEMA
```

**❌ TABLA FALTANTE:** `notifications` no está en schema.sql pero el código la usa extensivamente

---

### Tabla: `premium_plans`

**Columnas usadas en el código:**

| Columna | Tipo | Usado en | Required |
|---------|------|----------|----------|
| `id` | UUID | admin.js | SÍ |
| `plan_name` | TEXT | admin.js | SÍ |
| `display_name` | TEXT | admin.js, premium_screen.dart | SÍ |
| `price_monthly` | TEXT/NUM | admin.js, premium_screen.dart | SÍ |
| `price_lifetime` | TEXT/NUM | admin.js, premium_screen.dart | SÍ |
| `color` | TEXT | admin.js, premium_screen.dart | SÍ |
| `features` | TEXT[] | admin.js, premium_screen.dart | SÍ |
| `limitations` | TEXT[] | admin.js, premium_screen.dart | SÍ |
| `is_active` | BOOLEAN | admin.js:235 | SÍ |
| `sort_order` | INTEGER | admin.js:236, premium_screen.dart | SÍ |
| `created_at` | TIMESTAMP | NO USADO EXPLÍCITAMENTE | NO |
| `updated_at` | TIMESTAMP | admin.js:252 | SÍ |

**Schema actual (schema.sql):**
```
❌ NO EXISTE EN EL SCHEMA
```

**❌ TABLA FALTANTE:** `premium_plans` no está en schema.sql

---

## 3. STORAGE BUCKETS

### Buckets usados en el código:
- `maps` - maps.js:129-162 (upload de archivos de mapas)

### Buckets requeridos:
| Bucket | Uso | Estado |
|--------|-----|--------|
| `maps` | Upload de mapas (KML, KMZ, GPX, etc.) | ❌ NO DEFINIDO EN SCHEMA |
| `resources` | (Opcional) Upload de recursos | ⚠️ NO USADO PERO RECOMENDADO |

---

## 4. FOREIGN KEYS

### Foreign keys detectadas en el código:

| Tabla | Columna | Referencia | Estado |
|-------|---------|------------|--------|
| `downloads` | `user_id` | `users(id)` | ✅ En schema.sql |
| `downloads` | `resource_id` | `resources(id)` | ✅ En schema.sql |
| `notifications` | `user_id` | `users(id)` | ❌ FALTANTE |

---

## 5. RLS POLICIES

### Policies requeridas por el código:

| Tabla | Operación | Policy Requerida | Estado |
|-------|-----------|------------------|--------|
| `users` | SELECT | Authenticated users | ❌ FALTANTE |
| `users` | UPDATE | Own user or admin | ❌ FALTANTE |
| `resources` | SELECT | Public | ✅ En schema.sql |
| `resources` | INSERT | Admin only | ❌ FALTANTE (schema tiene public) |
| `resources` | UPDATE | Admin only | ❌ FALTANTE |
| `resources` | DELETE | Admin only | ❌ FALTANTE |
| `maps` | SELECT | Public | ✅ En schema.sql |
| `maps` | INSERT | Admin only | ❌ FALTANTE |
| `maps` | UPDATE | Admin only | ❌ FALTANTE |
| `maps` | DELETE | Admin only | ❌ FALTANTE |
| `downloads` | INSERT | Authenticated | ✅ En schema.sql (public) |
| `downloads` | SELECT | Own user or admin | ❌ FALTANTE |
| `notifications` | SELECT | Own user | ❌ FALTANTE |
| `notifications` | INSERT | System/Admin | ❌ FALTANTE |
| `notifications` | UPDATE | Own user | ❌ FALTANTE |
| `notifications` | DELETE | Own user or admin | ❌ FALTANTE |
| `premium_plans` | SELECT | Public | ❌ FALTANTE |
| `premium_plans` | INSERT/UPDATE/DELETE | Admin only | ❌ FALTANTE |

---

## 6. ÍNDICES

### Índices requeridos:

| Tabla | Columna | Razón | Estado |
|-------|---------|-------|--------|
| `resources` | `category` | Filtro por categoría | ✅ En schema.sql |
| `resources` | `created_at` | Ordenamiento | ❌ FALTANTE |
| `resources` | `name` | Búsqueda | ❌ FALTANTE |
| `downloads` | `resource_id` | Join/conteo | ✅ En schema.sql |
| `downloads` | `user_id` | Descargas por usuario | ❌ FALTANTE |
| `downloads` | `downloaded_at` | Filtro temporal | ❌ FALTANTE |
| `notifications` | `user_id` | Notificaciones por usuario | ❌ FALTANTE |
| `notifications` | `is_read` | Filtro no leídas | ❌ FALTANTE |
| `notifications` | `created_at` | Ordenamiento | ❌ FALTANTE |
| `users` | `username` | Login | ❌ FALTANTE |
| `users` | `is_premium` | Estadísticas | ❌ FALTANTE |
| `premium_plans` | `is_active` | Filtro activos | ❌ FALTANTE |
| `premium_plans` | `sort_order` | Ordenamiento | ❌ FALTANTE |

---

## 7. RESUMEN DE PROBLEMAS

### 🔴 CRÍTICOS (rompen funcionalidad):

1. **Tabla `notifications` no existe en schema.sql**
   - Usada en: admin.js, notifications.js, premiumExpiration.js, notification_service.dart
   - Impacto: Notificaciones no funcionan

2. **Tabla `premium_plans` no existe en schema.sql**
   - Usada en: admin.js, premium_screen.dart
   - Impacto: Gestión de planes premium no funciona

3. **Columna `downloaded_at` vs `created_at` en downloads**
   - Código usa `downloaded_at`, schema tiene `created_at`
   - Impacto: Error en stats y ordenamiento

4. **Columnas faltantes en `users`:**
   - `is_admin`, `password_hash`, `is_premium`, `premium_plan`, `subscription_end`, `favorites`
   - Impacto: Login admin, premium, favoritos no funcionan

5. **Columnas faltantes en `resources`:**
   - `title`, `file_type`, `thumbnail_url`, `download_url`, `is_premium`, `downloads`
   - Impacto: UI incompleta, filtros premium no funcionan

6. **Columnas faltantes en `maps`:**
   - `map_type`, `file_type`, `file_size`, `region`, `scale`
   - Impacto: Metadata de mapas incompleta

### 🟡 IMPORTANTES (degradan funcionalidad):

7. **Storage bucket `maps` no definido**
   - Upload de mapas no funciona

8. **RLS policies insuficientes**
   - Seguridad comprometida o operaciones bloqueadas

9. **Índices faltantes**
   - Performance degradado en queries complejas

10. **Inconsistencia `name` vs `title` en resources**
    - Confusión en el código, datos duplicados potenciales

---

## 8. MIGRACIONES REQUERIDAS

### 8.1 Tabla `notifications` (CREAR)

```sql
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'info',
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE is_read = false;
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);
```

### 8.2 Tabla `premium_plans` (CREAR)

```sql
CREATE TABLE IF NOT EXISTS premium_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_name TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  price_monthly TEXT DEFAULT '0',
  price_lifetime TEXT DEFAULT '0',
  color TEXT DEFAULT '#FF003C',
  features TEXT[] DEFAULT '{}',
  limitations TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_premium_plans_active ON premium_plans(is_active) WHERE is_active = true;
CREATE INDEX idx_premium_plans_sort ON premium_plans(sort_order);
```

### 8.3 Tabla `users` (ALTER)

```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_premium BOOLEAN DEFAULT false;
ALTER TABLE users ADD COLUMN IF NOT EXISTS premium_plan TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS subscription_end TIMESTAMP WITH TIME ZONE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS favorites UUID[] DEFAULT '{}';
ALTER TABLE users ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_premium ON users(is_premium);
```

### 8.4 Tabla `resources` (ALTER)

```sql
ALTER TABLE resources ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE resources ADD COLUMN IF NOT EXISTS file_type TEXT;
ALTER TABLE resources ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;
ALTER TABLE resources ADD COLUMN IF NOT EXISTS download_url TEXT;
ALTER TABLE resources ADD COLUMN IF NOT EXISTS is_premium BOOLEAN DEFAULT false;
ALTER TABLE resources ADD COLUMN IF NOT EXISTS downloads INTEGER DEFAULT 0;
ALTER TABLE resources ADD COLUMN IF NOT EXISTS drive_file_id TEXT;

CREATE INDEX IF NOT EXISTS idx_resources_created ON resources(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_resources_name ON resources(name);
CREATE INDEX IF NOT EXISTS idx_resources_premium ON resources(is_premium);
```

### 8.5 Tabla `maps` (ALTER)

```sql
ALTER TABLE maps ADD COLUMN IF NOT EXISTS map_type TEXT;
ALTER TABLE maps ADD COLUMN IF NOT EXISTS file_type TEXT;
ALTER TABLE maps ADD COLUMN IF NOT EXISTS file_size BIGINT;
ALTER TABLE maps ADD COLUMN IF NOT EXISTS region TEXT;
ALTER TABLE maps ADD COLUMN IF NOT EXISTS scale TEXT;

CREATE INDEX IF NOT EXISTS idx_maps_created ON maps(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_maps_region ON maps(region);
```

### 8.6 Tabla `downloads` (ALTER)

```sql
-- Opción 1: Renombrar created_at a downloaded_at
ALTER TABLE downloads RENAME COLUMN created_at TO downloaded_at;

-- Opción 2: Mantener ambos (más compatible)
-- ALTER TABLE downloads ADD COLUMN IF NOT EXISTS downloaded_at TIMESTAMP DEFAULT NOW();

CREATE INDEX IF NOT EXISTS idx_downloads_user ON downloads(user_id);
CREATE INDEX IF NOT EXISTS idx_downloads_date ON downloads(downloaded_at DESC);
```

### 8.7 Storage Bucket `maps`

```sql
-- Ejecutar en Supabase Dashboard > Storage
-- O vía API:
-- POST /storage/v1/bucket
-- {"id": "maps", "name": "maps", "public": true}
```

### 8.8 RLS Policies

```sql
-- notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  USING (auth.uid()::text = user_id::text OR is_admin = true);

CREATE POLICY "System can insert notifications"
  ON notifications FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can delete own notifications"
  ON notifications FOR DELETE
  USING (auth.uid()::text = user_id::text);

-- premium_plans
ALTER TABLE premium_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view active plans"
  ON premium_plans FOR SELECT
  USING (is_active = true);

CREATE POLICY "Admin can manage plans"
  ON premium_plans FOR ALL
  USING (auth.uid() IN (SELECT id FROM users WHERE is_admin = true));

-- users (actualizar)
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid()::text = id::text OR is_admin = true);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid()::text = id::text);

-- resources (admin write)
CREATE POLICY "Admin can manage resources"
  ON resources FOR ALL
  USING (auth.uid() IN (SELECT id FROM users WHERE is_admin = true));

-- maps (admin write)
CREATE POLICY "Admin can manage maps"
  ON maps FOR ALL
  USING (auth.uid() IN (SELECT id FROM users WHERE is_admin = true));

-- downloads (user read own)
CREATE POLICY "Users can view own downloads"
  ON downloads FOR SELECT
  USING (auth.uid()::text = user_id::text OR is_admin = true);
```

---

## 9. ARCHIVOS A MODIFICAR

### Backend:
- `backend/src/db/schema.sql` - Reescribir completo con todas las tablas
- `backend/src/routes/downloads.js` - Cambiar `downloaded_at` si se mantiene `created_at`
- `backend/src/routes/resources.js` - Estandarizar `name` vs `title`

### Frontend:
- `apps/mobile/lib/models/resource.dart` - Alinear con schema real
- `apps/mobile/lib/providers/app_provider.dart` - Validar columnas

---

## 10. VALIDACIONES POST-MIGRACIÓN

### Tests a ejecutar:

1. **Login Admin**
   ```bash
   curl -X POST https://backend-api-production-0cd8.up.railway.app/api/admin/login \
     -H "Content-Type: application/json" \
     -d '{"username":"admin","password":"..."}'
   ```

2. **Carga de Recursos**
   - Verificar que `resources` carga con `title`, `file_type`, `thumbnail_url`

3. **Descargas**
   - Verificar que `downloads` ordena por `downloaded_at`

4. **Notificaciones**
   - Verificar CRUD completo en `notifications`

5. **Planes Premium**
   - Verificar que `premium_plans` carga y filtra por `is_active`

6. **Storage**
   - Verificar upload de mapas a bucket `maps`

---

## 11. ESTADO ACTUAL

### ✅ Funciona:
- Login básico de usuarios
- Carga de recursos (campos básicos)
- Carga de mapas (campos básicos)
- Registro de descargas

### ❌ No funciona:
- Login admin (faltan columnas `is_admin`, `password_hash`)
- Gestión premium (falta tabla `premium_plans`)
- Notificaciones (falta tabla `notifications`)
- Filtros premium en recursos (falta columna `is_premium`)
- Metadata completa de mapas (faltan columnas)
- Upload de mapas a storage (falta bucket)
- Favoritos (falta columna `favorites`)

### ⚠️ Parcialmente funciona:
- Estadísticas (algunos conteos fallan)
- UI de recursos (campos incompletos)

---

## 12. RECOMENDACIONES

1. **Ejecutar migraciones en orden:**
   - 1º: Tablas faltantes (`notifications`, `premium_plans`)
   - 2º: Columnas faltantes (ALTER TABLE)
   - 3º: Índices
   - 4º: Storage buckets
   - 5º: RLS policies

2. **Backup antes de migrar:**
   ```bash
   pg_dump -h db.xxx.supabase.co -U postgres supabase_production > backup.sql
   ```

3. **Validar en entorno de staging primero**

4. **Actualizar documentación:**
   - `schema.sql` debe reflejar estado real
   - `FILES_MAP.md` debe listar columnas reales

---

**Fin del informe de auditoría.**
