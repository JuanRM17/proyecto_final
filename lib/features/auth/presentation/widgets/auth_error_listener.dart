import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_snackbar.dart';
import '../../data/auth_repository.dart';
import '../../providers/auth_provider.dart';

/// Muestra un SnackBar cuando una acción de autenticación falla.
class AuthErrorListener extends ConsumerWidget {
  const AuthErrorListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (prev, next) {
      if (next.hasError && !next.isLoading) {
        showAppSnack(context, authErrorMessage(next.error!));
      }
    });
    return child;
  }
}