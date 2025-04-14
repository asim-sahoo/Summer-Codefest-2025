# Add these rules to prevent R8 from stripping necessary classes
-keep class com.google.errorprone.annotations.CanIgnoreReturnValue { *; }
-keep class com.google.errorprone.annotations.CheckReturnValue { *; }
-keep class com.google.errorprone.annotations.Immutable { *; }
-keep class com.google.errorprone.annotations.RestrictedApi { *; }
-keep class com.google.errorprone.annotations.InlineMe { *; }
-keep class javax.annotation.Nullable { *; }
-keep class javax.annotation.concurrent.GuardedBy { *; }
-keep class javax.annotation.concurrent.ThreadSafe { *; }

# Keep HTTP client classes
-keep class com.google.api.client.http.** { *; }
-keep class com.google.api.client.http.GenericUrl { *; }
-keep class com.google.api.client.http.HttpHeaders { *; }
-keep class com.google.api.client.http.HttpRequest { *; }
-keep class com.google.api.client.http.HttpRequestFactory { *; }
-keep class com.google.api.client.http.HttpResponse { *; }
-keep class com.google.api.client.http.HttpTransport { *; }
-keep class com.google.api.client.http.javanet.NetHttpTransport { *; }
-keep class com.google.api.client.http.javanet.NetHttpTransport$Builder { *; }

# Keep time libraries
-keep class org.joda.time.** { *; }
-keep class org.joda.time.Instant { *; }

# Keep all classes in the com.google.crypto.tink package and subpackages
-keep class com.google.crypto.tink.** { *; }

# Keep all classes in the javax.annotation package and subpackages
-keep class javax.annotation.** { *; }

# Keep all classes in the com.google.errorprone.annotations package and subpackages
-keep class com.google.errorprone.annotations.** { *; }

# Additional keep rules
-dontwarn com.google.api.client.http.**
-dontwarn org.joda.time.**
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn com.google.crypto.tink.**

# Keep any classes referenced by the KeysDownloader class
-keep class * implements com.google.crypto.tink.KeyManager { *; }
-keep class * implements com.google.crypto.tink.PrimitiveSet { *; }

# Apache HTTP client rules to fix R8 conflicts
-dontnote org.apache.http.**
-dontnote android.net.http.**
-dontwarn org.apache.http.**
-dontwarn android.net.http.**
-keep class org.apache.http.** { *; }
-keep interface org.apache.http.** { *; }

# Fix for R8 errors with HttpEntityEnclosingRequestBase and related classes
-keep class org.apache.http.client.methods.** { *; }
-keep interface org.apache.http.client.methods.** { *; }
-keep class org.apache.http.message.** { *; }
-keep interface org.apache.http.message.** { *; }
-keep class org.apache.http.client.** { *; }
-keep interface org.apache.http.client.** { *; }

# Explicitly keep HttpClient implementation classes
-keep class org.apache.http.impl.client.** { *; }
-keep class org.apache.http.conn.** { *; }
-keep class org.apache.http.impl.conn.** { *; }