import 'package:flutter/material.dart';

import '../core/app_export.dart';

/// Custom button widget that supports various button styles and variants
///
/// Supports different button types including primary and secondary variants
/// with customizable text, colors, sizes, and interaction callbacks
///
/// @param text - The text to display on the button (required)
/// @param onPressed - Callback function when button is pressed
/// @param backgroundColor - Background color of the button
/// @param textColor - Color of the button text
/// @param fontSize - Font size of the button text
/// @param fontWeight - Font weight of the button text
/// @param width - Width constraint for the button
/// @param margin - External margin around the button
/// @param padding - Internal padding of the button
class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.width,
    this.margin,
    this.padding,
    this.border,
  }) : super(key: key);

  /// Text to display on the button
  final String text;

  /// Callback function when button is pressed
  final VoidCallback? onPressed;

  /// Background color of the button
  final Color? backgroundColor;

  /// Color of the button text
  final Color? textColor;

  /// Font size of the button text
  final double? fontSize;

  /// Font weight of the button text
  final FontWeight? fontWeight;

  /// Width constraint for the button
  final double? width;

  /// External margin around the button
  final EdgeInsetsGeometry? margin;

  /// Internal padding of the button
  final EdgeInsetsGeometry? padding;

  /// Button Border
  final RoundedRectangleBorder? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Color(0xFF1172D3),
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 30.h, vertical: 12.h),
          shape:
              border ??
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.h)),
        ),
        child: Text(
          text,
          style: TextStyleHelper.instance.bodyTextInter.copyWith(
            color: textColor ?? appTheme.whiteCustom,
          ),
        ),
      ),
    );
  }
}
