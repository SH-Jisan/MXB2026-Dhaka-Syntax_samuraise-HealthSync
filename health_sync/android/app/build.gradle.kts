import org.gradle.api.tasks.Copy
import com.android.build.gradle.internal.api.BaseVariantOutputImpl
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.health_sync"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.health_sync"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.7.0"))
}

android.applicationVariants.all {
    val variantName = name

    outputs.all {
        val outputImpl = this as BaseVariantOutputImpl
        val outputFile = outputImpl.outputFile

        val copyTaskName = "copy${variantName.replaceFirstChar { it.uppercase() }}Apk"

        tasks.register<Copy>(copyTaskName) {
            from(outputFile)
            into("D:/app_dev/healthSync/apk")
            rename {
                "Health Sync.apk"
            }
        }

        assembleProvider.get().finalizedBy(copyTaskName)
    }
}