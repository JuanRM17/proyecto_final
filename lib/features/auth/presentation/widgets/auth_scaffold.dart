import 'package:flutter/material.dart';

import '../../../../core/utils/responsive.dart';
import 'auth_error_listener.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.showBack = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthErrorListener(
      child: Scaffold(
        appBar: showBack ? AppBar() : null,
        body: SafeArea(
          child: ResponsiveCenter(
            maxWidth: 440,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.agriculture, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(subtitle!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 32),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}