import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../services/storage.dart';
import '../services/pix_service.dart';
import '../services/logo_service.dart';  // ← DEVE ESTAR AQUI!
import '../models/account.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/currency_input_formatter.dart';
import '../widgets/logo_placeholder.dart';  // ← DEVE ESTAR AQUI!
import 'login_screen.dart';
import 'premium_screen.dart';
import 'activation_screen.dart';
import 'settings_screen.dart';
import 'accounts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _chave = TextEditingController();
  final _nome = TextEditingController();
  final _cidade = TextEditingController();
  final _valor = TextEditingController();
  String? _qr;
  DateTime? _qrExpiry;
  Account? _activeAccount;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadActiveAccount();
    _checkPremium();
  }

  Future<void> _loadActiveAccount() async {
    _activeAccount = await Storage().activeAccount;
    if (_activeAccount != null && mounted) {
      setState(() {
        _chave.text = _activeAccount!.pixKey;
        _nome.text = _activeAccount!.name;
        _cidade.text = _activeAccount!.city;
      });
    }
  }

  Future<void> _checkPremium() async {
    final isPremium = await Storage().isPremium;
    if (mounted) {
      setState(() => _isPremium = isPremium);
    }
  }

  void _generate() {
    if (_chave.text.isEmpty || _nome.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Preencha Chave e Nome')),
      );
      return;
    }
    
    String valorLimpo = _valor.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    setState(() {
      _qr = PixService.generatePix(
        chave: _chave.text,
        nome: _nome.text,
        cidade: _cidade.text.isNotEmpty ? _cidade.text : 'BRASIL',
        valor: valorLimpo.isNotEmpty ? valorLimpo : null,
      );
      _qrExpiry = DateTime.now().add(const Duration(seconds: 120));
    });
  }

  Future<void> _donate() async {
    final uri = Uri.parse('pix://${AppConfig.pixKeyDonation}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Clipboard.setData(ClipboardData(text: AppConfig.pixKeyDonation));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chave PIX copiada: ${AppConfig.pixKeyDonation}')),
      );
    }
  }

  void _logout() async {
    await Storage().setLastLogin();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PIX Multi'),
            if (_isPremium)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        actions: [
          if (_isPremium)
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.orange),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
              tooltip: 'Configurações Premium',
            ),
          IconButton(
            icon: const Icon(Icons.star, color: Colors.orange),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ActivationScreen()),
              );
              if (result == true && mounted) {
                setState(() {});
                _checkPremium();
              }
            },
            tooltip: 'Ativar Premium',
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.yellow),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'accounts') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountsScreen()),
                );
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'accounts', child: Text('📋 Multi-Contas')),
              const PopupMenuItem(value: 'logout', child: Text('🚪 Sair')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de Geração
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gerar QR Code PIX',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _chave,
                      decoration: const InputDecoration(
                        labelText: 'Chave PIX',
                        prefixIcon: Icon(Icons.key),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nome,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _cidade,
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _valor,
                      decoration: const InputDecoration(
                        labelText: 'Valor (opcional)',
                        prefixIcon: Icon(Icons.monetization_on),
                        prefixText: 'R\$ ',
                        border: OutlineInputBorder(),
                        hintText: '0,00',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [CurrencyInputFormatter()],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _generate,
                      icon: const Icon(Icons.qr_code),
                      label: const Text('GERAR QR CODE'),
                    ),
                  ],
                ),
              ),
            ),
            
           // QR Code Gerado
           if (_qr != null) ...[
             const SizedBox(height: 20),
             Card(
               child: Padding(
                 padding: const EdgeInsets.all(16),
                 child: Column(
                   children: [
                     const Text(
                       'QR Code PIX:',
                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                     ),
                     const SizedBox(height: 16),
          
                     // QR Code com Logo
                     FutureBuilder<String?>(
                       future: Storage().qrLogo,
                       builder: (context, logoSnap) {
                         final logoType = logoSnap.data ?? 'none';
              
                         return FutureBuilder<Uint8List?>(
                           future: _getLogoImage(logoType, _nome.text),
                           builder: (context, imageSnap) {
                             return QrImageView(
                               data: _qr!,
                               version: QrVersions.auto,
                               size: 200.0,
                               backgroundColor: Colors.white,
                               eyeStyle: const QrEyeStyle(
                                 eyeShape: QrEyeShape.square,
                                 color: Color(0xFF00C853),
                               ),
                               dataModuleStyle: const QrDataModuleStyle(
                                 dataModuleShape: QrDataModuleShape.square,
                                 color: Colors.black,
                               ),
                               embeddedImage: imageSnap.data != null
                                   ? MemoryImage(imageSnap.data!)
                                   : null,
                               embeddedImageStyle: const QrEmbeddedImageStyle(
                                 size: Size(40, 40),
                               ),
                             );
                           },
                         );
                       },
                     ),
          
                     const SizedBox(height: 16),
          
                     // Countdown Timer
                     if (_qrExpiry != null)
                       CountdownTimerWidget(
                         expiryTime: _qrExpiry!,
                         onExpired: () {
                           if (mounted) {
                             setState(() {
                               _qr = null;
                               _qrExpiry = null;
                               _valor.clear();
                             });
                           }
                         },
                       ),
          
                     const SizedBox(height: 16),
          
                     const Text(
                       'Ou use o "Copiar e Cola":',
                       style: TextStyle(fontWeight: FontWeight.bold),
                     ),
                     const SizedBox(height: 8),
                     Text(
                       _qr!,
                       style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                       maxLines: 4,
                       overflow: TextOverflow.ellipsis,
                       textAlign: TextAlign.center,
                     ),
                     const SizedBox(height: 16),
                     ElevatedButton.icon(
                       onPressed: () {
                         Clipboard.setData(ClipboardData(text: _qr!));
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(
                             content: Text('✅ "Copiar e Cola" copiado!'),
                             backgroundColor: Colors.green,
                             duration: Duration(seconds: 2),
                           ),
                         );
                       },
                       icon: const Icon(Icons.copy),
                       label: const Text('COPIAR "COPIAR E COLA"'),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF00C853),
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                       ),
                     ),
                   ],
                 ),
               ),
             ),
           ],
            
            // Card de Doação
            const SizedBox(height: 20),
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text('Gostou?'),
                subtitle: const Text('Doe via PIX (voluntário)'),
                trailing: ElevatedButton(
                  onPressed: _donate,
                  child: const Text('DOAR'),
                ),
              ),
            ),
            
            // Card Premium
            const SizedBox(height: 20),
            Card(
              color: Colors.orange.shade50,
              child: ListTile(
                leading: const Icon(Icons.star, color: Colors.orange),
                title: const Text('Seja Premium'),
                subtitle: const Text('Sem login semanal + recursos extras'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PremiumScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  // ✅ Método para gerar/carregar imagem do logo
  Future<Uint8List?> _getLogoImage(String logoType, String userName) async {
    switch (logoType) {
      case 'custom':
        // Carregar logo personalizado do usuário
        return await LogoService.loadCustomLogo();
        
      case 'company':
        // Logo padrão da empresa (placeholder)
        return LogoPlaceholder.generate(text: 'PIX');
        
      case 'user':
        // Iniciais do usuário
        final initials = userName.isNotEmpty
            ? userName.split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
            : 'PX';
        return LogoPlaceholder.generate(text: initials);
        
      default:
        return null; // Sem logo
    }
  }
  void dispose() {
    _chave.dispose();
    _nome.dispose();
    _cidade.dispose();
    _valor.dispose();
    super.dispose();
  }
}
