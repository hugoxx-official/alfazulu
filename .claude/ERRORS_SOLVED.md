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
