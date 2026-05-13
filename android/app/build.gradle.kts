plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.matematicadivertida"
    
    // Atualizado conforme sugestão do terminal para suportar os plugins atuais
    compileSdk = 36 
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.matematicadivertida"
        minSdk = 21
        // Atualizado para coincidir com o compileSdk
        targetSdk = 36 
        versionCode = 1
        versionName = "1.0.0"
    }

    signingConfigs {
        getByName("debug") {
            storeFile = file("C:/.android/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}