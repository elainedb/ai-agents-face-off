plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.google.services)
    alias(libs.plugins.firebase.perf)
    alias(libs.plugins.kotlinx.serialization)
    alias(libs.plugins.ksp)
    jacoco
}

android {
    namespace = "dev.elainedb.ytdash_android_gemini"
    compileSdk = 36

    defaultConfig {
        applicationId = "dev.elainedb.ytdash_android_gemini"
        minSdk = 29
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        debug {
            enableUnitTestCoverage = true
        }
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
    buildFeatures {
        compose = true
    }
}

// Task to generate dummy google-services.json for CI builds
tasks.register("generateDummyGoogleServices") {
    description = "Generates a dummy google-services.json file for CI builds"
    group = "build setup"

    doLast {
        val googleServicesFile = file("google-services.json")
        val templateFile = file("google-services.json.template")

        if (!googleServicesFile.exists() && templateFile.exists()) {
            templateFile.copyTo(googleServicesFile)
            println("Generated dummy google-services.json from template for CI build")
        }
    }
}

// Ensure dummy google-services.json is generated before build starts
tasks.named("preBuild") {
    dependsOn("generateDummyGoogleServices")
}

tasks.withType<Test> {
    extensions.configure<JacocoTaskExtension> {
        isIncludeNoLocationClasses = true
        excludes = listOf("jdk.internal.*")
    }
}

tasks.register<JacocoReport>("JacocoDebugCodeCoverage") {
    dependsOn("testDebugUnitTest")
    group = "Reporting"
    description = "Generate JaCoCo coverage reports for debug unit tests"

    reports {
        xml.required.set(true)
        html.required.set(true)
    }

    val debugTree = fileTree("${layout.buildDirectory.get()}/tmp/kotlin-classes/debug") {
        exclude(
            "**/R.class",
            "**/R\$*.class",
            "**/BuildConfig.*",
            "**/Manifest*.*",
            "**/*Test*.*",
            "**/ComposableSingletons*",
            "**/*_Factory*",
            "**/*_MembersInjector*",
            "**/ui/theme/**"
        )
    }

    classDirectories.setFrom(debugTree)
    sourceDirectories.setFrom("${project.projectDir}/src/main/java")
    executionData.setFrom(
        fileTree(layout.buildDirectory) {
            include("jacoco/testDebugUnitTest.exec")
        }
    )
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.graphics)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    
    // Play Services Auth
    implementation(libs.play.services.auth)

    // Retrofit & OkHttp
    implementation(libs.retrofit)
    implementation(libs.retrofit.kotlinx.serialization)
    implementation(libs.okhttp)
    implementation(libs.okhttp.logging)

    // Kotlinx Serialization
    implementation(libs.kotlinx.serialization.json)

    // Room
    implementation(libs.room.runtime)
    implementation(libs.room.ktx)
    "ksp"(libs.room.compiler)

    // Coil
    implementation(libs.coil.compose)

    // OSMDroid
    implementation(libs.osmdroid.android)

    // Firebase
    implementation(platform(libs.firebase.bom))
    implementation(libs.firebase.perf.ktx)

    // Coroutines
    implementation(libs.kotlinx.coroutines.android)

    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
    androidTestImplementation(platform(libs.androidx.compose.bom))
    androidTestImplementation(libs.androidx.compose.ui.test.junit4)
    debugImplementation(libs.androidx.compose.ui.tooling)
    debugImplementation(libs.androidx.compose.ui.test.manifest)
}