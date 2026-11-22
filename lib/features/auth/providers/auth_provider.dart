import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../models/app_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

/// Sesión actual como [AppUser]? (null = sin sesión).
class SessionNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() {
    final repo = ref.watch(authRepositoryProvider);
    final sub = repo.userChanges.listen((u) {
      state = u == null ? null : AppUser.fromFirebase(u);
    });
    ref.onDispose(sub.cancel);

    final u = repo.currentUser;
    return u == null ? null : AppUser.fromFirebase(u);
  }

  Future<void> refresh() async {
    final repo = ref.read(authRepositoryProvider);
    try {
      await repo.reloadUser();
    } catch (_) {
      return; // sin red o usuario inválido: se intentará de nuevo
    }
    final u = repo.currentUser;
    state = u == null ? null : AppUser.fromFirebase(u);
  }
}

final sessionProvider =
    NotifierProvider<SessionNotifier, AppUser?>(SessionNotifier.new);

/// Acciones de autenticación con estado de carga/error para la UI.
class AuthController extends AsyncNotifier<void> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<void> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await action();
      } on AuthCancelledException {
        // El usuario canceló: sin error.
      }
    });
  }

  Future<void> login(String email, String password) =>
      _run(() => _repo.loginWithEmail(email, password));

  Future<void> register(String name, String email, String password) => _run(
        () => _repo.registerWithEmail(name: name, email: email, password: password),
      );

  Future<void> signInWithGoogle() => _run(_repo.signInWithGoogle);

  Future<void> signInWithFacebook() => _run(_repo.signInWithFacebook);

  Future<void> sendVerificationEmail() => _run(_repo.sendVerificationEmail);

  Future<void> sendPasswordReset(String email) =>
      _run(() => _repo.sendPasswordReset(email));

  Future<void> signOut() => _run(_repo.signOut);

  Future<void> changePhoto(Uint8List bytes) =>
      _run(() => _repo.updateProfilePhoto(bytes));
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

/// Visibilidad de contraseña (se reinicia al salir de la pantalla).
class ObscureNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

final obscurePasswordProvider =
    NotifierProvider.autoDispose<ObscureNotifier, bool>(ObscureNotifier.new);