import 'package:flutter/material.dart';
import '../services/storage.dart';
import '../services/request_service.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});
  @override State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _activateCode() async {
    final code = _codeController.text.trim().toUpperCase();
    
    if (code.isEmpty) {
      setState(() => _error = 'Digite o código de ativação');
      return;
    }

    if (!RequestService.isValidActivationCode(code)) {
      setState(() => _error = '❌ Código inválido. Use: ACT-W-XXX, ACT-M-XXX ou ACT-Y-XXX');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final codeHash = code.hashCode.toString();
      final used = await Storage().usedCodes;
      
      if (used.contains(codeHash)) {
        setState(() {
          _loading = false;
          _error = '❌ Código já utilizado';
        });
        return;
      }

      final planType = RequestService.identifyPlanFromCode(code);
      if (planType == null) {
        setState(() {
          _loading = false;
          _error = '❌ Código inválido';
        });
        return;
      }

      int days = 0;
      String plan = '';
      
      if (planType == 'weekly') { days = 7; plan = 'Semanal'; }
      else if (planType == 'monthly') { days = 30; plan = 'Mensal'; }
      else if (planType == 'yearly') { days = 365; plan = 'Anual'; }

      await Storage().setPremium(true);
      await Storage().setExpiry(DateTime.now().add(Duration(days: days)).toIso8601String());
      await Storage().setContractedPlan(planType);
      await Storage().markCodeUsed(codeHash);

      setState(() {
        _loading = false;
        _success = '✅ $plan ativado! ($days dias)';
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });

    } catch (e) {
      setState(() {
        _loading = false;
        _error = '❌ Erro: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ativar Premium'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.star, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              'Ativar Código Premium',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Código',
                prefixIcon: Icon(Icons.star),
                border: OutlineInputBorder(),
                hintText: 'ACT-W-ABC123',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _activateCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ATIVAR AGORA'),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_success != null) ...[
              const SizedBox(height: 16),
              Text(_success!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
