# ERRORS SOLVED

## req.supabase.from(...).count is not a function

### Error
`TypeError: req.supabase.from(...).count is not a function` en stats endpoint

### Causa
Supabase v2 cambió la API de count. El método `.count()` directo ya no existe.

### Solución
Cambiar a:
```javascript
const { count } = await req.supabase
  .from('resources')
  .select('*', { count: 'exact', head: true });
```

### Archivos
- `backend/src/routes/admin.js`

### Prevención
Usar siempre el patrón `{ count: 'exact', head: true }` en select para contar registros.

### Verificación
Stats endpoint devuelve números correctos sin errores.

---

## CORS PATCH method not allowed

### Error
CORS no permitía método PATCH en peticiones desde Flutter Web.

### Causa
Methods array en CORS configuration solo incluía GET, POST, PUT, DELETE.

### Solución
Añadir PATCH al array:
```javascript
methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS']
```

### Archivos
- `backend/src/server.js`

### Prevención
Incluir siempre todos los métodos HTTP que se usen en la aplicación.

### Verificación
Peticiones PATCH desde Flutter Web funcionan correctamente.

---

## Could not find 'is_admin' column of 'users'

### Error
Error al intentar leer/actualizar columnas is_admin, password_hash, is_premium, etc.

### Causa
Las columnas no existían en la tabla users de Supabase.

### Solución
Ejecutar SQL:
```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_premium BOOLEAN DEFAULT false;
ALTER TABLE users ADD COLUMN IF NOT EXISTS premium_plan TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS subscription_end TIMESTAMP;
```

### Archivos
- Database Supabase

### Prevención
Verificar schema antes de añadir features que requieran nuevas columnas.

### Verificación
Login admin y asignación de planes funcionan correctamente.

---

## 401 Unauthorized on admin login

### Error
Login admin devolvía 401 aunque las credenciales eran correctas.

### Causa
El usuario admin no existía en la base de datos.

### Solución
Crear script `create-admin.js` que:
1. Hashea password con bcrypt
2. Inserta usuario en Supabase con is_admin=true

### Archivos
- `backend/scripts/create-admin.js`

### Prevención
Verificar existencia de usuarios críticos antes de intentar login.

### Verificación
Login admin funciona y redirige al panel correctamente.

---

## flutter_bootstrap.js builds array has empty {} object

### Error
El archivo flutter_bootstrap.js tenía `"builds":[{...},{}]` con un objeto vacío.

### Causa
Flutter build generó un objeto vacío adicional en el array builds.

### Solución
Editar manualmente el archivo para eliminar el objeto vacío:
`"builds":[{...},{}]` → `"builds":[{...}]`

### Archivos
- `apps/mobile/build/web/flutter_bootstrap.js`

### Prevención
Revisar el output de flutter build web antes de deploy.

### Verificación
Flutter web app carga sin errores de parsing JSON.

---

## GitHub push blocked due to secrets in DEPLOYMENT_GUIDE.md

### Error
Push rechazado porque el archivo contenía credenciales reales.

### Causa
DEPLOYMENT_GUIDE.md incluía tokens y URLs sensibles.

### Solución
1. git reset --hard para eliminar commit con credenciales
2. Reemplazar credenciales con placeholders en el archivo
3. Commit limpio

### Archivos
- `DEPLOYMENT_GUIDE.md`

### Prevención
Nunca commitear credenciales reales. Usar siempre placeholders.

### Verificación
Push a GitHub exitoso sin alertas de seguridad.

---

## Notificaciones no aparecen como sistema con app abierta

### Error
Las notificaciones funcionaban in-app pero NO aparecían como notificación real del sistema Android cuando la app estaba abierta (foreground).

### Causa
El sistema de notificaciones no estaba configurado con:
- Importancia HIGH/MAX en Android
- Prioridad alta para mostrar banner
- Canal de notificación correcto
- Configuración para foreground notifications

### Solución
Reescrito `notification_service.dart` completamente:

1. **Canales de notificación**:
   - `alfazulu_notifications`: Importancia HIGH para notificaciones normales
   - `alfazulu_instant`: Importancia MAX para premium/admin

2. **Configuración Android crítica**:
   ```dart
   AndroidNotificationDetails(
     channelId,
     channelName,
     importance: Importance.high,  // CRÍTICO
     priority: Priority.high,       // CRÍTICO
     icon: '@mipmap/ic_launcher',
     playSound: true,
     enableVibration: true,
     showBadge: true,
     category: AndroidNotificationCategory.message,
     visibility: NotificationVisibility.public,
   )
   ```

3. **Permisos Android 13+**:
   - POST_NOTIFICATIONS en AndroidManifest.xml
   - Solicitud runtime de permisos

4. **Foreground polling**:
   - Timer cada 30 segundos verifica nuevas notificaciones
   - Muestra notificación del sistema automáticamente

### Archivos
- `apps/mobile/lib/services/notification_service.dart` (reescrito)
- `apps/mobile/android/app/src/main/AndroidManifest.xml` (permisos)

### Prevención
- Usar siempre Importance.high o superior
- Configurar canales antes de mostrar notificaciones
- Verificar permisos en Android 13+

### Verificación
- Notificaciones aparecen como banner con app abierta
- Sonido y vibración funcionan
- Badge se actualiza
- Funciona en foreground y background

---

## PostgrestException: could not find 'file_name' on table resources

### Error
`PostgrestException: could not find file_name on table resources` al cargar descargas.

### Causa
La tabla `public.resources` en Supabase NO tiene columna `file_name`. La columna correcta es `name`.

Estructura REAL de `public.resources`:
- `id` UUID
- `name` TEXT NOT NULL
- `category` TEXT NOT NULL
- `description` TEXT
- `file_url` TEXT NOT NULL
- `file_size` BIGINT
- `mime_type` TEXT
- `created_at` TIMESTAMP

### Solución
Reemplazar `file_name` por `name` en todas las consultas:

1. **backend/src/routes/downloads.js** (línea 25):
   ```javascript
   .select('file_url, name')  // antes: file_name
   ```

2. **backend/src/routes/resources.js** (línea 74):
   ```javascript
   .insert([{ name, category, description, file_url, file_size, mime_type }])
   // eliminado: file_name
   ```

3. **backend/src/services/driveSync.js** (líneas 67, 80):
   ```javascript
   // Eliminado file_name de update() e insert()
   ```

4. **backend/src/db/schema.sql**:
   ```sql
   -- Eliminada línea: file_name TEXT,
   ```

### Archivos
- `backend/src/routes/downloads.js`
- `backend/src/routes/resources.js`
- `backend/src/services/driveSync.js`
- `backend/src/db/schema.sql`

### Prevención
- Verificar schema real de Supabase antes de escribir consultas
- Usar siempre `SELECT *` para inspeccionar columnas existentes
- Mantener schema.sql sincronizado con la base de datos real

### Verificación
- Downloads endpoint funciona sin errores
- Resources carga correctamente
- flutter analyze sin errores
- No más PostgrestException
