import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';

class Storage {
  static final Storage _instance = Storage._internal();
  factory Storage() => _instance;
  Storage._internal();

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // ✅ LOGIN SEMANAL
  Future<DateTime?> getLastLogin() async {
    final p = await _prefs;
    final ts = p.getInt('last_login');
    return ts != null ? DateTime.fromMillisecondsSinceEpoch(ts) : null;
  }

  Future<void> setLastLogin() async {
    final p = await _prefs;
    await p.setInt('last_login', DateTime.now().millisecondsSinceEpoch);
  }

  bool needsLogin(DateTime? last) {
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= 7;
  }

  // ✅ PREMIUM
  Future<bool> get isPremium async {
    final p = await _prefs;
    return p.getBool('premium') ?? false;
  }

  Future<void> setPremium(bool value) async {
    final p = await _prefs;
    await p.setBool('premium', value);
  }

  Future<String?> get expiry async {
    final p = await _prefs;
    return p.getString('expiry');
  }

  Future<void> setExpiry(String value) async {
    final p = await _prefs;
    await p.setString('expiry', value);
  }

  // ✅ CÓDIGOS USADOS
  Future<List<String>> get usedCodes async {
    final p = await _prefs;
    return p.getStringList('used_codes') ?? [];
  }

  Future<void> markCodeUsed(String hash) async {
    final p = await _prefs;
    final used = await usedCodes;
    if (!used.contains(hash)) {
      used.add(hash);
      await p.setStringList('used_codes', used);
    }
  }

  // ✅ MULTI CONTAS
  Future<List<Account>> get accounts async {
    final p = await _prefs;
    final accountsJson = p.getStringList('accounts') ?? [];
    return accountsJson.map((json) => Account.fromJson(json)).toList();
  }

  Future<void> saveAccounts(List<Account> accounts) async {
    final p = await _prefs;
    final jsonList = accounts.map((a) => a.toJson()).toList();
    await p.setStringList('accounts', jsonList);
  }

  Future<Account?> get activeAccount async {
    final p = await _prefs;
    final json = p.getString('active_account');
    return json != null ? Account.fromJson(json) : null;
  }

  Future<void> setActiveAccount(Account account) async {
    final p = await _prefs;
    await p.setString('active_account', account.toJson());
  }

  // ✅ CONFIGURAÇÕES PREMIUM
  Future<int> get selectedTheme async {
    final p = await _prefs;
    return p.getInt('theme_index') ?? 0;
  }

  Future<void> setSelectedTheme(int index) async {
    final p = await _prefs;
    await p.setInt('theme_index', index);
  }

  Future<String?> get qrLogo async {
    final p = await _prefs;
    return p.getString('qr_logo');
  }

  Future<void> setQrLogo(String? logo) async {
    final p = await _prefs;
    if (logo != null) {
      await p.setString('qr_logo', logo);
    } else {
      await p.remove('qr_logo');
    }
  }

  Future<int> get qrTimeout async {
    final p = await _prefs;
    return p.getInt('qr_timeout') ?? 120;
  }

  Future<void> setQrTimeout(int seconds) async {
    final p = await _prefs;
    await p.setInt('qr_timeout', seconds);
  }

  // ✅ PLANO CONTRATADO
  Future<String?> get contractedPlan async {
    final p = await _prefs;
    return p.getString('contracted_plan');
  }

  Future<void> setContractedPlan(String planType) async {
    final p = await _prefs;
    await p.setString('contracted_plan', planType);
  }

  // ✅ CÓDIGOS DE SOLICITAÇÃO GERADOS (NOVO - CORRIGIDO!)
  Future<List<String>> get generatedRequests async {
    final p = await _prefs;
    return p.getStringList('generated_requests') ?? [];
  }

  Future<void> saveGeneratedRequest(String requestCode) async {
    final p = await _prefs;
    final requests = await generatedRequests;
    if (!requests.contains(requestCode)) {
      requests.add(requestCode);
      await p.setStringList('generated_requests', requests);
    }
  }

  // ✅ CÓDIGOS DE ATIVAÇÃO USADOS
  Future<List<String>> get usedActivations async {
    final p = await _prefs;
    return p.getStringList('used_activations') ?? [];
  }

  Future<void> markActivationUsed(String activationCode) async {
    final p = await _prefs;
    final used = await usedActivations;
    if (!used.contains(activationCode)) {
      used.add(activationCode);
      await p.setStringList('used_activations', used);
    }
  }
}
