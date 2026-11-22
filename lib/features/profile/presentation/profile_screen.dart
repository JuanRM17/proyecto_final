import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/responsive.dart';
import '../../auth/presentation/widgets/auth_error_listener.dart';
import '../../auth/providers/auth_provider.dart';
import 'user_avatar.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    await ref.read(authControllerProvider.notifier).changePhoto(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider);
    final loading = ref.watch(authControllerProvider).isLoading;
    final theme = Theme.of(context);

    if (user == null) return const Scaffold();

    return AuthErrorListener(
      child: Scaffold(
        appBar: AppBar(title: const Text('Mi perfil')),
        body: ResponsiveCenter(
          maxWidth: 520,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Stack(
                  children: [
                    const UserAvatar(radius: 64),
                    if (loading)
                      const Positioned.fill(
                        child: CircularProgressIndicator(),
                      ),
                    if (user.usesPassword)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filled(
                          onPressed: loading ? null : _pickPhoto,
                          icon: const Icon(Icons.photo_camera),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(user.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall),
              if (user.email != null)
                Text(user.email!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.login),
                      title: const Text('Método de acceso'),
                      subtitle: Text(user.providerLabel),
                    ),
                    ListTile(
                      leading: const Icon(Icons.verified_outlined),
                      title: const Text('Correo verificado'),
                      subtitle: Text(user.canAccess ? 'Sí' : 'No'),
                    ),
                  ],
                ),
              ),
              if (!user.usesPassword)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Tu foto viene de ${user.providerLabel}. '
                    'Solo las cuentas de correo pueden cambiarla aquí.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: loading
                    ? null
                    : () async {
                        await ref.read(authControllerProvider.notifier).signOut();
                        if (context.mounted) context.go('/login');
                      },
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}