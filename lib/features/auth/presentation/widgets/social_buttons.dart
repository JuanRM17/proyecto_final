import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../providers/auth_provider.dart';

class SocialButtons extends ConsumerWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!supportsSocialLogin) return const SizedBox.shrink();

    final loading = ref.watch(authControllerProvider).isLoading;
    final controller = ref.read(authControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Row(children: [
          Expanded(child: Divider()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('o continúa con'),
          ),
          Expanded(child: Divider()),
        ]),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: loading ? null : controller.signInWithGoogle,
          icon: const Icon(Icons.g_mobiledata, size: 32),
          label: const Text('Google'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: loading ? null : controller.signInWithFacebook,
          icon: const Icon(Icons.facebook),
          label: const Text('Facebook'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        ),
      ],
    );
  }
}