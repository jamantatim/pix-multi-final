import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';
import '../services/storage.dart';
import '../services/logo_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedTheme = 0;
  String _selectedLogo = 'none';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final storage = Storage();
    final theme = await storage.selectedTheme;
    final logo = await storage.qrLogo;
    if (mounted) {
      setState(() {
        _selectedTheme = theme;
        _selectedLogo = logo ?? 'none';
      });
    }
  }

  Future<void> _saveTheme(int index) async {
    await Storage().setSelectedTheme(index);
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎨 Tema aplicado!'), backgroundColor: Colors.green),
    );
  }

  Future<void> _uploadCustomLogo() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Escolher Logo'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, ImageSource.gallery), child: const Text('Galeria')),
          TextButton(onPressed: () => Navigator.pop(context, ImageSource.camera), child: const Text('Câmera')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ],
      ),
    );
    
    if (source == null) return;
    
    try {
      final picked = await picker.pickImage(source: source, maxWidth: 400, maxHeight: 400, imageQuality: 80);
      if (picked != null) {
        final imageBytes = await picked.readAsBytes();
        final processed = await LogoService.processLogoImage(imageBytes);
        if (processed != null) {
          await LogoService.saveCustomLogo(processed);
          await Storage().setQrLogo('custom');
          if (mounted) {
            setState(() => _selectedLogo = 'custom');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Logo personalizado salvo!'), backgroundColor: Colors.green),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveLogo(String logo) async {
    if (logo == 'custom') {
      await _uploadCustomLogo();
      return;
    }
    if (logo == 'none') {
      await LogoService.removeCustomLogo();
    }
    await Storage().setQrLogo(logo);
    if (mounted) {
      setState(() => _selectedLogo = logo);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('🖼️ Logo: $logo'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações Premium'), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tema
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Icon(Icons.palette, color: Colors.orange), SizedBox(width: 8), Text('Tema do App', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 12),
                    Wrap(spacing: 12, runSpacing: 12, children: AppConfig.themes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final color = entry.value['primary'] as Color;
                      final isSelected = index == _selectedTheme;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedTheme = index);
                          _saveTheme(index);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? Colors.black : Colors.transparent, width: 3),
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                        ),
                      );
                    }).toList()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Logo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Icon(Icons.image, color: Colors.orange), SizedBox(width: 8), Text('Logo no QR Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedLogo,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('Sem logo')),
                        DropdownMenuItem(value: 'company', child: Text('Logo padrão (PIX)')),
                        DropdownMenuItem(value: 'user', child: Text('Iniciais do Usuário')),
                        DropdownMenuItem(value: 'custom', child: Text('📤 Upload Personalizado')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _saveLogo(value);
                        }
                      },
                    ),
                    if (_selectedLogo == 'custom') ...[
                      const SizedBox(height: 12),
                      FutureBuilder<Uint8List?>(
                        future: LogoService.loadCustomLogo(),
                        builder: (context, snap) {
                          if (snap.hasData && snap.data != null) {
                            return Row(
                              children: [
                                const Text('Preview: '),
                                const SizedBox(width: 8),
                                Image.memory(snap.data!, width: 40, height: 40),
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await LogoService.removeCustomLogo();
                                    await Storage().setQrLogo('none');
                                    setState(() => _selectedLogo = 'none');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('🗑️ Logo removido!'), backgroundColor: Colors.orange),
                                    );
                                  },
                                ),
                              ],
                            );
                          }
                          return const Text('Selecione uma imagem para upload', style: TextStyle(color: Colors.grey, fontSize: 12));
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Timeout
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [Icon(Icons.timer, color: Colors.orange), SizedBox(width: 8), Text('Timeout do QR Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _selectedTimeout ?? 120,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 60, child: Text('1 minuto')),
                        DropdownMenuItem(value: 120, child: Text('2 minutos')),
                        DropdownMenuItem(value: 300, child: Text('5 minutos')),
                        DropdownMenuItem(value: 600, child: Text('10 minutos')),
                      ],
                      onChanged: (value) async {
                        if (value != null) {
                          await Storage().setQrTimeout(value);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('⏱️ Timeout: $value segundos'), backgroundColor: Colors.green),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int? get _selectedTimeout => null;
}
