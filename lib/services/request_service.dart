import 'dart:math';

class RequestService {
  static final Random _random = Random();
  
  static String generateRequestCode(String planType) {
    String prefix;
    switch (planType) {
      case 'weekly': prefix = 'REQ-W'; break;
      case 'monthly': prefix = 'REQ-M'; break;
      case 'yearly': prefix = 'REQ-Y'; break;
      default: prefix = 'REQ-W';
    }
    final randomPart = _generateRandomString(6);
    return '$prefix-$randomPart';
  }
  
  static String generateActivationCode(String planType) {
    String prefix;
    switch (planType) {
      case 'weekly': prefix = 'ACT-W'; break;
      case 'monthly': prefix = 'ACT-M'; break;
      case 'yearly': prefix = 'ACT-Y'; break;
      default: prefix = 'ACT-W';
    }
    final randomPart = _generateRandomString(6);
    return '$prefix-$randomPart';
  }
  
  static String? identifyPlanFromCode(String code) {
    final codeUpper = code.trim().toUpperCase();
    if (codeUpper.startsWith('REQ-W') || codeUpper.startsWith('ACT-W')) return 'weekly';
    if (codeUpper.startsWith('REQ-M') || codeUpper.startsWith('ACT-M')) return 'monthly';
    if (codeUpper.startsWith('REQ-Y') || codeUpper.startsWith('ACT-Y')) return 'yearly';
    return null;
  }
  
  static bool isValidActivationCode(String code) {
    final codeUpper = code.trim().toUpperCase();
    return codeUpper.startsWith('ACT-W-') || 
           codeUpper.startsWith('ACT-M-') || 
           codeUpper.startsWith('ACT-Y-');
  }
  
  static String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(_random.nextInt(chars.length))),
    );
  }
  
  static Map<String, dynamic> getPlanInfo(String planType) {
    switch (planType) {
      case 'weekly':
        return {'name': 'Semanal', 'days': 7, 'price': 'R\$ 1,99'};
      case 'monthly':
        return {'name': 'Mensal', 'days': 30, 'price': 'R\$ 4,90'};
      case 'yearly':
        return {'name': 'Anual', 'days': 365, 'price': 'R\$ 39,90'};
      default:
        return {'name': 'Desconhecido', 'days': 0, 'price': 'R\$ 0,00'};
    }
  }
}
