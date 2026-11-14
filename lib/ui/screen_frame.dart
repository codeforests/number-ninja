import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// A centred, scrollable page with a title, used by the simple screens.
class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.title,
    required this.child,
    this.message,
    this.messageIsError = false,
    this.leading,
  });

  final String title;
  final Widget child;
  final String? message;
  final bool messageIsError;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.gap * 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: theme.headlineSmall),
                    const SizedBox(height: AppSizes.gap),
                    SizedBox(
                      height: AppText.body * 2.6,
                      child: message == null
                          ? null
                          : Text(
                              message!,
                              key: const Key('screen-message'),
                              textAlign: TextAlign.center,
                              style: theme.bodyLarge?.copyWith(
                                color: messageIsError
                                    ? AppColors.berry
                                    : AppColors.muted,
                              ),
                            ),
                    ),
                    child,
                  ],
                ),
              ),
            ),
            if (leading != null) Positioned(left: 8, top: 8, child: leading!),
          ],
        ),
      ),
    );
  }
}
