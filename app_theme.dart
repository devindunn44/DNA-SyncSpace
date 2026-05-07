import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ─── Color Palettes ───────────────────────────────────────────────────────────

enum AppColorScheme { professional, coupleFriendly, productivity, darkMode }

class AppColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final String name;
  final String subtitle;

  const AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.name,
    required this.subtitle,
  });
}

class AppPalettes {
  static const professional = AppColors(
    primary: Color(0xFF0B3A5A),
    secondary: Color(0xFFD9A441),
    background: Color(0xFFF7F9FB),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0B3A5A),
    textSecondary: Color(0xFF4A5B6C),
    accent: Color(0xFF0E6B66),
    name: 'Professional',
    subtitle: 'CAP-inspired',
  );

  static const coupleFriendly = AppColors(
    primary: Color(0xFFCC4455),
    secondary: Color(0xFFFFD3B6),
    background: Color(0xFFFFF8F5),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF4A4A4A),
    textSecondary: Color(0xFF7A7A7A),
    accent: Color(0xFF3A9FD8),
    name: 'Couple-friendly',
    subtitle: 'Warm & approachable',
  );

  static const productivity = AppColors(
    primary: Color(0xFF0052CC),
    secondary: Color(0xFF36B37E),
    background: Color(0xFFF4F5F7),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF172B4D),
    textSecondary: Color(0xFF6B778C),
    accent: Color(0xFFFF5630),
    name: 'Productivity',
    subtitle: 'Bold & fast',
  );

  static const darkMode = AppColors(
    primary: Color(0xFF1E88E5),
    secondary: Color(0xFF90CAF9),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0BEC5),
    accent: Color(0xFFFFAB40),
    name: 'Dark Mode',
    subtitle: 'Elegant & easy',
  );

  static AppColors fromScheme(AppColorScheme scheme) {
    switch (scheme) {
      case AppColorScheme.professional:
        return professional;
      case AppColorScheme.coupleFriendly:
        return coupleFriendly;
      case AppColorScheme.productivity:
        return productivity;
      case AppColorScheme.darkMode:
        return darkMode;
    }
  }
}

// ─── Theme Data ───────────────────────────────────────────────────────────────

class AppTheme {
  static ThemeData light(AppColorScheme scheme) {
    final colors = AppPalettes.fromScheme(scheme);
    return _buildTheme(colors, Brightness.light);
  }

  static ThemeData dark() {
    return _buildTheme(AppPalettes.darkMode, Brightness.dark);
  }

  static ThemeData _buildTheme(AppColors colors, Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: Colors.white,
        secondary: colors.secondary,
        onSecondary: colors.textPrimary,
        error: const Color(0xFFC0392B),
        onError: Colors.white,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        surfaceContainerHighest: colors.background,
        onSurfaceVariant: colors.textSecondary,
      ),
      scaffoldBackgroundColor: colors.background,
      fontFamily: 'DM Sans',
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'DM Sans',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: colors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'DM Sans',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        labelStyle: TextStyle(
          color: colors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: colors.textSecondary.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: colors.textSecondary.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: colors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
      cardTheme: CardTheme(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.textSecondary.withOpacity(0.15)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'DM Sans',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: 'DM Sans',
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.primary.withOpacity(0.08),
        labelStyle: TextStyle(
          color: colors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      extensions: [AppColorsExtension(colors: colors)],
    );
  }
}

// ─── Theme Extension ─────────────────────────────────────────────────────────

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final AppColors colors;
  const AppColorsExtension({required this.colors});

  @override
  AppColorsExtension copyWith({AppColors? colors}) =>
      AppColorsExtension(colors: colors ?? this.colors);

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) => this;
}

extension ThemeColors on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!.colors;
}

// ─── Providers ───────────────────────────────────────────────────────────────

final colorSchemeProvider =
    StateNotifierProvider<ColorSchemeNotifier, AppColorScheme>((ref) {
  return ColorSchemeNotifier();
});

class ColorSchemeNotifier extends StateNotifier<AppColorScheme> {
  ColorSchemeNotifier() : super(AppColorScheme.professional) {
    _load();
  }

  void _load() {
    final box = Hive.box('settings');
    final idx = box.get('colorScheme', defaultValue: 0) as int;
    state = AppColorScheme.values[idx];
  }

  void setScheme(AppColorScheme scheme) {
    state = scheme;
    Hive.box('settings').put('colorScheme', scheme.index);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final scheme = ref.watch(colorSchemeProvider);
  return ThemeModeNotifier(scheme);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(AppColorScheme scheme)
      : super(scheme == AppColorScheme.darkMode
            ? ThemeMode.dark
            : ThemeMode.light);

  void update(AppColorScheme scheme) {
    state =
        scheme == AppColorScheme.darkMode ? ThemeMode.dark : ThemeMode.light;
  }
}
