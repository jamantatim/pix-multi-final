import 'package:flutter/services.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remover tudo que não é dígito
    String text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (text.isEmpty) {
      return const TextEditingValue(text: '');
    }
    
    // Converter para centavos → reais
    int value = int.parse(text);
    String reais = (value ~/ 100).toString();
    String centavos = (value % 100).toString().padLeft(2, '0');
    
    // Formatar com vírgula (padrão brasileiro)
    String formatted = 'R\$ $reais,$centavos';
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
