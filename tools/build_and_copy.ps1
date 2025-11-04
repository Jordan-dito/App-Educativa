<#
tools/build_and_copy.ps1
Script para compilar APK y copiarlo a la ruta que Flutter espera.
Uso (desde la raíz del repo en PowerShell):
  .\tools\build_and_copy.ps1 -Configuration Release
  .\tools\build_and_copy.ps1 -Configuration Debug

Este script intenta ejecutar `flutter build apk` y si se genera el APK lo copia a:
  build\app\outputs\flutter-apk\app-<configuration>.apk

Devuelve código 0 si todo OK, distinto de 0 si hay error.
#>

param(
    [ValidateSet("Release","Debug")]
    [string]$Configuration = "Release"
)

Write-Host "Ejecutando build_and_copy.ps1 (Configuration=$Configuration)" -ForegroundColor Cyan

# Rutas
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$androidApkPath = Join-Path $root "android\app\build\outputs\apk\$($Configuration.ToLower())\app-$($Configuration.ToLower()).apk"
$flutterOutDir = Join-Path $root "build\app\outputs\flutter-apk"
$destApk = Join-Path $flutterOutDir "app-$($Configuration.ToLower()).apk"

# Ejecutar compilación
if ($Configuration -eq 'Release') {
    Write-Host "Corriendo: flutter build apk --release" -ForegroundColor Yellow
    $code = & flutter build apk --release
    $exit = $LASTEXITCODE
} else {
    Write-Host "Corriendo: flutter build apk --debug" -ForegroundColor Yellow
    $code = & flutter build apk --debug
    $exit = $LASTEXITCODE
}

if ($exit -ne 0) {
    Write-Host "La compilación devolvió código $exit. Revisa los logs anteriores." -ForegroundColor Red
    exit $exit
}

# Comprobar APK en la ruta de Gradle
if (Test-Path $androidApkPath) {
    Write-Host "APK generado: $androidApkPath" -ForegroundColor Green
    if (-not (Test-Path $flutterOutDir)) { New-Item -ItemType Directory -Force -Path $flutterOutDir | Out-Null }
    Copy-Item -Path $androidApkPath -Destination $destApk -Force
    Write-Host "Copiado a: $destApk" -ForegroundColor Green
    exit 0
} else {
    # Intentar buscar cualquier APK que coincida
    Write-Host "No se encontró el APK en la ruta esperada: $androidApkPath" -ForegroundColor Yellow
    Write-Host "Buscando .apk en android/app/build/outputs..." -ForegroundColor Yellow
    $found = Get-ChildItem -Path (Join-Path $root 'android\app\build\outputs') -Recurse -Filter *.apk -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
    if ($found) {
        $first = $found | Select-Object -First 1
        Write-Host "Se encontró APK alternativo: $($first.FullName)" -ForegroundColor Green
        if (-not (Test-Path $flutterOutDir)) { New-Item -ItemType Directory -Force -Path $flutterOutDir | Out-Null }
        Copy-Item -Path $first.FullName -Destination $destApk -Force
        Write-Host "Copiado a: $destApk" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "No se encontró ningún APK en android/app/build/outputs." -ForegroundColor Red
        Write-Host "Ejecuta tools\check_android_env.ps1 para comprobar el entorno (NDK, SDK, Flutter)." -ForegroundColor Cyan
        exit 2
    }
}
