import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Wrapper fino sobre o OneSignal. Segmentação sempre por `external_id`
/// (nunca por tags — ver `referencia/erros-herdados-do-sigau.md`), então o
/// `external_id` usado aqui é sempre o `id` do usuário no Supabase Auth,
/// o mesmo valor que a Edge Function `notify-push` recebe em `usuario_id`.
class PushNotificationsService {
  const PushNotificationsService._();

  static bool _initialized = false;

  static Future<void> init(String appId) async {
    // Push web do OneSignal exige service workers próprios em web/
    // (OneSignalSDKWorker.js) que não fazem parte deste MVP — o app web
    // segue funcionando normalmente, só sem push (o alvo real de demo é
    // Android físico). Notificação in-app via realtime continua ativa em
    // todas as plataformas.
    if (_initialized || appId.isEmpty || kIsWeb) return;
    _initialized = true;

    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.warn);
    }
    OneSignal.initialize(appId);
    await OneSignal.Notifications.requestPermission(true);
  }

  /// Chamado após login (`OneSignal.login` é `Future<void>` — sempre `await`
  /// antes de qualquer outra chamada do SDK, senão o external_id ainda não
  /// está associado no device).
  static Future<void> login(String usuarioId) async {
    if (!_initialized) return;
    await OneSignal.login(usuarioId);
  }

  static Future<void> logout() async {
    if (!_initialized) return;
    await OneSignal.logout();
  }
}
