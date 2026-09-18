import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Remove metadados EXIF de imagens antes do upload — pode conter GPS
/// preciso do dispositivo, modelo e data/hora (risco de privacidade, LGPD).
/// Decodifica e reencodifica o JPEG a 90% de qualidade em isolate separado
/// pra não bloquear a UI.
class ExifRemover {
  ExifRemover._();

  static Future<Uint8List> strip(Uint8List bytes) async {
    return compute(_processInIsolate, bytes);
  }

  static Uint8List _processInIsolate(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;
    return Uint8List.fromList(img.encodeJpg(decoded, quality: 90));
  }
}
