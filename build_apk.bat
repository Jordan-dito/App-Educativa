@echo off
echo ========================================
echo    SCRIPT PARA COMPILAR APK
echo ========================================
echo.

echo Configurando variables de entorno...
set ANDROID_HOME=C:\Android\Sdk
set PATH=%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;%PATH%

echo.
echo Verificando configuracion de Flutter...
flutter doctor

echo.
echo Limpiando proyecto...
flutter clean

echo.
echo Obteniendo dependencias...
flutter pub get

echo.
echo Compilando APK...
flutter build apk --release

echo.
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ========================================
    echo    APK COMPILADO EXITOSAMENTE!
    echo ========================================
    echo.
    echo El APK se encuentra en:
    echo build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo Tamaño del archivo:
    for %%A in ("build\app\outputs\flutter-apk\app-release.apk") do echo %%~zA bytes
) else (
    echo ========================================
    echo    ERROR AL COMPILAR APK
    echo ========================================
    echo.
    echo Posibles soluciones:
    echo 1. Instalar Android SDK desde Android Studio
    echo 2. Configurar ANDROID_HOME correctamente
    echo 3. Aceptar las licencias de Android: flutter doctor --android-licenses
)

echo.
pause