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
        fontFamily: fontFamily.isEmpty ? null : fontFamily,
        fontSize: 27.99,
        fontWeight: bold,
        color: primaryColor,
      ),
      
      navLargeTitleTextStyle: TextStyle(
        fontFamily: fontFamily.isEmpty ? null : fontFamily,
        fontSize: 40.31,
        fontWeight: bold,
        color: primaryColor,
      ),
    );
  }
}

class TextStyles {
  static TextStyle get h1 => TextStyle(
        fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
        fontSize: 40.31,
        fontWeight: AppTypography.bold,
        height: AppTypography.lineHeight,
      );
  
  static TextStyle get h2 => TextStyle(
        fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
        fontSize: 33.59,
        fontWeight: AppTypography.bold,
        height: AppTypography.lineHeight,
      );
  
  static TextStyle get h3 => TextStyle(
        fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
        fontSize: 27.99,
        fontWeight: AppTypography.bold,
        height: AppTypography.lineHeight,
      );
  
  static TextStyle get h4 => TextStyle(
        fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
        fontSize: 23.33,
        fontWeight: AppTypography.bold,
        height: AppTypography.lineHeight,
      );
  
  static TextStyle get h5 => TextStyle(
        fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
        fontSize: 19.44,
        fontWeight: AppTypography.bold,
        height: AppTypography.lineHeight,
      );
  
  static TextStyle get h6 => TextStyle(
        fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
        fontSize: 16.20,
        fontWeight: AppTypography.bold,
        height: AppTypography.lineHeight,
      );
  
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
        fontSize: AppTypography.baseFontSize,
        fontWeight: AppTypography.regular,
        height: AppTypography.lineHeight,
      );
  
  static TextStyle get bodyMedium => TextStyle(
        fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
        fontSize: 16.20,
        fontWeight: AppTypography.regular,
        height: AppTypography.lineHeight,
      );
  
  static TextStyle get bodySmall => TextStyle(
        fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
        fontSize: 13.5,
        fontWeight: AppTypography.regular,
        height: AppTypography.lineHeight,
      );
  
  static TextStyle get paragraph => TextStyle(
        fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
        fontSize: 13.5,
        fontWeight: AppTypography.regular,
        height: AppTypography.lineHeight,
      );

  static TextStyle get small => TextStyle(
        fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
        fontSize: 11.25,
        fontWeight: AppTypography.regular,
        height: AppTypography.lineHeight,
      );
  
  static TextStyle get button => TextStyle(
        fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
        fontSize: AppTypography.baseFontSize,
        fontWeight: AppTypography.semiBold,
        height: 1.0,
      );
  
  static TextStyle get caption => TextStyle(
        fontFamily: AppTypography.fontFamily.isEmpty ? null : AppTypography.fontFamily,
        fontSize: 9.38,
        fontWeight: AppTypography.regular,
        height: 1.4,
      );
}
