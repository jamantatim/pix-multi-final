import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage.dart';
import '../services/request_service.dart';
import 'activation_screen.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isPremium = false;
  String? _contractedPlan;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    final storage = Storage();
    final isPremium = await storage.isPremium;
    final plan = await storage.contractedPlan;
    setState(() {
      _isPremium = isPremium;
      _contractedPlan = plan;
    });
  }

  void _generateRequestCode(String planType) {
    final requestCode = RequestService.generateRequestCode(planType);
    Storage().saveGeneratedRequest(requestCode);
    Storage().setContractedPlan(planType);
    setState(() {});
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('📋 Código de Solicitação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Envie este código + comprovante PIX para ativar:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange, width: 2)),
              child: Text(requestCode, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'monospace'), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            Text('Plano: ${RequestService.getPlanInfo(planType)['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Valor: ${RequestService.getPlanInfo(planType)['price']}', style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 8),
            const Text('📧 Envie para: vendas.neyresolve@gmail.com', style: TextStyle(fontSize: 12)),
            const Text('📱 WhatsApp: +5511986174159', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: requestCode));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Código copiado!')));
            },
            child: const Text('COPIAR'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('FECHAR')),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String planType, String name, String price, String days, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.orange),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(price, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            Text('$days dias', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _generateRequestCode(planType),
                icon: const Icon(Icons.qr_code),
                label: const Text('GERAR CÓDIGO DE SOLICITAÇÃO'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium'), backgroundColor: Colors.orange, actions: [
        if (_isPremium)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Chip(avatar: Icon(Icons.star, color: Colors.white, size: 18), label: Text('ATIVO', style: TextStyle(color: Colors.white, fontSize: 12)), backgroundColor: Colors.green),
          ),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isPremium) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 50),
                      const SizedBox(height: 8),
                      const Text('✅ Premium Ativo!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 8),
                      FutureBuilder<String?>(
                        future: Storage().contractedPlan,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final plan = RequestService.getPlanInfo(snapshot.data!);
                            return Text('Plano: ${plan['name']}', style: const TextStyle(fontSize: 16));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      FutureBuilder<String?>(
                        future: Storage().expiry,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final expiry = DateTime.tryParse(snapshot.data!);
                            if (expiry != null) {
                              final daysLeft = expiry.difference(DateTime.now()).inDays;
                              return Text('⏰ Expira em: $daysLeft dias', style: const TextStyle(fontSize: 14, color: Colors.orange));
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text('Escolha seu Plano:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPlanCard('weekly', 'Semanal', 'R\$ 1,99', '7', Icons.today),
            const SizedBox(height: 16),
            _buildPlanCard('monthly', 'Mensal', 'R\$ 4,90', '30', Icons.calendar_today),
            const SizedBox(height: 16),
            _buildPlanCard('yearly', 'Anual', 'R\$ 39,90', '365', Icons.calendar_month),
            const SizedBox(height: 24),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📋 Como Funciona:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('1️⃣ Escolha um plano acima'),
                    const Text('2️⃣ Toque em "Gerar Código de Solicitação"'),
                    const Text('3️⃣ Copie o código gerado'),
                    const Text('4️⃣ Faça PIX para: vendas.neyresolve@gmail.com'),
                    const Text('5️⃣ Envie código + comprovante'),
                    const Text('6️⃣ Receba código de ativação'),
                    const Text('7️⃣ Ative no app e aproveite! 🎉'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.orange.shade50,
              child: ListTile(
                leading: const Icon(Icons.lock_open, color: Colors.orange),
                title: const Text('Já tenho código de ativação'),
                subtitle: const Text('Ativar Premium agora'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ActivationScreen()));
                  if (result == true) {
                    _checkPremiumStatus();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📞 Suporte:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('📧 Email: Vendas.neyresolve@gmail.com'),
                    const Text('📱 WhatsApp: +5511986174159'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
