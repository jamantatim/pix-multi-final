import 'package:flutter/material.dart';

class AppConfig {
  // 📞 CONTATO
  static const String pixKeyDonation = 'vendas.neyresolve@gmail.com';
  static const String supportEmail = 'adm.neyresolve@gmail.com';
  static const String whatsappNumber = '+5511986174159';
  
  // 💰 PLANOS PREMIUM
  static const double weeklyPrice = 1.99;
  static const double monthlyPrice = 4.90;
  static const double yearlyPrice = 39.90;
  
  static const int weeklyDays = 7;
  static const int monthlyDays = 30;
  static const int yearlyDays = 365;
  
  // 🎫 CÓDIGOS DE SOLICITAÇÃO (Cliente → Você)
  static const String requestWeeklyPrefix = 'REQ-W';
  static const String requestMonthlyPrefix = 'REQ-M';
  static const String requestYearlyPrefix = 'REQ-Y';
  
  // 🔓 CÓDIGOS DE ATIVAÇÃO (Você → Cliente)
  static const String activationWeeklyPrefix = 'ACT-W';
  static const String activationMonthlyPrefix = 'ACT-M';
  static const String activationYearlyPrefix = 'ACT-Y';
  
  // 🔐 SEGURANÇA
  static const String secretKey = 'MUDE_ESTA_CHAVE_SECRETA_2024!@#';
  
  // ⏰ LOGIN SEMANAL
  static const int freeLoginDays = 7;
  
  // ⏱️ TIMEOUT QR CODE
  static const int qrTimeoutSeconds = 120;
  
  // 🎨 TEMAS
  static const List<Map<String, dynamic>> themes = [
    {'name': 'Verde PIX', 'primary': Color(0xFF00C853), 'accent': Color(0xFF2979FF)},
    {'name': 'Azul', 'primary': Color(0xFF2979FF), 'accent': Color(0xFF00B0FF)},
    {'name': 'Roxo', 'primary': Color(0xFFAA00FF), 'accent': Color(0xFFD500F9)},
    {'name': 'Laranja', 'primary': Color(0xFFFF6D00), 'accent': Color(0xFFFFAB00)},
    {'name': 'Vermelho', 'primary': Color(0xFFD50000), 'accent': Color(0xFFFF1744)},
  ];
  
  // 📊 INFO DOS PLANOS
  static Map<String, Map<String, dynamic>> get planInfo => {
    'weekly': {'name': 'Semanal', 'days': 7, 'price': 1.99, 'request': requestWeeklyPrefix, 'activation': activationWeeklyPrefix},
    'monthly': {'name': 'Mensal', 'days': 30, 'price': 4.90, 'request': requestMonthlyPrefix, 'activation': activationMonthlyPrefix},
    'yearly': {'name': 'Anual', 'days': 365, 'price': 39.90, 'request': requestYearlyPrefix, 'activation': activationYearlyPrefix},
  };
}
