import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_snackbar.dart';
import '../providers/auth_provider.dart';
import 'widgets/auth_scaffold.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => ref.read(sessionProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    await ref.read(authControllerProvider.notifier).sendVerificationEmail();
    if (!mounted) return;
    if (!ref.read(authControllerProvider).hasError) {
      showAppSnack(context, 'Correo de verificación reenviado.');
    }
  }

  Future<void> _check() async {
    await ref.read(sessionProvider.notifier).refresh();
    if (!mounted) return;
    if (ref.read(sessionProvider)?.canAccess != true) {
      showAppSnack(
        context,
        'Aún no detectamos la verificación. Revisa tu correo (y spam).',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    final loading = ref.watch(authControllerProvider).isLoading;
    final controller = ref.read(authControllerProvider.notifier);

    return AuthScaffold(
      title: 'Verifica tu correo',
      subtitle: 'Enviamos un enlace a ${user?.email ?? 'tu correo'}. '
          'Ábrelo para activar tu cuenta.',
      children: [
        FilledButton(
          onPressed: loading ? null : _check,
          child: const Text('Ya lo verifiqué'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: loading ? null : _resend,
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: const Text('Reenviar correo'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: loading ? null : controller.signOut,
          child: const Text('Usar otra cuenta'),
        ),
      ],
    );
  }
}