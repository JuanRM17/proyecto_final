import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../providers/breeds_provider.dart';
import 'breed_card.dart';
import 'breed_detail_modal.dart';

class BreedsScreen extends ConsumerWidget {
  const BreedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(breedsProvider);
    final filtered = ref.watch(filteredBreedsProvider);
    final filter = ref.watch(breedFilterProvider);

    return ResponsiveCenter(
      maxWidth: 1200,
      child: Column(
        children: [
          all.maybeWhen(
            data: (list) {
              final purposes = list.map((b) => b.purpose).toSet().toList()
                ..sort();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Todas'),
                      selected: filter == null,
                      onSelected: (_) =>
                          ref.read(breedFilterProvider.notifier).select(null),
                    ),
                    for (final p in purposes) ...[
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(p),
                        selected: filter == p,
                        onSelected: (_) =>
                            ref.read(breedFilterProvider.notifier).select(p),
                      ),
                    ],
                  ],
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          Expanded(
            child: filtered.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No se pudieron cargar las razas.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => ref.invalidate(breedsProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (breeds) {
                if (breeds.isEmpty) {
                  return const Center(child: Text('No hay razas para mostrar.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: breeds.length,
                  itemBuilder: (context, i) => BreedCard(
                    breed: breeds[i],
                    onTap: () => showBreedDetail(context, breeds[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}