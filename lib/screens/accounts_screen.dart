import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/storage.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});
  @override State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  List<Account> _accounts = [];
  Account? _activeAccount;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final storage = Storage();
    final accounts = await storage.accounts;
    final active = await storage.activeAccount;
    setState(() {
      _accounts = accounts;
      _activeAccount = active;
    });
  }

  void _addAccount() {
    final nameController = TextEditingController();
    final pixKeyController = TextEditingController();
    final cityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nova Conta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: pixKeyController, decoration: const InputDecoration(labelText: 'Chave PIX')),
            TextField(controller: cityController, decoration: const InputDecoration(labelText: 'Cidade')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && pixKeyController.text.isNotEmpty) {
                final account = Account(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  pixKey: pixKeyController.text,
                  city: cityController.text.isNotEmpty ? cityController.text : 'BRASIL',
                );
                _accounts.add(account);
                await Storage().saveAccounts(_accounts);
                Navigator.pop(context);
                _loadAccounts();
              }
            },
            child: const Text('SALVAR'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
        ],
      ),
    );
  }

  void _setActiveAccount(Account account) async {
    await Storage().setActiveAccount(account);
    setState(() => _activeAccount = account);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Conta ativa: ${account.name}')));
  }

  void _deleteAccount(Account account) async {
    _accounts.removeWhere((a) => a.id == account.id);
    await Storage().saveAccounts(_accounts);
    _loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Contas'), backgroundColor: Colors.green),
      body: Column(
        children: [
          Expanded(
            child: _accounts.isEmpty
                ? const Center(child: Text('Nenhuma conta salva\nToque em + para adicionar'))
                : ListView.builder(
                    itemCount: _accounts.length,
                    itemBuilder: (context, index) {
                      final account = _accounts[index];
                      final isActive = _activeAccount?.id == account.id;
                      return Card(
                        color: isActive ? Colors.green.shade50 : null,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isActive ? Colors.green : Colors.grey,
                            child: Text(account.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(account.name),
                          subtitle: Text(account.pixKey),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isActive)
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => _setActiveAccount(account),
                                  tooltip: 'Ativar conta',
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteAccount(account),
                                tooltip: 'Excluir conta',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAccount,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
