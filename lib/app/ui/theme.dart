import 'package:flutter/material.dart';

const Color primaryGold = Color(0xFFD4AF37);
const Color primaryGoldLight = Color(0xFFF5DC9F);
const Color primaryGoldDark = Color(0xFFB8941F);

const Color secondaryWine = Color(0xFF8B4049);
const Color secondaryWineLight = Color(0xFFB55A65);
const Color secondaryWineDark = Color(0xFF6B2E35);

ThemeData theme = ThemeData(
  useMaterial3: true,

  // Base clara, simples
  brightness: Brightness.light,

  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: primaryGold,
    onPrimary: Colors.black,
    primaryContainer: primaryGoldLight,
    onPrimaryContainer: Colors.black,

    secondary: secondaryWine,
    onSecondary: Colors.white,
    secondaryContainer: secondaryWineLight,
    onSecondaryContainer: Colors.white,

    surface: Color(0xFAFAFAFA),
    onSurface: Colors.black,

    error: Colors.red,
    onError: Colors.white,
  ),

  // 🧠 Tipografia neutra (igual ao MUI)
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    bodySmall: TextStyle(color: Colors.black87),
  ),

  // 🟨 AppBar com destaque de cor
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryGold,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
  ),

  // 🟡 Botões (equivalente ao MuiButton)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryGold,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w500,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: secondaryWine,
      side: const BorderSide(color: secondaryWine),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: secondaryWine,
      textStyle: const TextStyle(fontWeight: FontWeight.w500),
    ),
  ),

  // 📄 Cards / Paper
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),

  // ⌨️ Inputs propositalmente simples (preto e branco)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 14,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: Colors.black54),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: Colors.black54),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: Colors.black, width: 1.5),
    ),
    labelStyle: const TextStyle(color: Colors.black),
    hintStyle: const TextStyle(color: Colors.black45),
  ),

  // 🔘 Ícones discretos
  iconTheme: const IconThemeData(
    color: Colors.black87,
  ),

  dividerTheme: const DividerThemeData(
    color: Colors.black12,
    thickness: 1,
  ),
);
