import 'package:flutter/material.dart';

LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.

// ignore_for_file: must_be_immutable
class ThemeHelper {
  // The current app theme
  var _appTheme = "lightCode";

  // A map of custom color themes supported by the app
  Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors(),
  };

  // A map of color schemes supported by the app
  Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme,
  };

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      canvasColor: appTheme.blue_gray_900_01,
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        dragHandleColor: _getThemeColors().grey400,
      ),
    );
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light();
}

class LightCodeColors {
  // App Colors
  Color get white_A700 => Color(0xFFFFFFFF);
  Color get gray_900 => Color(0xFF111921);
  Color get gray_200 => Color(0xFFE5E8EA);
  Color get indigo_200 => Color(0xFF91ADC9);
  Color get blue_gray_700 => Color(0xFF334C66);
  Color get blue_gray_900 => Color(0xFF233547);
  Color get blue_gray_900_01 => Color(0xFF192633);
  Color get green_A700 => Color(0xFF0AD85B);
  Color get blue_700 => Color(0xFF1172D3);
  Color get black_900_26 => Color(0x26000000);
  Color get gray_300 => Color(0xFFE3E4E8);

  // Additional Colors
  Color get redCustom => Colors.red;
  Color get transparentCustom => Colors.transparent;
  Color get whiteCustom => Colors.white;
  Color get greenCustom => Colors.green;
  Color get greyCustom => Colors.grey;
  Color get colorFF607D => Color(0xFF607D94);
  Color get colorFF4CAF => Color(0xFF4CAF50);
  Color get colorFFF443 => Color(0xFFF44336);

  // Color Shades - Each shade has its own dedicated constant
  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;
  Color get grey400 => Colors.grey.shade400;
  Color get grey300 => Colors.grey.shade300;
}
