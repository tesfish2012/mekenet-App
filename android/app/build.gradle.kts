plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mekenetinsurance.mekenetinsurance_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Required by flutter_local_notifications and other Java 8+ libraries
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.mekenetinsurance.mekenetinsurance_mobile"
        // flutter_local_notifications, local_auth, and several other plugins
        // require minSdk >= 21 (Android 5.0 Lollipop)
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Multidex is auto-enabled when minSdk >= 21, no explicit opt-in needed
    }

    buildTypes {
        release {
            // TODO: Replace with your own signing config before publishing.
            // Using debug keys for now so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // Enable R8 code shrinking & resource shrinking for release builds
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            isDebuggable = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring — required by flutter_local_notifications
    // Uses newer Java 8+ APIs (java.time etc.) on older Android versions
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
