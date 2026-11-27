import 'package:firebase_database/firebase_database.dart';

import '../models/breed.dart';

class BreedRepository {
  BreedRepository(this._db);

  final FirebaseDatabase _db;

  /// Escucha las razas en tiempo real (se actualiza sola si cambian en la consola).
  Stream<List<Breed>> watchBreeds() {
    final ref = _db.ref('breeds');
    try {
      ref.keepSynced(true);
    } catch (_) {
      // No soportado en todas las plataformas.
    }

    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is! Map) return <Breed>[];

      final breeds = value.entries
          .where((e) => e.value is Map)
          .map((e) => Breed.fromMap(
                e.key.toString(),
                Map<String, dynamic>.from(e.value as Map),
              ))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      return breeds;
    });
  }
}