class PixService {
  static String generatePix({
    required String chave,
    required String nome,
    required String cidade,
    String? valor,
    String txid = '***',
  }) {
    nome = _normalize(nome.toUpperCase()).trim();
    cidade = _normalize(cidade.toUpperCase()).trim();
    chave = chave.trim();
    
    if (nome.length > 25) nome = nome.substring(0, 25);
    if (cidade.length > 15) cidade = cidade.substring(0, 15);
    if (nome.isEmpty) nome = 'SEM NOME';
    if (cidade.isEmpty) cidade = 'SEM CIDADE';
    
    String valorFormatado = '';
    if (valor != null && valor.isNotEmpty) {
      String apenasNumeros = valor.replaceAll(RegExp(r'[^0-9]'), '');
      if (apenasNumeros.isNotEmpty) {
        int centavos = int.parse(apenasNumeros);
        valorFormatado = (centavos / 100).toStringAsFixed(2);
      }
    }
    
    String payload = '';
    payload += _field('00', '01');
    payload += _field('26', _field('00', 'BR.GOV.BCB.PIX') + _field('01', chave));
    payload += _field('52', '0000');
    payload += _field('53', '986');
    if (valorFormatado.isNotEmpty) {
      payload += _field('54', valorFormatado);
    }
    payload += _field('58', 'BR');
    payload += _field('59', nome);
    payload += _field('60', cidade);
    payload += _field('62', _field('05', txid));
    payload += '6304';
    payload += _crc16(payload);
    
    return payload;
  }
  
  static String _field(String id, String value) {
    return '$id${value.length.toString().padLeft(2, '0')}$value';
  }
  
  static String _crc16(String payload) {
    int crc = 0xFFFF;
    const polynomial = 0x1021;
    for (int i = 0; i < payload.length; i++) {
      crc ^= payload.codeUnitAt(i) << 8;
      for (int j = 0; j < 8; j++) {
        crc = (crc & 0x8000) != 0 ? (crc << 1) ^ polynomial : crc << 1;
      }
    }
    return (crc & 0xFFFF).toRadixString(16).toUpperCase().padLeft(4, '0');
  }
  
  static String _normalize(String text) {
    return text
        .replaceAll('Á', 'A').replaceAll('À', 'A').replaceAll('Ã', 'A').replaceAll('Â', 'A')
        .replaceAll('É', 'E').replaceAll('È', 'E').replaceAll('Ê', 'E')
        .replaceAll('Í', 'I').replaceAll('Ì', 'I').replaceAll('Î', 'I')
        .replaceAll('Ó', 'O').replaceAll('Ò', 'O').replaceAll('Õ', 'O').replaceAll('Ô', 'O')
        .replaceAll('Ú', 'U').replaceAll('Ù', 'U').replaceAll('Û', 'U')
        .replaceAll('Ç', 'C')
        .replaceAll(RegExp(r'[^A-Z0-9 ]'), '');
  }
  
  static bool isValidPix(String pixCode) {
    if (pixCode.length < 50) return false;
    if (!pixCode.startsWith('000201')) return false;
    if (!pixCode.contains('6304')) return false;
    final parts = pixCode.split('6304');
    return parts.length == 2 && parts[1].length == 4;
  }
}
