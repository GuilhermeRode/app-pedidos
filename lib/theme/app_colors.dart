import 'package:flutter/material.dart';

/// Paleta de cores do app, baseada na identidade visual da DIMARCY
/// (logo em preto e azul sobre fundo branco).
class AppColors {
  AppColors._();

  // Fundo geral das telas (branco levemente azulado)
  static const Color background = Color(0xFFF5F8FC);

  // Superfícies: cards, appbar, bottom sheets
  static const Color surface = Color(0xFFFFFFFF);

  // Cor de preenchimento de campos de texto
  static const Color inputFill = Color(0xFFF0F4F9);

  // Bordas e divisores sutis
  static const Color border = Color(0xFFE1E8F0);

  // Azul da marca (extraído da logo DIMARCY)
  static const Color primary = Color(0xFF3CA4EB);
  static const Color primaryLight = Color(0xFF7FC6F2);
  static const Color primaryDark = Color(0xFF1E86CC);

  // Preto da marca, usado como texto principal
  static const Color textPrimary = Color(0xFF15181F);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textOnPrimary = Colors.white;

  // Cores semânticas (mantidas para estados de pedidos/estoque)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradiente do card de destaque (ex.: total em vendas)
  static const List<Color> primaryGradient = [primary, primaryLight];
}
