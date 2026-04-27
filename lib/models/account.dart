import 'dart:convert';

class Account {
  final String id;
  final String name;
  final String pixKey;
  final String city;
  final String? bankName;
  final String? agency;
  final String? accountNumber;

  Account({
    required this.id,
    required this.name,
    required this.pixKey,
    required this.city,
    this.bankName,
    this.agency,
    this.accountNumber,
  });

  Map<String, dynamic> toJsonMap() => {
    'id': id,
    'name': name,
    'pixKey': pixKey,
    'city': city,
    'bankName': bankName,
    'agency': agency,
    'accountNumber': accountNumber,
  };

  String toJson() => jsonEncode(toJsonMap());

  factory Account.fromJson(String json) {
    final data = jsonDecode(json) as Map<String, dynamic>;
    return Account(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      pixKey: data['pixKey'] ?? '',
      city: data['city'] ?? '',
      bankName: data['bankName'],
      agency: data['agency'],
      accountNumber: data['accountNumber'],
    );
  }
}
