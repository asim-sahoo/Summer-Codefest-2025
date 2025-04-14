# Add these rules to prevent R8 from stripping necessary classes
-keep class com.google.errorprone.annotations.CanIgnoreReturnValue { *; }
-keep class com.google.errorprone.annotations.CheckReturnValue { *; }
-keep class com.google.errorprone.annotations.Immutable { *; }
-keep class com.google.errorprone.annotations.RestrictedApi { *; }
-keep class javax.annotation.Nullable { *; }
-keep class javax.annotation.concurrent.GuardedBy { *; }

# Keep all classes in the com.google.crypto.tink package and subpackages
-keep class com.google.crypto.tink.** { *; }

# Keep all classes in the javax.annotation package and subpackages
-keep class javax.annotation.** { *; }

# Keep all classes in the com.google.errorprone.annotations package and subpackages
-keep class com.google.errorprone.annotations.** { *; }