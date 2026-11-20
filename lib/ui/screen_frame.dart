import 'package:material_ui/material_ui.dart';

import 'layout.dart';
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
    final heading = Column(
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
                    color: messageIsError ? AppColors.berry : AppColors.muted,
                  ),
                ),
        ),
      ],
    );
    final size = MediaQuery.sizeOf(context);
    // A landscape phone is too short for the title above a keypad: the
    // title sits beside it instead (FEAT-19).
    final Widget body = compact(size) && size.width > size.height
        ? Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.gap * 2,
                    AppSizes.minTap,
                    AppSizes.gap,
                    AppSizes.gap,
                  ),
                  child: Center(child: SingleChildScrollView(child: heading)),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.gap / 2,
                    ),
                    child: child,
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.gap * 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [heading, child],
              ),
            ),
          );
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            body,
            if (leading != null) Positioned(left: 8, top: 8, child: leading!),
          ],
        ),
      ),
    );
  }
}
