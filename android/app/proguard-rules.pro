# OneSignal — sem isso o R8 remove as classes silenciosamente em build
# release e o push some sem erro nenhum (lição herdada do SIGAU, ver
# SISANSecondBrain/referencia/erros-herdados-do-sigau.md).
-keep class com.onesignal.** { *; }
-dontwarn com.onesignal.**
