# 🚀 Configuración de Splash Screen Nativa

## ✅ Archivos Configurados

He configurado todos los archivos necesarios para la splash screen nativa:

### Archivos Android Creados/Modificados:
- `android/app/src/main/res/drawable/splash_background.xml` - Fondo de la splash screen
- `android/app/src/main/res/drawable/splash_logo.xml` - Logo temporal (placeholder)
- `android/app/src/main/res/values/colors.xml` - Colores para splash screen
- `android/app/src/main/res/values-night/colors.xml` - Colores para modo oscuro
- `android/app/src/main/res/values/styles.xml` - Estilos actualizados

## 📸 Pasos para Usar Tu Imagen

### 1. Preparar tu imagen
- **Formato**: PNG (recomendado) o JPG
- **Tamaño recomendado**: 512x512 píxeles o más
- **Fondo**: Preferiblemente transparente o con fondo sólido

### 2. Colocar la imagen
```
📁 assets/images/
  └── splash_logo.png  ← Tu imagen aquí
```

### 3. Crear diferentes tamaños (opcional pero recomendado)
Para mejor calidad en diferentes dispositivos, crea estas versiones:

```
📁 android/app/src/main/res/
  ├── drawable-mdpi/splash_logo.png    (72x72)
  ├── drawable-hdpi/splash_logo.png    (96x96)
  ├── drawable-xhdpi/splash_logo.png   (144x144)
  ├── drawable-xxhdpi/splash_logo.png  (192x192)
  └── drawable-xxxhdpi/splash_logo.png (288x288)
```

### 4. Personalizar colores
Edita `android/app/src/main/res/values/colors.xml`:
```xml
<color name="splash_background_color">#FFFFFF</color> <!-- Cambia este color -->
```

### 5. Compilar y probar
```bash
flutter clean
flutter build apk --debug
```

## 🎨 Personalización Avanzada

### Cambiar duración de la splash screen
En `android/app/src/main/kotlin/com/example/colegio_app/MainActivity.kt`, puedes agregar:
```kotlin
// Mantener splash screen por 3 segundos
Handler(Looper.getMainLooper()).postDelayed({
    // Tu código aquí
}, 3000)
```

### Animaciones personalizadas
Modifica `android/app/src/main/res/values/styles.xml`:
```xml
<style name="SplashScreenAnimation" parent="@android:style/Animation">
    <item name="android:windowEnterAnimation">@android:anim/slide_in_left</item>
    <item name="android:windowExitAnimation">@android:anim/slide_out_right</item>
</style>
```

## 🚨 Notas Importantes

1. **Reemplaza el placeholder**: El archivo `splash_logo.xml` actual es temporal
2. **Optimiza imágenes**: Usa herramientas como TinyPNG para reducir tamaño
3. **Prueba en diferentes dispositivos**: Verifica que se vea bien en tablets y móviles
4. **Modo oscuro**: La app ya está configurada para modo oscuro automáticamente

## 🔧 Solución de Problemas

### Si la splash screen no aparece:
1. Verifica que `splash_logo.png` esté en `assets/images/`
2. Ejecuta `flutter clean` y vuelve a compilar
3. Revisa que no haya errores en `flutter logs`

### Si la imagen se ve distorsionada:
1. Usa una imagen cuadrada (1:1 ratio)
2. Asegúrate de que el tamaño sea apropiado
3. Considera usar formato SVG para escalabilidad

¡Tu splash screen nativa está lista! Solo necesitas agregar tu imagen. 🎉
