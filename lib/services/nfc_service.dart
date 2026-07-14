import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/nfc_manager_android.dart';
import 'package:nfc_manager/nfc_manager_ios.dart';

class NfcService {
  // Mapeo de UIDs a tipos
  static const Map<String, String> stickerMap = {
    '04:XX:XX:XX':
        'hydration', // TODO: poner UID real del sticker (ej: '04:84:48:2A:E0:73:80')
    '04:YY:YY:YY': 'workout', // TODO: poner UID real del sticker
  };

  // Callback cuando detecta NFC
  void Function(String type)? onNfcDetected;

  // Iniciar escucha
  Future<void> startListening() async {
    try {
      // Comprobar disponibilidad de NFC
      final availability = await NfcManager.instance.checkAvailability();
      if (availability != NfcAvailability.enabled) {
        debugPrint('NFC no está disponible o está desactivado: $availability');
        return;
      }

      // 2. Iniciar sesión NFC
      NfcManager.instance.startSession(
        pollingOptions: {NfcPollingOption.iso14443, NfcPollingOption.iso15693},
        onDiscovered: (NfcTag tag) async {
          try {
            // Extraer el UID real del tag de forma segura
            final String? tagId = _extractUid(tag);

            if (tagId != null) {
              debugPrint('Tag detectado con UID: $tagId');

              // Busca el tipo en el mapa
              if (stickerMap.containsKey(tagId)) {
                onNfcDetected?.call(stickerMap[tagId]!);
              } else {
                debugPrint('Tag no reconocido en el mapa.');
              }
            }
          } catch (e) {
            debugPrint('Error al procesar tag: $e');
          }
        },
      );
    } catch (e) {
      debugPrint('Error al iniciar sesión NFC: $e');
    }
  }

  // Detener escucha
  Future<void> stopListening() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (e) {
      debugPrint('Error al detener la sesión: $e');
    }
  }

  // Para testing: simular detección de NFC
  void simulateNfcDetection(String type) {
    onNfcDetected?.call(type);
  }

  // Método privado para extraer el UID del tag de manera segura
  String? _extractUid(NfcTag tag) {
    try {
      // Para Android: usar NfcTagAndroid que tiene acceso al ID del tag
      if (Platform.isAndroid) {
        final androidTag = NfcTagAndroid.from(tag);
        if (androidTag != null) {
          final id = androidTag.id;
          return id
              .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
              .join(':');
        }
      }

      // Para iOS: intentar extraer el identificador de diferentes tecnologías
      if (Platform.isIOS) {
        // 1. Intentar MiFare (tarjetas MiFare Ultralight, Plus, DESFire)
        final mifare = MiFareIos.from(tag);
        if (mifare != null) {
          return mifare.identifier
              .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
              .join(':');
        }

        // 2. Intentar ISO7816 (tarjetas inteligentes ISO 7816)
        final iso7816 = Iso7816Ios.from(tag);
        if (iso7816 != null) {
          return iso7816.identifier
              .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
              .join(':');
        }

        // 3. Intentar ISO15693 (tarjetas ISO 15693)
        final iso15693 = Iso15693Ios.from(tag);
        if (iso15693 != null) {
          return iso15693.identifier
              .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
              .join(':');
        }

        // 4. Intentar FeliCa (tarjetas japonesas FeliCa)
        final felica = FeliCaIos.from(tag);
        if (felica != null) {
          // FeliCa usa currentIDm como identificador
          return felica.currentIDm
              .map((e) => e.toRadixString(16).padLeft(2, '0').toUpperCase())
              .join(':');
        }

        debugPrint('No se pudo extraer UID de ninguna tecnología compatible en iOS');
      }
    } catch (e) {
      debugPrint('Error extrayendo UID: $e');
    }
    return null;
  }
}
