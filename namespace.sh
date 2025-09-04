# Fix file_picker JVM target issue in all relevant build.gradle files
for FILE_PICKER_GRADLE in $(find $HOME/.pub-cache -type f -path "*/file_picker-*/android/build.gradle"); do
    if [ -f "$FILE_PICKER_GRADLE" ]; then
        echo "Fixing file_picker JVM target and kotlin options in $FILE_PICKER_GRADLE..."
        cp "$FILE_PICKER_GRADLE" "$FILE_PICKER_GRADLE.backup"
        # Replace any existing jvmTarget line, or add it if missing
        if grep -q 'kotlinOptions' "$FILE_PICKER_GRADLE"; then
            # Replace existing jvmTarget line
            sed -i '' "s/jvmTarget[ ]*=[ ]*['\"]1.8['\"]/jvmTarget = '17'/g" "$FILE_PICKER_GRADLE"
            sed -i '' "s/jvmTarget[ ]*=[ ]*JavaVersion.VERSION_1_8/jvmTarget = '17'/g" "$FILE_PICKER_GRADLE"
        else
            # Add kotlinOptions block if missing (after compileOptions or at end of android block)
            awk '/android[ \t]*{/ {print; in_android=1; next} in_android && /}/ {print "    kotlinOptions {\n        jvmTarget = \"17\"\n    }"; in_android=0} {print}' "$FILE_PICKER_GRADLE.backup" > "$FILE_PICKER_GRADLE"
        fi
        echo "file_picker JVM target fixed in $FILE_PICKER_GRADLE"
    else
        echo "file_picker build.gradle not found at $FILE_PICKER_GRADLE"
    fi
done
# Fix at_onboarding_flutter import issue for git dependency
for plugin_path in $HOME/.pub-cache/git/at_widgets-*/packages/at_onboarding_flutter/android/src/main/kotlin/com/atsign/at_onboarding_flutter/AtOnboardingFlutterPlugin.kt; do
    if [ -f "$plugin_path" ]; then
        echo "Fixing at_onboarding_flutter (git) import issue..."
        cp "$plugin_path" "$plugin_path.backup"
        sed '/import io.flutter.plugin.common.PluginRegistry.Registrar/d' "$plugin_path.backup" > "$plugin_path"
        echo "at_onboarding_flutter (git) import fixed"
    fi
done
# Fix at_onboarding_flutter import issue
AT_ONBOARDING_PLUGIN="$HOME/.pub-cache/hosted/pub.dev/at_onboarding_flutter-6.1.9/android/src/main/kotlin/com/atsign/at_onboarding_flutter/AtOnboardingFlutterPlugin.kt"
if [ -f "$AT_ONBOARDING_PLUGIN" ]; then
    echo "Fixing at_onboarding_flutter import issue..."
    cp "$AT_ONBOARDING_PLUGIN" "$AT_ONBOARDING_PLUGIN.backup"
    # Remove the problematic Registrar import
    sed '/import io.flutter.plugin.common.PluginRegistry.Registrar/d' "$AT_ONBOARDING_PLUGIN.backup" > "$AT_ONBOARDING_PLUGIN"
    echo "at_onboarding_flutter import fixed"
else
    echo "at_onboarding_flutter plugin file not found"
fi
# Fix at_contacts_group_flutter import issue
AT_CONTACTS_GROUP_PLUGIN="$HOME/.pub-cache/hosted/pub.dev/at_contacts_group_flutter-4.1.0/android/src/main/kotlin/com/atsign/at_contacts_group_flutter/AtContactsGroupFlutterPlugin.kt"
if [ -f "$AT_CONTACTS_GROUP_PLUGIN" ]; then
    echo "Fixing at_contacts_group_flutter import issue..."
    cp "$AT_CONTACTS_GROUP_PLUGIN" "$AT_CONTACTS_GROUP_PLUGIN.backup"
    # Remove the problematic Registrar import
    sed '/import io.flutter.plugin.common.PluginRegistry.Registrar/d' "$AT_CONTACTS_GROUP_PLUGIN.backup" > "$AT_CONTACTS_GROUP_PLUGIN"
    echo "at_contacts_group_flutter import fixed"
else
    echo "at_contacts_group_flutter plugin file not found"
fi
#!/bin/bash

# Fix Android Gradle Plugin version in settings.gradle.kts
SETTINGS_GRADLE="android/settings.gradle.kts"
if [ -f "$SETTINGS_GRADLE" ]; then
    echo "Upgrading Android Gradle Plugin to 8.3.0..."
    cp "$SETTINGS_GRADLE" "$SETTINGS_GRADLE.backup"
    sed 's/id("com.android.application") version "8.2.1"/id("com.android.application") version "8.3.0"/' "$SETTINGS_GRADLE" > "$SETTINGS_GRADLE.tmp" && mv "$SETTINGS_GRADLE.tmp" "$SETTINGS_GRADLE"
    echo "Android Gradle Plugin upgraded"
else
    echo "settings.gradle.kts not found"
fi

# Fix namespace for qr_code_scanner
QR_GRADLE="$HOME/.pub-cache/hosted/pub.dev/qr_code_scanner-1.0.1/android/build.gradle"
if [ -f "$QR_GRADLE" ]; then
    echo "Fixing qr_code_scanner namespace..."
    cp "$QR_GRADLE" "$QR_GRADLE.backup"
    
    # Create new build.gradle with namespace
    cat > "$QR_GRADLE" << 'EOF'
group 'net.touchcapture.qr.flutterqr'
version '1.0-SNAPSHOT'

buildscript {
    ext.kotlin_version = '1.7.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.2.2'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    namespace 'net.touchcapture.qr.flutterqr'
    compileSdkVersion 32

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
    defaultConfig {
        // minSdkVersion is determined by Native View.
        minSdkVersion 20
        targetSdkVersion 32
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
        multiDexEnabled true
    }

    compileOptions {
        // Flag to enable support for the new language APIs
        coreLibraryDesugaringEnabled true
        // Sets Java compatibility to Java 8
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation('com.journeyapps:zxing-android-embedded:4.3.0') { transitive = false }
    implementation 'androidx.appcompat:appcompat:1.4.2'
    implementation 'com.google.zxing:core:3.5.0'
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:1.2.0'
}
EOF
    
    echo "qr_code_scanner namespace fixed"
else
    echo "qr_code_scanner build.gradle not found"
fi

# Check what we have now
echo "Checking namespaces:"
if [ -f "$QR_GRADLE" ]; then
    grep -A 2 "android {" "$QR_GRADLE" | head -n 3
fi

# Fix at_file_saver JVM target issue
AT_FILE_SAVER_GRADLE="$HOME/.pub-cache/hosted/pub.dev/at_file_saver-0.1.2/android/build.gradle"
if [ -f "$AT_FILE_SAVER_GRADLE" ]; then
    echo "Fixing at_file_saver JVM target and kotlin options..."
    cp "$AT_FILE_SAVER_GRADLE" "$AT_FILE_SAVER_GRADLE.backup2"
    
    # Create new build.gradle with proper kotlin options
    cat > "$AT_FILE_SAVER_GRADLE" << 'EOF'
group 'com.one.at_file_saver'
version '1.0-SNAPSHOT'

buildscript {
    ext.kotlin_version = '1.6.10'
    ext.coroutinesVersion = '1.3.3'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    namespace 'com.one.at_file_saver'
    compileSdkVersion 30

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
    defaultConfig {
        minSdkVersion 19
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    implementation "org.jetbrains.kotlinx:kotlinx-coroutines-core:$coroutinesVersion"
    implementation "org.jetbrains.kotlinx:kotlinx-coroutines-android:$coroutinesVersion"
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'androidx.annotation:annotation:1.1.0'
}
EOF
    
    echo "at_file_saver JVM target fixed"
else
    echo "at_file_saver build.gradle not found"
fi

echo "All namespace and JVM target fixes applied!"

# Fix at_backupkey_flutter kotlinOptions
AT_BACKUP_GRADLE="$HOME/.pub-cache/hosted/pub.dev/at_backupkey_flutter-4.0.17/android/build.gradle"
if [ -f "$AT_BACKUP_GRADLE" ]; then
    echo "Fixing at_backupkey_flutter kotlinOptions..."
    cp "$AT_BACKUP_GRADLE" "$AT_BACKUP_GRADLE.backup3"
    
    # Create new build.gradle with proper kotlin options
    cat > "$AT_BACKUP_GRADLE" << 'EOF'
group 'com.atsign.at_backupkey_flutter'
version '1.0-SNAPSHOT'

buildscript {
    ext.kotlin_version = '1.7.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    namespace 'com.atsign.at_backupkey_flutter'
    compileSdkVersion 33

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
    defaultConfig {
        minSdkVersion 23
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = "1.8"
    }
    
    lintOptions {
        disable 'InvalidPackage'
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
EOF
    
    echo "at_backupkey_flutter kotlinOptions fixed"
else
    echo "at_backupkey_flutter build.gradle not found"
fi

# Fix biometric_storage kotlinOptions
BIOMETRIC_GRADLE="$HOME/.pub-cache/hosted/pub.dev/biometric_storage-5.0.1/android/build.gradle"
if [ -f "$BIOMETRIC_GRADLE" ]; then
    echo "Fixing biometric_storage kotlinOptions..."
    cp "$BIOMETRIC_GRADLE" "$BIOMETRIC_GRADLE.backup6"
    
    # Create new build.gradle with kotlinOptions and without kapt
    cat > "$BIOMETRIC_GRADLE" << 'EOF'
group 'design.codeux.biometric_storage'
version '1.0-SNAPSHOT'

buildscript {
    ext.kotlin_version = '1.8.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    namespace "design.codeux.biometric_storage"
    compileSdk 31

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
    defaultConfig {
        minSdkVersion 23
        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
        consumerProguardFiles 'proguard.pro'
    }
    lintOptions {
        disable 'InvalidPackage'
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = "1.8"
    }
}

dependencies {
    def biometric_version = "1.2.0-alpha05"

    api "androidx.core:core-ktx:1.10.1"
    api "androidx.fragment:fragment-ktx:1.6.1"

    implementation "org.slf4j:slf4j-api:2.0.7"
    implementation "androidx.biometric:biometric:$biometric_version"
    implementation "io.github.oshai:kotlin-logging-jvm:5.0.1"
}
EOF
    
    echo "biometric_storage kotlinOptions fixed"
else
    echo "biometric_storage build.gradle not found"
fi


# Fix at_backupkey_flutter import issue
AT_BACKUP_PLUGIN="$HOME/.pub-cache/hosted/pub.dev/at_backupkey_flutter-4.1.0/android/src/main/kotlin/com/atsign/at_backupkey_flutter/AtBackupkeyFlutterPlugin.kt"
if [ -f "$AT_BACKUP_PLUGIN" ]; then
    echo "Fixing at_backupkey_flutter import issue..."
    cp "$AT_BACKUP_PLUGIN" "$AT_BACKUP_PLUGIN.backup"
    # Remove the problematic Registrar import
    sed '/import io.flutter.plugin.common.PluginRegistry.Registrar/d' "$AT_BACKUP_PLUGIN.backup" > "$AT_BACKUP_PLUGIN"
    echo "at_backupkey_flutter import fixed"
else
    echo "at_backupkey_flutter plugin file not found"
fi

# Fix at_contacts_flutter import issue
AT_CONTACTS_PLUGIN="$HOME/.pub-cache/hosted/pub.dev/at_contacts_flutter-4.1.0/android/src/main/kotlin/com/atsign/at_contacts_flutter/AtContactsFlutterPlugin.kt"
if [ -f "$AT_CONTACTS_PLUGIN" ]; then
    echo "Fixing at_contacts_flutter import issue..."
    cp "$AT_CONTACTS_PLUGIN" "$AT_CONTACTS_PLUGIN.backup"
    # Remove the problematic Registrar import
    sed '/import io.flutter.plugin.common.PluginRegistry.Registrar/d' "$AT_CONTACTS_PLUGIN.backup" > "$AT_CONTACTS_PLUGIN"
    echo "at_contacts_flutter import fixed"
else
    echo "at_contacts_flutter plugin file not found"
fi

# Fix at_onboarding_flutter kotlinOptions
AT_ONBOARDING_GRADLE="$HOME/.pub-cache/hosted/pub.dev/at_onboarding_flutter-6.1.11/android/build.gradle"
if [ -f "$AT_ONBOARDING_GRADLE" ]; then
    echo "Fixing at_onboarding_flutter kotlinOptions..."
    cp "$AT_ONBOARDING_GRADLE" "$AT_ONBOARDING_GRADLE.backup2"
    
    # Create new build.gradle with proper kotlin options
    cat > "$AT_ONBOARDING_GRADLE" << 'EOF'
group 'com.atsign.at_onboarding_flutter'
version '1.0-SNAPSHOT'

buildscript {
    ext.kotlin_version = '1.8.20'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

rootProject.allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    namespace 'com.atsign.at_onboarding_flutter'
    compileSdkVersion 32

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
    defaultConfig {
        minSdkVersion 23
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = "1.8"
    }
    
    lintOptions {
        disable 'InvalidPackage'
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
EOF
    
    echo "at_onboarding_flutter kotlinOptions fixed"
else
    echo "at_onboarding_flutter build.gradle not found"
fi
    
# Fix at_onboarding_flutter import issue
AT_ONBOARDING_PLUGIN="$HOME/.pub-cache/hosted/pub.dev/at_onboarding_flutter-6.1.11/android/src/main/kotlin/com/atsign/at_onboarding_flutter/AtOnboardingFlutterPlugin.kt"
if [ -f "$AT_ONBOARDING_PLUGIN" ]; then
    echo "Fixing at_onboarding_flutter import issue..."
    cp "$AT_ONBOARDING_PLUGIN" "$AT_ONBOARDING_PLUGIN.backup"
    
    # Remove the problematic Registrar import
    sed '/import io.flutter.plugin.common.PluginRegistry.Registrar/d' "$AT_ONBOARDING_PLUGIN.backup" > "$AT_ONBOARDING_PLUGIN"
    
    echo "at_onboarding_flutter import fixed"
else
    echo "at_onboarding_flutter plugin file not found"
fi

# Fix flutter_keychain import issue
FLUTTER_KEYCHAIN_PLUGIN="$HOME/.pub-cache/hosted/pub.dev/flutter_keychain-2.5.0/android/src/main/kotlin/be/appmire/flutterkeychain/FlutterKeychainPlugin.kt"
FLUTTER_KEYCHAIN_BUILD="$HOME/.pub-cache/hosted/pub.dev/flutter_keychain-2.5.0/android/build.gradle"
if [ -f "$FLUTTER_KEYCHAIN_PLUGIN" ]; then
    echo "Fixing flutter_keychain import issue..."
    cp "$FLUTTER_KEYCHAIN_PLUGIN" "$FLUTTER_KEYCHAIN_PLUGIN.backup"
    
    # Create a new version removing the problematic import and companion object registerWith method
    cat > "$FLUTTER_KEYCHAIN_PLUGIN" << 'EOF'
package be.appmire.flutterkeychain

import android.content.Context
import android.content.SharedPreferences
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterKeychainPlugin */
class FlutterKeychainPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_keychain")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "put" -> {
        val key = call.argument<String>("key") ?: return result.error("INVALID_PARAMETER", "Missing key", null)
        val value = call.argument<String>("value") ?: return result.error("INVALID_PARAMETER", "Missing value", null)
        put(key, value, result)
      }
      "get" -> {
        val key = call.argument<String>("key") ?: return result.error("INVALID_PARAMETER", "Missing key", null)
        get(key, result)
      }
      "remove" -> {
        val key = call.argument<String>("key") ?: return result.error("INVALID_PARAMETER", "Missing key", null)
        remove(key, result)
      }
      "clear" -> {
        clear(result)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun getSharedPreferences(): SharedPreferences {
    return context.getSharedPreferences("flutter_keychain_prefs", Context.MODE_PRIVATE)
  }

  private fun put(key: String, value: String, result: Result) {
    try {
      val sharedPreferences = getSharedPreferences()
      sharedPreferences.edit().putString(key, value).apply()
      result.success(null)
    } catch (e: Exception) {
      result.error("KEYCHAIN_ERROR", "Failed to put value", e.localizedMessage)
    }
  }

  private fun get(key: String, result: Result) {
    try {
      val sharedPreferences = getSharedPreferences()
      val value = sharedPreferences.getString(key, null)
      result.success(value)
    } catch (e: Exception) {
      result.error("KEYCHAIN_ERROR", "Failed to get value", e.localizedMessage)
    }
  }

  private fun remove(key: String, result: Result) {
    try {
      val sharedPreferences = getSharedPreferences()
      sharedPreferences.edit().remove(key).apply()
      result.success(null)
    } catch (e: Exception) {
      result.error("KEYCHAIN_ERROR", "Failed to remove value", e.localizedMessage)
    }
  }

  private fun clear(result: Result) {
    try {
      val sharedPreferences = getSharedPreferences()
      sharedPreferences.edit().clear().apply()
      result.success(null)
    } catch (e: Exception) {
      result.error("KEYCHAIN_ERROR", "Failed to clear keychain", e.localizedMessage)
    }
  }
}
EOF
    
    echo "flutter_keychain import fixed"
else
    echo "flutter_keychain plugin file not found"
fi

echo "All fixes completed!"
echo ""
echo "If you see errors about jlink or JAVA_HOME, make sure you have a full JDK (not just a JRE) and set JAVA_HOME to the JDK path."
echo "For example: export JAVA_HOME=\$(/usr/libexec/java_home -v 17)"