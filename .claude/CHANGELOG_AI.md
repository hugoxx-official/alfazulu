# CHANGELOG AI

## 2026-05-07 - Premium Cards + Responsive Grid

### Changes
- Complete rewrite of `resource_card.dart` with premium design
- Implemented responsive grid in `home_screen.dart` using SliverLayoutBuilder
- Dynamic breakpoints: mobile (2 cols), tablet (3 cols), desktop (4 cols)

### Files Modified
- `apps/mobile/lib/widgets/resource_card.dart` - Premium card design
- `apps/mobile/lib/screens/home_screen.dart` - Responsive grid
- `apps/mobile/lib/providers/app_provider.dart` - Favorites per user
- `apps/mobile/lib/screens/premium_screen.dart` - Plan selection
- `apps/mobile/lib/screens/admin_screen.dart` - Plan management
- `apps/mobile/lib/screens/settings_screen.dart` - Premium badge
- `apps/mobile/lib/widgets/add_resource_dialog.dart` - Resource upload

### Features Added
- Hover scale animation (Matrix4)
- Neon border glow (BorderSide dynamic)
- Dynamic shadows (red tint)
- Enhanced thumbnails (160px desktop, gradient overlay)
- Dual badges (file type + category)
- SliverLayoutBuilder for responsive grid
- Optimized spacing per breakpoint

### Commit
```
Feature: Premium cards with responsive grid
```
