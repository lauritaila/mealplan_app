import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final Widget? footer;
  final String? appBarTitle;
  final VoidCallback? onBack;

  const AuthLayout({
    super.key,
    required this.child,
    this.footer,
    this.appBarTitle,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: appBarTitle != null
          ? AppBar(
              title: Text(
                appBarTitle!,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              leading: onBack != null
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: onBack,
                    )
                  : null,
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: child,
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: footer!,
              ),
          ],
        ),
      ),
    );
  }
}
