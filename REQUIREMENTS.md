# Requisitos del Sistema - Resumen Rápido

## Versiones Exactas Requeridas

| Componente | Versión Requerida | Notas |
|------------|-------------------|-------|
| **Flutter SDK** | `>=3.0.0` | Recomendado: última versión estable |
| **Dart SDK** | `>=3.0.0 <4.0.0` | Incluido con Flutter |
| **Android Studio** | `Giraffe \| 2022.3.1+` | O última versión estable |
| **Java JDK** | `17` (Java 17 LTS) | Recomendado: Java 17 o 21 (LTS). Mínimo: Java 11 |
| **Android SDK** | `35` (Android 15) | Para compileSdk y targetSdk |
| **minSdk** | `21` (Android 5.0) | Compatibilidad mínima |
| **Gradle** | `8.12` | Se descarga automáticamente |
| **Android Gradle Plugin** | `8.9.1` | Configurado en el proyecto |
| **Kotlin** | `2.1.0` | Configurado en el proyecto |

## Verificación Rápida

Ejecuta estos comandos para verificar tu instalación:

```bash
# Verificar Flutter
flutter --version
# Debe mostrar: Flutter >=3.0.0

# Verificar Java
java -version
# Debe mostrar: version "17.x.x" o "21.x.x" (recomendado)
# También acepta: version "11.x.x" (mínimo)

# Verificar variables de entorno (Windows)
echo %JAVA_HOME%
echo %ANDROID_HOME%

# Verificar todo con Flutter Doctor
flutter doctor -v
```

## Instalación Mínima

1. **Flutter**: https://flutter.dev/docs/get-started/install
2. **Android Studio**: https://developer.android.com/studio
3. **Java 17 o 21**: https://adoptium.net/ (OpenJDK 17 LTS recomendado, o Java 21 LTS)

## Configuración de Variables de Entorno (Windows)

```cmd
setx JAVA_HOME "C:\Program Files\Java\jdk-17"
# O para Java 21:
# setx JAVA_HOME "C:\Program Files\Java\jdk-21"
setx ANDROID_HOME "C:\Users\%USERNAME%\AppData\Local\Android\Sdk"
setx PATH "%PATH%;%FLUTTER_HOME%\bin;%ANDROID_HOME%\platform-tools"
```

## Compatibilidad

- ✅ **Android**: 5.0 (Lollipop) hasta la última versión
- ❌ **iOS**: No configurado (solo Android)

## Problemas Comunes

### Error: "Java version X is not supported"
**Solución**: Instala Java 17 o 21 (recomendado) y configura `JAVA_HOME`. El proyecto ahora soporta Java 11, 17 y 21

### Error: "Android SDK not found"
**Solución**: Instala Android SDK desde Android Studio y configura `ANDROID_HOME`

### Error: "Gradle sync failed"
**Solución**: Asegúrate de tener conexión a internet para descargar Gradle 8.12

---

**Nota**: Para más detalles, consulta el archivo `README.md` en la sección "Requisitos del Sistema".

