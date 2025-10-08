# 📱 Guía para Compilar APK - Sistema Colegio

## 🚀 Opción 1: Script Automático (Recomendado)

1. **Ejecutar el script automático:**
   ```bash
   build_apk.bat
   ```

## 🔧 Opción 2: Configuración Manual

### Prerrequisitos

1. **Android Studio instalado** con Android SDK
2. **Flutter SDK** configurado
3. **Variables de entorno** configuradas

### Pasos para Compilar

1. **Configurar Android SDK:**
   ```bash
   # En PowerShell o CMD
   set ANDROID_HOME=C:\Users\%USERNAME%\AppData\Local\Android\Sdk
   # O la ruta donde tengas instalado Android SDK
   ```

2. **Aceptar licencias de Android:**
   ```bash
   flutter doctor --android-licenses
   ```

3. **Limpiar proyecto:**
   ```bash
   flutter clean
   flutter pub get
   ```

4. **Compilar APK:**
   ```bash
   # APK de Release (recomendado para distribución)
   flutter build apk --release
   
   # APK de Debug (para pruebas)
   flutter build apk --debug
   ```

## 📍 Ubicación del APK

Una vez compilado exitosamente, el APK se encontrará en:
```
build/app/outputs/flutter-apk/app-release.apk
```

## 🌐 Opción 3: Herramientas Online

Si no puedes compilar localmente, puedes usar herramientas online:

1. **Codemagic** (https://codemagic.io)
2. **GitHub Actions** con Flutter
3. **Bitrise** (https://bitrise.io)

### Para usar herramientas online:
1. Sube el código a un repositorio Git
2. Conecta el repositorio con la herramienta
3. Configura el pipeline de compilación
4. Descarga el APK generado

## 🔍 Solución de Problemas

### Error: "Android SDK not found"
```bash
# Verificar instalación de Android Studio
flutter doctor -v

# Configurar ANDROID_HOME manualmente
set ANDROID_HOME=C:\Android\Sdk
```

### Error: "License not accepted"
```bash
flutter doctor --android-licenses
# Acepta todas las licencias presionando 'y'
```

### Error: "Build failed"
```bash
# Limpiar completamente
flutter clean
rm -rf build/
flutter pub get
flutter build apk --release
```

## 📋 Información del Proyecto

- **Nombre:** Sistema Colegio
- **Versión:** 1.0.0
- **Plataforma:** Android
- **Framework:** Flutter
- **Lenguaje:** Dart

## 🎯 Características de la App

✅ **Gestión de Estudiantes** - CRUD completo
✅ **Gestión de Profesores** - CRUD completo  
✅ **Gestión de Materias** - CRUD completo
✅ **Dashboard Interactivo** - Estadísticas y navegación
✅ **Almacenamiento Local** - SharedPreferences
✅ **Interfaz Moderna** - Material Design

## 📞 Soporte

Si tienes problemas compilando el APK:
1. Verifica que Android Studio esté instalado
2. Ejecuta `flutter doctor` para diagnosticar problemas
3. Asegúrate de tener las licencias de Android aceptadas
4. Considera usar herramientas online como alternativa