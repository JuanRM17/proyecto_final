import 'package:firebase_auth/firebase_auth.dart';

/// Vista inmutable del usuario. Al tener igualdad por valor, Riverpod
/// notifica solo cuando algo cambia de verdad (foto, verificación, etc.).
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.emailVerified,
    required this.usesPassword,
    required this.providerId,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final bool usesPassword;
  final String providerId;

  factory AppUser.fromFirebase(User u) {
    return AppUser(
      uid: u.uid,
      email: u.email,
      displayName: u.displayName,
      photoUrl: u.photoURL,
      emailVerified: u.emailVerified,
      usesPassword: u.providerData.any((p) => p.providerId == 'password'),
      providerId:
          u.providerData.isNotEmpty ? u.providerData.first.providerId : 'password',
    );
  }

  /// Las cuentas de correo deben verificar; Google/Facebook entran directo.
  bool get canAccess => emailVerified || !usesPassword;

  String get name {
    final n = displayName?.trim();
    if (n != null && n.isNotEmpty) return n;
    return email ?? 'Usuario';
  }

  String get providerLabel => switch (providerId) {
        'google.com' => 'Google',
        'facebook.com' => 'Facebook',
        _ => 'Correo y contraseña',
      };

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.uid == uid &&
      other.email == email &&
      other.displayName == displayName &&
      other.photoUrl == photoUrl &&
      other.emailVerified == emailVerified &&
      other.usesPassword == usesPassword &&
      other.providerId == providerId;

  @override
  int get hashCode => Object.hash(
        uid, email, displayName, photoUrl, emailVerified, usesPassword, providerId,
      );
}