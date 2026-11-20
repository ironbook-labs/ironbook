import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jlleitschuh.gradle.ktlint")
}

// Load secrets from .env file in the root project directory
val envProperties = Properties()
val envFile = rootProject.file(".env")

if (envFile.exists()) {
    envFile.forEachLine { line ->
        if (line.isNotBlank() && !line.startsWith("#") && line.contains("=")) {
            val (key, value) = line.split("=", limit = 2)
            val cleanValue = value.trim().removeSurrounding("\"").removeSurrounding("'")
            envProperties.setProperty(key.trim(), cleanValue)
        }
    }
}

android {
    namespace = "com.abledtaha.ironbook"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.abledtaha.ironbook"
        minSdk = 26
        targetSdk = 34
        versionCode = 10310
        versionName = "0.1.3-alpha"
    }

    signingConfigs {
        create("release") {
            val storePath =
                System.getenv("KEYSTORE_PATH")
                    ?: envProperties.getProperty("KEYSTORE_PATH")

            if (!storePath.isNullOrEmpty()) {
                storeFile = rootProject.file(storePath)
            }
            storePassword = System.getenv("KEYSTORE_PASSWORD")
                ?: envProperties.getProperty("KEYSTORE_PASSWORD")
                ?: ""
            keyAlias = System.getenv("KEY_ALIAS")
                ?: envProperties.getProperty("KEY_ALIAS")
                ?: ""
            keyPassword = System.getenv("KEY_PASSWORD")
                ?: envProperties.getProperty("KEY_PASSWORD")
                ?: ""
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = "21"
    }
}

dependencies {
    // Core AndroidX libraries needed for basic modern app components
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")

    // UI Layout essentials
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
}
