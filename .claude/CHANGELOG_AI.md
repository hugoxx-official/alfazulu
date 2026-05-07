# CHANGELOG AI

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
