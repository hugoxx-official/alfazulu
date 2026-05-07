# GITHUB WORKFLOW

## Repository
- **URL**: https://github.com/hugoxx-official/alfazulu
- **Rama**: master
- **Estado**: Up to date

## Último Commit
```
Commit: f5a63f5
Message: Feature: Premium cards with responsive grid
Changes: 7 files, +1518 -768
```

## Convenciones de Commit

### Tipos
- `feat:` - Nueva funcionalidad
- `fix:` - Corrección de bugs
- `ui:` - Cambios visuales/diseño
- `refactor:` - Refactorización de código
- `docs:` - Documentación
- `test:` - Tests
- `chore:` - Mantenimiento

### Formato
```bash
git commit -m "tipo: descripción"
```

### Ejemplos
```
feat: premium cards with hover effects
fix: responsive grid breakpoints
ui: neon border glow animation
refactor: app_provider favorites logic
docs: update PROJECT_MEMORY.md
```

## Workflow
1. git status
2. git add <files>
3. git commit -m "tipo: descripción"
4. git push origin master

## Protected
- No force push a master
- No skip hooks (--no-verify)
- No commit de credenciales (.env, tokens, URLs sensibles)
