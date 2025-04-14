# Keep all Google API Client related classes
-keep class com.google.api.client.** { *; }
-keep interface com.google.api.client.** { *; }
-dontwarn com.google.api.client.**

# Keep crypto tink classes that are referenced
-keep class com.google.crypto.tink.** { *; }
-keep interface com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Keep Error Prone annotations
-keep class com.google.errorprone.annotations.** { *; }
-dontwarn com.google.errorprone.annotations.**

# Keep JSR annotations
-keep class javax.annotation.** { *; }
-dontwarn javax.annotation.**

# Keep Joda Time
-keep class org.joda.time.** { *; }
-dontwarn org.joda.time.**

# Keep Apache HTTP classes
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**

# Fix for R8/ProGuard errors related to HttpClient
-keepclassmembers class org.apache.** {
    *;
}

# Ensure there's no class hierarchy confusion
-dontoptimize
-dontobfuscate