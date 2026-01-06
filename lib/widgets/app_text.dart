import 'package:flutter/widgets.dart';

import '../core/theme/app_typography.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
      this.text, {
        super.key,
        this.style,
        this.textAlign,
        this.maxLines,
        this.overflow,
      });

  // Headings
  factory AppText.h1(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.h1,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.h2(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.h2,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.h3(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.h3,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.h4(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.h4,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.h5(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.h5,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.h6(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.h6,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  // Body Text - Regular Weight
  factory AppText.bodyLarge(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.bodyLarge,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.bodyMedium(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.bodyMedium,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.bodySmall(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.bodySmall,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  // Body Text - Bold Weight
  factory AppText.bodyLargeBold(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.bodyLargeBold,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.bodyMediumBold(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.bodyMediumBold,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.bodySmallBold(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.bodySmallBold,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  // Body Text - SemiBold Weight
  factory AppText.bodyLargeSemiBold(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.bodyLargeSemiBold,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.bodyMediumSemiBold(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.bodyMediumSemiBold,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.bodySmallSemiBold(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.bodySmallSemiBold,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  // Paragraph
  factory AppText.paragraph(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.paragraph,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.paragraphBold(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.paragraphBold,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  // Small
  factory AppText.small(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.small,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.smallBold(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.smallBold,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  // Button
  factory AppText.button(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.button,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.buttonBold(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.buttonBold,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  // Caption
  factory AppText.caption(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.caption,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory AppText.captionBold(String text, {Key? key, TextAlign? textAlign, int? maxLines, TextOverflow? overflow}) {
    return AppText(
      text,
      key: key,
      style: TextStyles.captionBold,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: style,
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}