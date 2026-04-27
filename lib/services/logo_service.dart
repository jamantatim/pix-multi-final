import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';  // ← IMPORT OBRIGATÓRIO!

class LogoService {
  // ✅ Processar imagem (redimensionar)
  static Future<Uint8List?> processLogoImage(Uint8List imageBytes, {int targetSize = 200}) async {
    try {
      final codec = await ui.instantiateImageCodec(imageBytes, targetWidth: targetSize, targetHeight: targetSize);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('❌ Erro ao processar logo: $e');
      return null;
    }
  }
  
  // ✅ Salvar logo personalizado (base64)
  static Future<void> saveCustomLogo(Uint8List imageBytes) async {
    final base64 = _bytesToBase64(imageBytes);
    final prefs = await SharedPreferences.getInstance();  // ← CORRETO!
    await prefs.setString('custom_logo_base64', base64);
  }
  
  // ✅ Carregar logo personalizado
  static Future<Uint8List?> loadCustomLogo() async {
    final prefs = await SharedPreferences.getInstance();  // ← CORRETO!
    final base64 = prefs.getString('custom_logo_base64');
    if (base64 != null && base64.isNotEmpty) {
      return _base64ToBytes(base64);
    }
    return null;
  }
  
  // ✅ Remover logo personalizado
  static Future<void> removeCustomLogo() async {
    final prefs = await SharedPreferences.getInstance();  // ← CORRETO!
    await prefs.remove('custom_logo_base64');
  }
  
  // ✅ Verificar se tem logo personalizado
  static Future<bool> hasCustomLogo() async {
    final prefs = await SharedPreferences.getInstance();  // ← CORRETO!
    final base64 = prefs.getString('custom_logo_base64');
    return base64 != null && base64.isNotEmpty;
  }
  
  // ✅ Converter bytes para base64
  static String _bytesToBase64(Uint8List bytes) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    var result = '';
    for (var i = 0; i < bytes.length; i += 3) {
      var b1 = bytes[i];
      var b2 = i + 1 < bytes.length ? bytes[i + 1] : 0;
      var b3 = i + 2 < bytes.length ? bytes[i + 2] : 0;
      
      result += chars[b1 >> 2];
      result += chars[((b1 & 0x03) << 4) | (b2 >> 4)];
      result += i + 1 < bytes.length ? chars[((b2 & 0x0F) << 2) | (b3 >> 6)] : '=';
      result += i + 2 < bytes.length ? chars[b3 & 0x3F] : '=';
    }
    return result;
  }
  
  // ✅ Converter base64 para bytes
  static Uint8List _base64ToBytes(String base64) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    final clean = base64.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
    var bytes = <int>[];
    
    for (var i = 0; i < clean.length; i += 4) {
      var b1 = chars.indexOf(clean[i]);
      var b2 = chars.indexOf(clean[i + 1]);
      var b3 = clean[i + 2] == '=' ? 0 : chars.indexOf(clean[i + 2]);
      var b4 = clean[i + 3] == '=' ? 0 : chars.indexOf(clean[i + 3]);
      
      bytes.add((b1 << 2) | (b2 >> 4));
      if (clean[i + 2] != '=') bytes.add(((b2 & 0x0F) << 4) | (b3 >> 2));
      if (clean[i + 3] != '=') bytes.add(((b3 & 0x03) << 6) | b4);
    }
    return Uint8List.fromList(bytes);
  }
}
