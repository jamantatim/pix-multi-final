# ============================================
# PIX MULTI - Regras ProGuard para Ofuscação
# ============================================

# ✅ Flutter (Manter classes essenciais)
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }

# ✅ Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# ✅ AndroidX
-keep class androidx.** { *; }
-keep interface androidx.** { *; }
-dontwarn androidx.**
-keep class android.arch.** { *; }
-dontwarn android.arch.**

# ✅ Google Play Services
-keep class com.google.** { *; }
-dontwarn com.google.**

# ✅ SharedPreferences (Importante para Premium!)
-keep class android.content.SharedPreferences { *; }
-keepclassmembers class * implements android.content.SharedPreferences {
    *;
}

# ✅ QR Code Libraries
-keep class com.google.zxing.** { *; }
-keep class com.github.** { *; }
-dontwarn com.google.zxing.**
-dontwarn com.github.**

# ✅ Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class io.flutter.plugins.** { *; }

# ✅ URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# ✅ Shared Preferences Plugin
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# ✅ Manter seu pacote do app (ajuste se necessário)
-keep class com.example.pix_multi_final.** { *; }
-keep class com.example.pix_multi_final.MainActivity { *; }

# ✅ JSON e Serialização
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class java.lang.invoke.MethodHandle { *; }

# ✅ Manter métodos nativos
-keepclasseswithmembernames class * {
    native <methods>;
}

# ✅ Manter enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ✅ Manter Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# ✅ Manter Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ✅ Manter construtores padrão
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet, int);
}

# ✅ Manter views customizadas
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(***);
    *** get*();
}

# ✅ Manter activities
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# ✅ Manter R.id, R.string, etc.
-keepclassmembers class **.R$* {
    public static <fields>;
}

# ✅ Remover logs de debug (segurança)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# ✅ Otimizações
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification

# ✅ Não avisar sobre classes ausentes
-dontnote android.net.http.**
-dontnote android.support.**
-dontnote androidx.**
-dontnote com.android.**
-dontnote com.google.**
-dontnote org.apache.**
-dontnote org.json.**

# ✅ Ignorar warnings
-dontwarn android.support.**
-dontwarn androidx.**
-dontwarn com.google.**
-dontwarn org.json.**
-dontwarn javax.annotation.**
-dontwarn sun.misc.**

# ============================================
# FIM DAS REGRAS - PIX MULTI
# ============================================
