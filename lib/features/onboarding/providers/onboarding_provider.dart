import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/preferences_provider.dart';

/// Si el usuario ya vio el onboarding (persistido).
class OnboardingSeenNotifier extends Notifier<bool> {
  static const _key = 'onboarding_seen';

  @override
  bool build() => ref.read(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> complete() async {
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
    state = true;
  }
}

final onboardingSeenProvider =
    NotifierProvider<OnboardingSeenNotifier, bool>(OnboardingSeenNotifier.new);

/// Página actual del carrusel (se reinicia al salir de la pantalla).
class OnboardingPageNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

final onboardingPageProvider =
    NotifierProvider.autoDispose<OnboardingPageNotifier, int>(
  OnboardingPageNotifier.new,
);