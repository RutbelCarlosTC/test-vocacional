import java.util.Properties
import java.io.FileInputStream

// 1. Leer el archivo key.properties (Sintaxis Kotlin DSL)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter debe ir después de Android y Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ceprunsa.conocet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "30.0.14904198"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // 2. Configurar el contenedor de firmas en Kotlin DSL
    signingConfigs {
        create("release") {
            val keystoreFile = keystoreProperties.getProperty("storeFile")
            storeFile = if (keystoreFile != null) rootProject.file(keystoreFile) else null
            storePassword = keystoreProperties.getProperty("storePassword")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
        }
    }

    defaultConfig {
        applicationId = "com.ceprunsa.conocet"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // 3. Asignar la firma de release que acabamos de crear arriba
            signingConfig = signingConfigs.getByName("release")
            ndk {
                debugSymbolLevel = "NONE"
            }
        }
    }
    packaging {
        jniLibs {
            useLegacyPackaging = true
            // Esto le dice a Android que no intente romper o limpiar las librerías nativas de Flutter
            keepDebugSymbols += setOf("**/libflutter.so", "**/libapp.so")
        }
    }
}

flutter {
    source = "../.."
}