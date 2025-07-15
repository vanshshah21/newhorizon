import 'package:color/color.dart' show HslColor;
import 'package:flutter/material.dart';

extension HslColorToFlutter on HslColor {
  Color get toColor {
    final rgb = toRgbColor();
    return Color.fromARGB(255, rgb.r.toInt(), rgb.g.toInt(), rgb.b.toInt());
  }
}

class ShadcnColors {
  // Light
  static final background = HslColor(0, 0, 100);
  static final foreground = HslColor(222.2, 84, 4.9);
  static final card = HslColor(0, 0, 100);
  static final cardForeground = HslColor(222.2, 84, 4.9);
  static final popover = HslColor(0, 0, 100);
  static final popoverForeground = HslColor(222.2, 84, 4.9);
  static final primary = HslColor(221.2, 83.2, 53.3);
  static final primaryForeground = HslColor(210, 40, 98);
  static final secondary = HslColor(210, 40, 96.1);
  static final secondaryForeground = HslColor(222.2, 47.4, 11.2);
  static final muted = HslColor(210, 40, 96.1);
  static final mutedForeground = HslColor(215.4, 16.3, 46.9);
  static final accent = HslColor(210, 40, 96.1);
  static final accentForeground = HslColor(222.2, 47.4, 11.2);
  static final destructive = HslColor(0, 84.2, 60.2);
  static final destructiveForeground = HslColor(210, 40, 98);
  static final border = HslColor(214.3, 31.8, 91.4);
  static final input = HslColor(214.3, 31.8, 91.4);
  static final ring = HslColor(221.2, 83.2, 53.3);

  // Chart Colors
  static final chart1 = HslColor(12, 76, 61);
  static final chart2 = HslColor(173, 58, 39);
  static final chart3 = HslColor(197, 37, 24);
  static final chart4 = HslColor(43, 74, 66);
  static final chart5 = HslColor(27, 87, 67);

  // Dark
  static final darkBackground = HslColor(222.2, 84, 4.9);
  static final darkForeground = HslColor(210, 40, 98);
  static final darkCard = HslColor(222.2, 84, 4.9);
  static final darkCardForeground = HslColor(210, 40, 98);
  static final darkPopover = HslColor(222.2, 84, 4.9);
  static final darkPopoverForeground = HslColor(210, 40, 98);
  static final darkPrimary = HslColor(217.2, 91.2, 59.8);
  static final darkPrimaryForeground = HslColor(222.2, 47.4, 11.2);
  static final darkSecondary = HslColor(217.2, 32.6, 17.5);
  static final darkSecondaryForeground = HslColor(210, 40, 98);
  static final darkMuted = HslColor(217.2, 32.6, 17.5);
  static final darkMutedForeground = HslColor(215, 20.2, 65.1);
  static final darkAccent = HslColor(217.2, 32.6, 17.5);
  static final darkAccentForeground = HslColor(210, 40, 98);
  static final darkDestructive = HslColor(0, 62.8, 30.6);
  static final darkDestructiveForeground = HslColor(210, 40, 98);
  static final darkBorder = HslColor(217.2, 32.6, 17.5);
  static final darkInput = HslColor(217.2, 32.6, 17.5);
  static final darkRing = HslColor(224.3, 76.3, 48);

  // Dark Chart Colors
  static final darkChart1 = HslColor(220, 70, 50);
  static final darkChart2 = HslColor(160, 60, 45);
  static final darkChart3 = HslColor(30, 80, 55);
  static final darkChart4 = HslColor(280, 65, 60);
  static final darkChart5 = HslColor(340, 75, 55);
}

final shadcnLightTheme = ThemeData(
  // brightness: Brightness.light,
  scaffoldBackgroundColor: ShadcnColors.background.toColor,
  primaryTextTheme: TextTheme(),
  canvasColor: ShadcnColors.background.toColor,
  cardColor: ShadcnColors.card.toColor,
  dividerColor: ShadcnColors.border.toColor,
  primaryColor: ShadcnColors.primary.toColor,
  secondaryHeaderColor: ShadcnColors.secondary.toColor,
  highlightColor: ShadcnColors.accent.toColor,
  splashColor: ShadcnColors.accent.toColor,
  focusColor: ShadcnColors.ring.toColor,
  // hintColor: ShadcnColors.mutedForeground.toColor,
  // disabledColor: ShadcnColors.muted.toColor,
  indicatorColor: ShadcnColors.primary.toColor,
  shadowColor: Colors.black.withValues(alpha: (0.1 * 255)),
  appBarTheme: AppBarTheme(
    backgroundColor: ShadcnColors.background.toColor,
    foregroundColor: ShadcnColors.foreground.toColor,
    elevation: 0,
    iconTheme: IconThemeData(color: ShadcnColors.foreground.toColor),
    titleTextStyle: TextStyle(
      color: ShadcnColors.foreground.toColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  colorScheme: ColorScheme.light(
    primary: ShadcnColors.primary.toColor,
    onPrimary: ShadcnColors.primaryForeground.toColor,
    secondary: ShadcnColors.secondary.toColor,
    onSecondary: ShadcnColors.secondaryForeground.toColor,
    // background: ShadcnColors.background.toColor,
    // onBackground: ShadcnColors.foreground.toColor,
    surface: ShadcnColors.card.toColor,
    onSurface: ShadcnColors.cardForeground.toColor,
    error: ShadcnColors.destructive.toColor,
    onError: ShadcnColors.destructiveForeground.toColor,
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: ShadcnColors.border.toColor),
      borderRadius: BorderRadius.circular(8.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: ShadcnColors.border.toColor),
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: ShadcnColors.ring.toColor, width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: ShadcnColors.destructive.toColor),
      borderRadius: BorderRadius.circular(8.0),
    ),
    // hintStyle: TextStyle(color: ShadcnColors.mutedForeground.toColor),
    labelStyle: TextStyle(color: ShadcnColors.foreground.toColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ShadcnColors.primary.toColor,
      foregroundColor: ShadcnColors.primaryForeground.toColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 0,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: ShadcnColors.primary.toColor,
      side: BorderSide(color: ShadcnColors.border.toColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: ShadcnColors.primary.toColor,
    // unselectedLabelColor: ShadcnColors.mutedForeground.toColor,
    dividerHeight: 0,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: ShadcnColors.primary.toColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: ShadcnColors.primary.toColor,
    foregroundColor: ShadcnColors.primaryForeground.toColor,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: ShadcnColors.secondary.toColor,
    disabledColor: ShadcnColors.muted.toColor,
    selectedColor: ShadcnColors.primary.toColor,
    secondarySelectedColor: ShadcnColors.primary.toColor,
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    labelStyle: TextStyle(color: ShadcnColors.secondaryForeground.toColor),
    secondaryLabelStyle: TextStyle(
      color: ShadcnColors.primaryForeground.toColor,
    ),
    brightness: Brightness.light,
  ),
  cardTheme: CardTheme(
    elevation: 0,
    color: ShadcnColors.card.toColor,
    shadowColor: Colors.black.withValues(alpha: (0.5 * 255)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
      side: BorderSide(color: ShadcnColors.border.toColor, width: 2),
    ),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: ShadcnColors.popover.toColor,
    titleTextStyle: TextStyle(
      color: ShadcnColors.popoverForeground.toColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: TextStyle(color: ShadcnColors.popoverForeground.toColor),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: ShadcnColors.card.toColor,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: ShadcnColors.border.toColor, width: 2),
      borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: ShadcnColors.foreground.toColor),
    bodyMedium: TextStyle(color: ShadcnColors.foreground.toColor),
    // bodySmall: TextStyle(color: ShadcnColors.mutedForeground.toColor),
    titleLarge: TextStyle(color: ShadcnColors.foreground.toColor),
    titleMedium: TextStyle(color: ShadcnColors.foreground.toColor),
    // titleSmall: TextStyle(color: ShadcnColors.mutedForeground.toColor),
    labelLarge: TextStyle(color: ShadcnColors.primary.toColor),
    labelMedium: TextStyle(color: ShadcnColors.primary.toColor),
    // labelSmall: TextStyle(color: ShadcnColors.mutedForeground.toColor),
    displayMedium: TextStyle(
      color: ShadcnColors.foreground.toColor,
      fontWeight: FontWeight.w500,
    ),
  ),

  expansionTileTheme: ExpansionTileThemeData(
    // shape: RoundedRectangleBorder(
    //   side: BorderSide(color: ShadcnColors.border.toColor, width: 2),
    //   borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
    // ),
    backgroundColor: ShadcnColors.card.toColor,
    collapsedBackgroundColor: ShadcnColors.card.toColor,
    collapsedIconColor: ShadcnColors.primary.toColor,
    iconColor: ShadcnColors.foreground.toColor,
  ),
);

final shadcnDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: ShadcnColors.darkBackground.toColor,
  canvasColor: ShadcnColors.darkBackground.toColor,
  cardColor: ShadcnColors.darkCard.toColor,
  dividerColor: ShadcnColors.darkBorder.toColor,
  primaryColor: ShadcnColors.darkPrimary.toColor,
  secondaryHeaderColor: ShadcnColors.darkSecondary.toColor,
  highlightColor: ShadcnColors.darkAccent.toColor,
  splashColor: ShadcnColors.darkAccent.toColor,
  focusColor: ShadcnColors.darkRing.toColor,
  hintColor: ShadcnColors.darkMutedForeground.toColor,
  disabledColor: ShadcnColors.darkMuted.toColor,
  indicatorColor: ShadcnColors.darkPrimary.toColor,
  shadowColor: Colors.black.withValues(alpha: (0.2 * 255)),
  appBarTheme: AppBarTheme(
    backgroundColor: ShadcnColors.darkBackground.toColor,
    foregroundColor: ShadcnColors.darkForeground.toColor,
    elevation: 0,
    iconTheme: IconThemeData(color: ShadcnColors.darkForeground.toColor),
    titleTextStyle: TextStyle(
      color: ShadcnColors.darkForeground.toColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  colorScheme: ColorScheme.dark(
    primary: ShadcnColors.darkPrimary.toColor,
    onPrimary: ShadcnColors.darkPrimaryForeground.toColor,
    secondary: ShadcnColors.darkSecondary.toColor,
    onSecondary: ShadcnColors.darkSecondaryForeground.toColor,
    surface: ShadcnColors.darkBackground.toColor,
    onSurface: ShadcnColors.darkForeground.toColor,
    error: ShadcnColors.darkDestructive.toColor,
    onError: ShadcnColors.darkDestructiveForeground.toColor,
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: ShadcnColors.darkInput.toColor,
    filled: true,
    border: OutlineInputBorder(
      borderSide: BorderSide(color: ShadcnColors.darkBorder.toColor),
      borderRadius: BorderRadius.circular(8.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: ShadcnColors.darkBorder.toColor),
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: ShadcnColors.darkRing.toColor, width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: ShadcnColors.darkDestructive.toColor),
      borderRadius: BorderRadius.circular(8.0),
    ),
    hintStyle: TextStyle(color: ShadcnColors.darkMutedForeground.toColor),
    labelStyle: TextStyle(color: ShadcnColors.darkForeground.toColor),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ShadcnColors.darkPrimary.toColor,
      foregroundColor: ShadcnColors.darkPrimaryForeground.toColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 0,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: ShadcnColors.darkPrimary.toColor,
      side: BorderSide(color: ShadcnColors.darkBorder.toColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: ShadcnColors.darkPrimary.toColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: ShadcnColors.darkPrimary.toColor,
    foregroundColor: ShadcnColors.darkPrimaryForeground.toColor,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: ShadcnColors.darkSecondary.toColor,
    disabledColor: ShadcnColors.darkMuted.toColor,
    selectedColor: ShadcnColors.darkPrimary.toColor,
    secondarySelectedColor: ShadcnColors.darkPrimary.toColor,
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    labelStyle: TextStyle(color: ShadcnColors.darkSecondaryForeground.toColor),
    secondaryLabelStyle: TextStyle(
      color: ShadcnColors.darkPrimaryForeground.toColor,
    ),
    brightness: Brightness.dark,
  ),
  cardTheme: CardTheme(
    color: ShadcnColors.darkCard.toColor,
    shadowColor: Colors.black.withValues(alpha: (0.1 * 255)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
      side: BorderSide(color: ShadcnColors.darkBorder.toColor),
    ),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: ShadcnColors.darkPopover.toColor,
    titleTextStyle: TextStyle(
      color: ShadcnColors.darkPopoverForeground.toColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: TextStyle(
      color: ShadcnColors.darkPopoverForeground.toColor,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: ShadcnColors.darkCard.toColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: ShadcnColors.darkForeground.toColor),
    bodyMedium: TextStyle(color: ShadcnColors.darkForeground.toColor),
    bodySmall: TextStyle(color: ShadcnColors.darkMutedForeground.toColor),
    titleLarge: TextStyle(color: ShadcnColors.darkForeground.toColor),
    titleMedium: TextStyle(color: ShadcnColors.darkForeground.toColor),
    titleSmall: TextStyle(color: ShadcnColors.darkMutedForeground.toColor),
    labelLarge: TextStyle(color: ShadcnColors.darkPrimary.toColor),
    labelMedium: TextStyle(color: ShadcnColors.darkPrimary.toColor),
    labelSmall: TextStyle(color: ShadcnColors.darkMutedForeground.toColor),
  ),
);
