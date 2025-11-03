<#
tools/check_android_env.ps1
Comprobaciones rápidas para el entorno Android usado por este proyecto.
Ejecútalo en PowerShell: .\tools\check_android_env.ps1
#>

Write-Host "Comprobando entorno Flutter/Android..." -ForegroundColor Cyan

function Exec { param($cmd) try { & $cmd 2>$null } catch { return $null } }

# 1) Flutter
Write-Host "\n1) Flutter:" -ForegroundColor Yellow
$flutter = Exec { flutter --version }
if ($LASTEXITCODE -ne 0 -or -not $flutter) {
    Write-Host "  Flutter no está disponible en PATH. Ejecuta: https://docs.flutter.dev/get-started/install" -ForegroundColor Red
} else {
    Write-Host "  Flutter disponible: " -NoNewline; flutter --version | Select-Object -First 1
}

# 2) ANDROID_SDK_ROOT or ANDROID_HOME
Write-Host "\n2) Android SDK:" -ForegroundColor Yellow
$androidSdk = $env:ANDROID_SDK_ROOT; if (-not $androidSdk) { $androidSdk = $env:ANDROID_HOME }
if (-not $androidSdk) {
    Write-Host "  No se encontró ANDROID_SDK_ROOT ni ANDROID_HOME en variables de entorno." -ForegroundColor Red
    Write-Host "  (Instala Android SDK o configura ANDROID_SDK_ROOT)" -ForegroundColor Red
} else {
    Write-Host "  ANDROID_SDK_ROOT = $androidSdk" -ForegroundColor Green
}

# 3) sdkmanager
Write-Host "\n3) sdkmanager (Android cmdline-tools):" -ForegroundColor Yellow
$sdkManagerPath = Join-Path $androidSdk 'tools\bin\sdkmanager.bat'
if (-not (Test-Path $sdkManagerPath)) { $sdkManagerPath = Join-Path $androidSdk 'cmdline-tools\latest\bin\sdkmanager.bat' }
if (-not (Test-Path $sdkManagerPath)) {
    Write-Host "  sdkmanager no encontrado. Instala 'Android SDK Command-line Tools' desde Android Studio SDK Manager." -ForegroundColor Red
} else {
    Write-Host "  sdkmanager encontrado: $sdkManagerPath" -ForegroundColor Green
}

# 4) NDK
Write-Host "\n4) NDK requerida por este proyecto:" -ForegroundColor Yellow
$requiredNdk = '27.0.12077973'
$ndkDirs = @()
if ($androidSdk) {
    $ndkRoot = Join-Path $androidSdk 'ndk'
    if (Test-Path $ndkRoot) { $ndkDirs = Get-ChildItem -Directory -Path $ndkRoot | Select-Object -ExpandProperty Name }
}
if ($ndkDirs -contains $requiredNdk) {
    Write-Host "  NDK $requiredNdk instalado." -ForegroundColor Green
} else {
    Write-Host "  NDK $requiredNdk NO está instalado." -ForegroundColor Red
    if ($sdkManagerPath) {
        Write-Host "  Para instalar (requiere aceptar licencias):" -ForegroundColor Cyan
        Write-Host "    & `"$sdkManagerPath`" ""ndk;$requiredNdk""" -ForegroundColor White
        Write-Host "  O desde Android Studio: SDK Manager -> SDK Tools -> NDK (Side by side) -> Instalar la versión $requiredNdk" -ForegroundColor White
    }
}

# 5) Comprobación del APK generado (si ya se compiló)
Write-Host "\n5) APKs ya construidos (si existen):" -ForegroundColor Yellow
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$apkPaths = Get-ChildItem -Path $repoRoot -Recurse -Filter *.apk -ErrorAction SilentlyContinue | Select-Object FullName,Length,LastWriteTime
if ($apkPaths) { $apkPaths | Format-Table -AutoSize } else { Write-Host "  No se encontraron APKs en el repo." }

# 6) Flutter doctor summary
Write-Host "\n6) Resumen rápido de 'flutter doctor -v' (primeras 20 líneas):" -ForegroundColor Yellow
try { flutter doctor -v | Select-Object -First 20 } catch { Write-Host "  No se pudo ejecutar 'flutter doctor -v'." -ForegroundColor Red }

Write-Host "\nComprobación finalizada. Si detectas problemas, sigue las instrucciones impresas arriba." -ForegroundColor Cyan
