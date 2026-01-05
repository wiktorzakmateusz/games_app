import 'package:flutter/cupertino.dart';
import 'app_typography.dart';

/// This is an example page showing how to use the typography system
/// You can delete this file once you understand how to use it
class TypographyExamplePage extends StatelessWidget {
  const TypographyExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Typography Example'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Method 1: Using the predefined text styles
            Text(
              'Headline 1 - Large',
              style: TextStyles.h1,
            ),
            const SizedBox(height: 16),
            
            Text(
              'Headline 2 - Medium',
              style: TextStyles.h2,
            ),
            const SizedBox(height: 16),
            
            Text(
              'Headline 3 - Regular',
              style: TextStyles.h3,
            ),
            const SizedBox(height: 16),
            
            Text(
              'Body Large - This is body text',
              style: TextStyles.bodyLarge,
            ),
            const SizedBox(height: 16),
            
            Text(
              'Body Medium - Regular paragraph text',
              style: TextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            Text(
              'Small text for captions',
              style: TextStyles.small,
            ),
            const SizedBox(height: 32),
            
            // Method 2: Using theme text styles
            Text(
              'Using theme default style',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
            const SizedBox(height: 16),
            
            // Method 3: Customizing existing styles
            Text(
              'Custom styled heading',
              style: TextStyles.h2.copyWith(
                color: CupertinoColors.systemBlue,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 32),
            
            // Button example
            CupertinoButton.filled(
              onPressed: () {},
              child: Text(
                'Button with custom style',
                style: TextStyles.button,
              ),
            ),
            const SizedBox(height: 16),
            
            // Multiple styles in rich text
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Bold text ',
                    style: TextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                  ),
                  TextSpan(
                    text: 'with regular text',
                    style: TextStyles.bodyLarge.copyWith(
                      color: CupertinoColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

