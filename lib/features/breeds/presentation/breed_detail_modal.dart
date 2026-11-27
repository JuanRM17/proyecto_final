import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_network_image.dart';
import '../models/breed.dart';

/// Abre la ficha de la raza cubriendo toda la pantalla, con transición
/// de la imagen (Hero) desde la tarjeta.
Future<void> showBreedDetail(BuildContext context, Breed breed) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: true,
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, _, _) => BreedDetailModal(breed: breed),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    ),
  );
}

class BreedDetailModal extends StatelessWidget {
  const BreedDetailModal({super.key, required this.breed});

  final Breed breed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ResponsiveCenter(
        maxWidth: 800,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: true,
              expandedHeight: 340,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(breed.name),
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.fadeTitle,
                ],
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'breed-${breed.id}',
                      child: AppNetworkImage(url: breed.imageUrl),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList.list(
                children: [
                  _InfoTile(
                    icon: Icons.place_outlined,
                    label: 'Origen',
                    value: breed.origin,
                  ),
                  _InfoTile(
                    icon: Icons.category_outlined,
                    label: 'Aptitud',
                    value: breed.purpose,
                  ),
                  _InfoTile(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Peso aproximado',
                    value: breed.weight,
                  ),
                  const SizedBox(height: 16),
                  Text(breed.description, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Text('Características', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in breed.traits) Chip(label: Text(t)),
                    ],
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}