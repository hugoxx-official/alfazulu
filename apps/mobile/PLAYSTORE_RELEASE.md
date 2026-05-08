# AlfaZulu - Google Play Store Release

## Información del Build

- **Archivo**: `build/app/outputs/bundle/release/app-release.aab`
- **Tamaño**: 44.1 MB
- **Package**: `com.alfazulu.app`
- **Version**: 1.0.0
- **Version Code**: 1
- **Min SDK**: Android 5.0 (API 21)
- **Target SDK**: Android 15 (API 36)

## Firma Digital (Keystore)

**IMPORTANTE**: Guarda el keystore en un lugar seguro. Sin él, NO podrás actualizar la app en Play Store.

- **Ubicación**: `android/alfazulu-release-key.keystore`
- **Alias**: `alfazulu`
- **Contraseña**: `alfazulu2026`
- **Validez**: 10,000 días (~27 años)

## Archivos de Configuración

### key.properties (NO subir a GitHub)
```properties
storePassword=alfazulu2026
keyPassword=alfazulu2026
keyAlias=alfazulu
storeFile=../alfazulu-release-key.keystore
```

### .gitignore actualizado
```
# Keystore y signing
*.keystore
key.properties
```

## Checklist para Play Store

### 1. Google Play Console
- [ ] Crear cuenta de desarrollador ($25 USD pago único)
- [ ] Crear nueva aplicación
- [ ] Subir AAB: `app-release.aab`

### 2. Ficha de la tienda
- [ ] **Título**: AlfaZulu - Gestión de Recursos
- [ ] **Descripción corta**: Plataforma profesional de gestión de recursos militares
- [ ] **Descripción completa**: (ver más abajo)
- [ ] **Icono 512x512**: `logo1.png` (redimensionar)
- [ ] **Imagen destacada 1024x500**: Crear banner
- [ ] **Capturas de pantalla**: Mínimo 2 (móvil y tablet)

### 3. Clasificación de contenido
- [ ] Cuestionario IARC (clasificación por edades)
- [ ] Política de privacidad (URL requerida)
- [ ] Términos de servicio (URL requerida)

### 4. Configuración de precios
- [ ] Gratis o de pago
- [ ] Países de distribución
- [ ] Compras in-app (si aplica para Premium)

### 5. Lanzamiento
- [ ] Producción (público general)
- [ ] Prueba cerrada/abierta (opcional)

## Descripción Sugerida

```
AlfaZulu es una plataforma profesional diseñada para la gestión y distribución de recursos tácticos militares.

CARACTERÍSTICAS PRINCIPALES:
• Catálogo de recursos militares organizado por categorías
• Mapas tácticos descargables
• Sistema de evaluación TGCF (Test General de Condición Física)
• Planes Premium con contenido exclusivo
• Notificaciones en tiempo real
• Interfaz moderna y fácil de usar

RECURSOS DISPONIBLES:
- Documentación técnica
- Mapas y planos
- Material de entrenamiento
- Guías y procedimientos

PLANES PREMIUM:
Accede a contenido exclusivo con nuestros planes Premium y Premium+. Más recursos, más descargas y soporte prioritario.

SEGURIDAD:
Tus datos están protegidos con encriptación de extremo a extremo. Cumplimos con los estándares más altos de seguridad.

¿NECESITAS AYUDA?
Contacto: soporte@alfazulu.com

Términos de uso: https://alfazulu.com/terms
Política de privacidad: https://alfazulu.com/privacy
```

## Comandos Útiles

### Generar nuevo AAB
```bash
cd apps/mobile
flutter build appbundle --release
```

### Generar APK para testing
```bash
flutter build apk --release
```

### Verificar firma del AAB
```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

### Ver información del keystore
```bash
keytool -list -v -keystore android/alfazulu-release-key.keystore -alias alfazulu -storepass alfazulu2026
```

## Actualizaciones Futuras

Para cada nueva versión:

1. **Incrementar versionCode** (obligatorio, debe ser único)
2. **Actualizar versionName** (visible para usuarios)
3. **Rebuild**: `flutter build appbundle --release`
4. **Subir** nuevo AAB a Play Console

Ejemplo en `pubspec.yaml`:
```yaml
version: 1.1.0+2  # versionName=1.1.0, versionCode=2
```

## Notas Importantes

1. **NUNCA pierdas el keystore** - Sin él no puedes actualizar la app
2. **Haz backup** del keystore en múltiples ubicaciones seguras
3. **versionCode** debe incrementarse en cada release
4. **Prueba en production track** antes de lanzar a todo el público
5. **Monitorea** Android Vitals después del lanzamiento

## Contacto Soporte

- Email: soporte@alfazulu.com
- Web: https://alfazulu.com
