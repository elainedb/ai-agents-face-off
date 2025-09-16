// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.kotlin.compose) apply false
    id("org.sonarqube") version "6.3.1.5724"
}

sonar {
    properties {
        property("sonar.projectKey", "elainedb_android_gemini")
        property("sonar.organization", "elainedb")
        property("sonar.coverage.jacoco.xmlReportPaths", "app/build/reports/jacoco/JacocoDebugCodeCoverage/JacocoDebugCodeCoverage.xml")
        property("sonar.junit.reportPaths", "app/build/test-results/testDebugUnitTest")
        property("sonar.android.lint.reportPaths", "app/build/reports/lint-results.xml")

        // Exclude test files from coverage analysis
        property("sonar.coverage.exclusions",
            "**/test/**," +
                    "**/androidTest/**," +
                    "**/*Test*," +
                    "**/*test*," +
                    "**/*.Test," +
                    "**/src/test/**/*," +
                    "**/src/androidTest/**/*"
        )

        // Also exclude test files from duplication analysis
        property("sonar.cpd.exclusions",
            "**/test/**," +
                    "**/androidTest/**," +
                    "**/*Test*"
        )

        // Exclude test sources from analysis entirely
        property("sonar.sources", "app/src/main")
        property("sonar.tests", "app/src/test,app/src/androidTest")

        // Exclude build artifacts to prevent duplicate indexing
        property("sonar.exclusions",
            "**/build/**," +
            "**/target/**"
        )
    }
}

tasks.register("jacocoTestReport") {
    dependsOn(":app:JacocoDebugCodeCoverage")
    group = "verification"
    description = "Generate Jacoco coverage reports for all modules"
}