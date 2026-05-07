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
- **Features**: Users tab, Plans tab, stats reales
- **Advertencias**: Requiere login admin con bcrypt

### apps/mobile/lib/screens/settings_screen.dart
- **Función**: Ajustes y perfil de usuario
- **Dependencias**: app_provider
- **Features**: Premium badge, días restantes, plan display
- **Advertencias**: Color coding de días (verde >7, naranja <7, rojo 0)

### apps/mobile/lib/models/user.dart
- **Función**: Modelo de usuario
- **Campos**: id, username, favorites[], isPremium, premiumPlan, subscriptionEnd

### apps/mobile/lib/models/resource.dart
- **Función**: Modelo de recurso
- **Campos**: id, title, category, fileType, fileSize, thumbnailUrl, downloadUrl

## Backend Node.js

### backend/src/server.js
- **Función**: Servidor Express + CORS
- **Config**: CORS methods ['GET','POST','PUT','PATCH','DELETE','OPTIONS']

### backend/src/routes/admin.js
- **Función**:Endpoints admin (login, stats, plans CRUD, premium-request)
- **Features**: Telegram notifications, stats reales
- **Endpoints**: POST /login, GET /stats, GET/POST/PUT/DELETE /plans, POST /premium-request

### backend/src/routes/resources.js
- **Función**: Endpoints de recursos
- **Features**: Favoritos por usuario, búsqueda
- **Endpoints**: GET /, POST /:id/favorite, GET /favorites/:user_id

### backend/src/routes/users.js
- **Función**: Gestión de usuarios
- **Features**: Telegram log en premium assignment
- **Endpoints**: POST / (crear), PUT /:id (actualizar premium)

### backend/premium_plans.sql
- **Función**: Schema de planes premium
- **Defaults**: Free, Premium, Premium+ con features/limitations

## Database Supabase

### Tablas
- **users**: id, username, favorites[], is_admin, password_hash, is_premium, premium_plan, subscription_end
- **resources**: id, title, description, category, file_type, file_size, thumbnail_url, download_url, downloads, is_premium
- **maps**: id, title, description, image_url
- **premium_plans**: id, plan_name, display_name, price, color, features[], limitations[], payment_type
