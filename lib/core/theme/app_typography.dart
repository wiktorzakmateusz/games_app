import 'package:flutter/cupertino.dart';

class AppTypography {
  static const String fontFamily = 'Bubblegum Sans';

  static const double baseFontSize = 18.0;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static const double lineHeight = 1.6;

  static CupertinoTextThemeData createTextTheme({
    Color primaryColor = CupertinoColors.black,
  }) {
    return CupertinoTextThemeData(
      primaryColor: primaryColor,

      textStyle: TextStyle(
        fontFamily: fontFamily.isEmpty ? null : fontFamily,
        fontSize: baseFontSize,
        fontWeight: regular,
        height: lineHeight,
        color: primaryColor,
      ),

      actionTextStyle: TextStyle(
        fontFamily: fontFamily.isEmpty ? null : fontFamily,
        fontSize: baseFontSize,
        fontWeight: semiBold,
        color: CupertinoColors.activeBlue,
      ),

      navTitleTextStyle: TextStyle(
        inherit: false,
        fontFamily: fontFamily.isEmpty ? null : fontFamily,
        fontSize: 27.99,
        fontWeight: bold,
        color: primaryColor,
      ),

      navLargeTitleTextStyle: TextStyle(
        inherit: false,
        fontFamily: fontFamily.isEmpty ? null : fontFamily,
        fontSize: 40.31,
        fontWeight: bold,
        color: primaryColor,
      ),
    );
  }
}

class TextStyles {
  // Headings
  static TextStyle get h1 => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 40.31,
    fontWeight: AppTypography.bold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get h2 => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 33.59,
    fontWeight: AppTypography.bold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get h3 => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 27.99,
    fontWeight: AppTypography.bold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get h4 => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 23.33,
    fontWeight: AppTypography.bold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get h5 => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 19.44,
    fontWeight: AppTypography.bold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get h6 => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 16.20,
    fontWeight: AppTypography.bold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  // Body Text - Regular Weight
  static TextStyle get bodyLarge => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: AppTypography.baseFontSize,
    fontWeight: AppTypography.regular,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get bodyMedium => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 16.20,
    fontWeight: AppTypography.regular,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get bodySmall => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 13.5,
    fontWeight: AppTypography.regular,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  // Body Text - Bold Weight
  static TextStyle get bodyLargeBold => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: AppTypography.baseFontSize,
    fontWeight: AppTypography.bold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get bodyMediumBold => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 16.20,
    fontWeight: AppTypography.bold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get bodySmallBold => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 13.5,
    fontWeight: AppTypography.bold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  // Body Text - SemiBold Weight
  static TextStyle get bodyLargeSemiBold => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: AppTypography.baseFontSize,
    fontWeight: AppTypography.semiBold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get bodyMediumSemiBold => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 16.20,
    fontWeight: AppTypography.semiBold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get bodySmallSemiBold => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 13.5,
    fontWeight: AppTypography.semiBold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  // Paragraph and Small
  static TextStyle get paragraph => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 13.5,
    fontWeight: AppTypography.regular,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get paragraphBold => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 13.5,
    fontWeight: AppTypography.bold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get small => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 11.25,
    fontWeight: AppTypography.regular,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  static TextStyle get smallBold => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 11.25,
    fontWeight: AppTypography.bold,
    height: AppTypography.lineHeight,
    color: CupertinoColors.label,
  );

  // Button and Caption
  static TextStyle get button => TextStyle(
    inherit: true, // Keep true so buttons can inherit white color from button context
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: AppTypography.baseFontSize,
    fontWeight: AppTypography.semiBold,
    height: 1.0,
  );

  static TextStyle get buttonBold => TextStyle(
    inherit: true, // Keep true so buttons can inherit white color from button context
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: AppTypography.baseFontSize,
    fontWeight: AppTypography.bold,
    height: 1.0,
  );

  static TextStyle get caption => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 9.38,
    fontWeight: AppTypography.regular,
    height: 1.4,
    color: CupertinoColors.label,
  );

  static TextStyle get captionBold => TextStyle(
    inherit: false,
    fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
    fontSize: 9.38,
    fontWeight: AppTypography.bold,
    height: 1.4,
    color: CupertinoColors.label,
  );
}