import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/firebase_config.dart';

final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  final db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: kDatabaseUrl,
  );

  // Caché en disco de los datos: permite ver razas sin conexión (móvil).
  if (!kIsWeb) {
    try {
      db.setPersistenceEnabled(true);
    } catch (_) {
      // Ya se usó la instancia o la plataforma no lo soporta.
    }
  }
  return db;
});