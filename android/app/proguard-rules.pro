# TensorFlow Lite
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.support.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }

# AutoValue
-keep @com.google.auto.value.AutoValue class * {*;}
-keep class com.google.auto.value.AutoValue$Builder {*;}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep metadata
-keepattributes *Annotation*
-keepclassmembers class * {
    @org.tensorflow.lite.annotations.UseExperimental *;
}

# Keep GPU delegate
-keep class org.tensorflow.lite.gpu.GpuDelegate$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }