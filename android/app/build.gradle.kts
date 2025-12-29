// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // مهم للـ Firebase
}

android {
    namespace = "com.example.my_app" // غيّري حسب اسم التطبيق
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.my_app" // غيّري حسب اسم التطبيق
        minSdk = flutter.minSdkVersion // أقل نسخة مدعومة من Flutter & Firebase
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            // استخدمي debug مؤقتاً للتجربة، لاحقاً استخدمي signing حقيقي
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false    // تعطيل تصغير الكود مؤقتاً
            isShrinkResources = false  // تعطيل إزالة الموارد لتجنب خطأ build
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

// Dependencies Firebase وأمثلة على الخدمات
dependencies {
    implementation("com.google.firebase:firebase-analytics-ktx:21.3.0") // Firebase Analytics
    implementation("com.google.firebase:firebase-auth-ktx:22.1.0")      // Firebase Auth
    implementation("com.google.firebase:firebase-firestore-ktx:24.5.0") // Firestore
}
