# AlfaZulu - Project Memory

## Arquitectura
- **Frontend**: Flutter Web (mobile-first)
- **Backend**: Node.js + Express
- **Database**: Supabase (PostgreSQL)
- **Deployment**: Railway (backend), Flutter web build (static)
- **Renderer**: CanvasKit

## Repositorios GitHub
- **Frontend Web**: https://github.com/hugoxx-official/alfazulu.git
- **Backend**: https://github.com/hugoxx-official/alfazulu-backend.git

## Objetivo
Gestión de recursos militares con sistema premium, favoritos por usuario, y panel de administración.

## Stack
- Flutter 3.x
- Node.js 18+
- Supabase v2
- Telegram Bot API (notificaciones)
- bcrypt (password hashing)

## Diseño
- Tema oscuro (#0A0A0A background)
- Acentos rojos neon
- Fuente: Orbitron (títulos), Google Fonts
- Cards premium con:
  - Hover effects (scale 1.02x)
  - Neon border glow (red, opacity 0.3→0.8)
  - Dynamic shadows (elevation 2→8)
  - Gradient overlays en thumbnails
  - Dual badges (file type + category)

## Responsive Grid
- Mobile (<600px): 2 columns, 16px padding
- Tablet (600-1200px): 3 columns, 24px padding
- Desktop (>1200px): 4 columns, 32px padding

## Configuración Importante
- API URL: https://backend-api-production-0cd8.up.railway.app/api
- CORS: GET, POST, PUT, PATCH, DELETE, OPTIONS
- Session persistence: SharedPreferences
- Favorites: Per-user (stored in users.favorites array)

## Premium Plans
- Free: Icono shield (grey)
- Premium: Icono star (amber)
- Premium+: Icono trophy (red)
- Payment: Bizum only (monthly/lifetime)
- Telegram notifications on premium request

## Admin Features
- CRUD de planes premium
- Stats reales desde DB
- User management
- Plan assignment con Telegram log
