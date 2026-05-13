# Project-wide Gradle settings.
# For more details on how to configure your build environment visit
# http://www.gradle.org/docs/current/userguide/build_environment.html

# Specifies the JVM arguments used for the Gradle Daemon.
# Setting a description here will override any settings in ~/.gradle/gradle.properties.
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=512m

# When configured, Gradle will run in incubating parallel mode.
# This option should only be used with decoupled projects. More details, visit
# http://www.gradle.org/docs/current/userguide/multi_project_builds.html#sec:decoupled_projects
# org.gradle.parallel=true

# AndroidX package structure to make it clearer which packages are bundled with the
# Android operating system, and which are packaged with your app"s APK.
# https://developer.android.com/topic/libraries/support-library/androidx-rn
android.useAndroidX=true
android.enableJetifier=true

# Enables Kotlin code style within the project.
kotlin.code.style=official

# CORREÇÃO PARA CAMINHOS COM CARACTERES ESPECIAIS (COMO "USUÁRIO")
# Esta linha permite que o build continue mesmo com o erro de non-ASCII characters.
android.overridePathCheck=true