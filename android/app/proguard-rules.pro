# Flutter Local Notifications ProGuard Rules
# Fixes: TypeToken must be created with a type argument: new TypeToken<...>() {};
# When using code shrinkers (ProGuard, R8, ...) make sure that generic signatures are preserved.

# Preserve generic signatures
-keepattributes Signature

# Preserve TypeToken generic type information
-keepclassmembers class * extends com.google.gson.reflect.TypeToken {
    <init>(...);
}

# Preserve flutter_local_notifications classes
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# If you use Gson directly in your project, you might also need:
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keepattributes *Annotation*
