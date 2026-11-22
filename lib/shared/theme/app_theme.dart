import 'package:flutter/material.dart';


class AppTheme {
  const AppTheme._();

  static const Color _ink = Color(0xFF0E1311);
  static const Color _lime = Color(0xFFC6F36B);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final scheme = ColorScheme.fromSeed(
      seedColor: _ink,
      brightness: brightness,
    ).copyWith(
      primary: isLight ? _ink : _lime,
      onPrimary: isLight ? Colors.white : _ink,
      tertiary: _lime,
      onTertiary: _ink,
      surface: isLight ? const Color(0xFFF2F3F0) : const Color(0xFF080B0A),
      onSurface: isLight ? const Color(0xFF101412) : const Color(0xFFEEF2EF),
      onSurfaceVariant:
          isLight ? const Color(0xFF5B6560) : const Color(0xFF9BA8A1),
      outlineVariant:
          isLight ? const Color(0xFFE2E4DE) : const Color(0xFF242C28),
      // Fondo de las tarjetas de la lista, campos y hojas.
      surfaceContainerLowest:
          isLight ? Colors.white : const Color(0xFF151B18),
      inverseSurface:
          isLight ? const Color(0xFFE4F6B4) : const Color(0xFF1A2420),
      onInverseSurface:
          isLight ? const Color(0xFF0E1311) : const Color(0xFFEEF2EF),
      error: isLight ? const Color(0xFFB3261E) : const Color(0xFFF2B8B5),
      errorContainer:
          isLight ? const Color(0xFFFBE3E0) : const Color(0xFF3A1F1D),
      onErrorContainer:
          isLight ? const Color(0xFFB3261E) : const Color(0xFFF2B8B5),
    );

    final fieldRadius = BorderRadius.circular(16);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: scheme.onSurface, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: scheme.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: fieldRadius,
          borderSide: BorderSide(color: scheme.error, width: 1.4),
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          elevation: 0,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
          side: BorderSide(color: scheme.outlineVariant, width: 1.5),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        backgroundColor: Colors.transparent,
        selectedColor: scheme.onSurface.withValues(alpha: 0.1),
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.outlineVariant,
            width: states.contains(WidgetState.selected) ? 1.5 : 1,
          ),
        ),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        highlightElevation: 4,
        backgroundColor: scheme.tertiary,
        foregroundColor: scheme.onTertiary,
        extendedTextStyle:
            const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        shape: const StadiumBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
