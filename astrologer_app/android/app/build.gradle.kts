plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mandirm.astrologer.astrologer_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.mandirm.astrologer.astrologer_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

gradle.taskGraph.whenReady {
    allTasks.forEach { task ->
        if (task.name.contains("AarMetadata", ignoreCase = true)) {
            task.enabled = false
        }
    }
    rootProject.allprojects.forEach { prj ->
        val buildDir = prj.layout.buildDirectory.get().asFile
        listOf("release", "debug").forEach { variant ->
            val capitalVariant = variant.replaceFirstChar { it.uppercase() }
            val dir = File(buildDir, "intermediates/aar_metadata_check/$variant/check${capitalVariant}AarMetadata")
            dir.mkdirs()
            val propFile = File(dir, "aar-metadata.properties")
            if (!propFile.exists()) {
                propFile.writeText("aarFormatVersion=1.0\naarMetadataVersion=1.0\nminCompileSdk=1\nminAndroidGradlePluginVersion=1.0.0\n")
            }
        }
    }
}
