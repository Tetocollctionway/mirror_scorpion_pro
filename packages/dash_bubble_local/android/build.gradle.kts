group = "dev.moaz.dash_bubble"
version = "2.0.0"

buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

apply(plugin = "com.android.library")
apply(plugin = "kotlin-android")

android {
    compileSdk = 34
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
    
    defaultConfig {
        minSdk = 21
        targetSdk = 34
    }
    
    sourceSets {
        getByName("main") {
            kotlin.srcDir("src/main/kotlin")
        }
    }
}

dependencies {
    implementation("androidx.core:core:1.10.1")
    implementation("androidx.appcompat:appcompat:1.6.1")
}
