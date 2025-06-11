import 'package:flutter/material.dart';

class AppTheme {
  // カラーパレット - より視認性の高い色
  static const Color primaryColor = Color(0xFF1565C0); // より濃いブルー
  static const Color secondaryColor = Color(0xFF2E7D32); // より濃いグリーン
  static const Color errorColor = Color(0xFFD32F2F); // より濃いレッド
  static const Color backgroundColor = Color(0xFFF8F9FA); // より明るいグレー
  static const Color surfaceColor = Colors.white;
  static const Color onPrimaryColor = Colors.white;
  static const Color onSecondaryColor = Colors.white;
  static const Color onSurfaceColor = Color(0xFF1A1A1A); // より濃いダークグレー
  
  // ライトテーマ
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      background: backgroundColor,
      surface: surfaceColor,
      onPrimary: onPrimaryColor,
      onSecondary: onSecondaryColor,
      onSurface: onSurfaceColor,
    ),
    
    // AppBar テーマ
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: onPrimaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: onPrimaryColor,
        letterSpacing: 0.5,
      ),
    ),
    
    // ElevatedButton テーマ
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        minimumSize: const Size(120, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Card テーマ
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
    ),
    
    // Text テーマ
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: onSurfaceColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: onSurfaceColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: onSurfaceColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: onSurfaceColor,
      ),
    ),
  );
  
  // ダークテーマ
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      background: Color(0xFF121212),
      surface: Color(0xFF1E1E1E),
      onPrimary: onPrimaryColor,
      onSecondary: onSecondaryColor,
      onSurface: Colors.white,
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        minimumSize: const Size(120, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

// カスタムスタイル
class AppStyles {
  // 大きなボタンスタイル
  static ButtonStyle bigButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(200, 80),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
  
  // プライマリアクションボタン
  static ButtonStyle primaryActionStyle = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    foregroundColor: AppTheme.onPrimaryColor,
    minimumSize: const Size(double.infinity, 60),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 6,
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
  
  // セカンダリアクションボタン
  static ButtonStyle secondaryActionStyle = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.secondaryColor,
    foregroundColor: AppTheme.onSecondaryColor,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 4,
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );
}