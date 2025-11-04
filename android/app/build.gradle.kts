plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.colegio_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.colegio_app"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Configuración global para suprimir warnings de Java 8 obsoleto en dependencias
tasks.withType<JavaCompile> {
    options.compilerArgs.add("-Xlint:-options")
}

// Tarea para asegurar que el APK esté en la ubicación esperada por Flutter (debug y release)
afterEvaluate {
    val buildTasks = listOf("assembleDebug", "assembleRelease")
    
    buildTasks.forEach { taskName ->
        tasks.findByName(taskName)?.let { task ->
            task.doLast {
                val buildType = if (taskName.contains("Release")) "release" else "debug"
                val apkSource = file("${layout.buildDirectory.get()}/outputs/flutter-apk/app-$buildType.apk")
                val flutterRoot = project.rootDir.parentFile
                val apkTarget = file("${flutterRoot}/build/app/outputs/flutter-apk/app-$buildType.apk")
                
                if (apkSource.exists()) {
                    apkTarget.parentFile.mkdirs()
                    apkSource.copyTo(apkTarget, overwrite = true)
                    println("✓ APK $buildType disponible en: ${apkTarget.absolutePath}")
                }
            }
        }
    }
}
