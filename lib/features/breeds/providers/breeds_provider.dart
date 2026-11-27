import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/firebase_providers.dart';
import '../data/breed_repository.dart';
import '../models/breed.dart';

final breedRepositoryProvider = Provider<BreedRepository>(
  (ref) => BreedRepository(ref.watch(firebaseDatabaseProvider)),
);

final breedsProvider = StreamProvider.autoDispose<List<Breed>>(
  (ref) => ref.watch(breedRepositoryProvider).watchBreeds(),
);

/// Filtro por aptitud (null = todas).
class BreedFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? purpose) => state = purpose;
}

final breedFilterProvider =
    NotifierProvider<BreedFilterNotifier, String?>(BreedFilterNotifier.new);

final filteredBreedsProvider =
    Provider.autoDispose<AsyncValue<List<Breed>>>((ref) {
  final filter = ref.watch(breedFilterProvider);
  return ref.watch(breedsProvider).whenData(
        (list) => filter == null
            ? list
            : list.where((b) => b.purpose == filter).toList(),
      );
});