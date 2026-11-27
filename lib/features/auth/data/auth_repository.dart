import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/firebase_config.dart';

/// El usuario cerró la ventana de Google/Facebook: no es un error a mostrar.
class AuthCancelledException implements Exception {}

/// Google/Facebook solo en móvil (el login social no soporta Windows).
bool get supportsSocialLogin =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'El correo no es válido.';
      case 'user-disabled':
        return 'Esta cuenta fue deshabilitada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese correo.';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres).';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos.';
      case 'network-request-failed':
        return 'Sin conexión a internet.';
      case 'account-exists-with-different-credential':
        return 'Ese correo ya está registrado con otro método de acceso.';
      default:
        return error.message ?? 'Error de autenticación.';
    }
  }
  return 'Ocurrió un error inesperado. Intenta de nuevo.';
}

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseStorage? storage})
      : _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  Future<void>? _googleInit;

  Stream<User?> get userChanges => _auth.userChanges();
  User? get currentUser => _auth.currentUser;

  // ── Correo y contraseña ──────────────────────────────────────────
  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.updateDisplayName(name.trim());
    await cred.user?.sendEmailVerification();
  }

  Future<void> loginWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Recarga el usuario para detectar si ya verificó el correo.
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
    final user = _auth.currentUser;
    if (user != null && user.emailVerified) {
      await user.getIdToken(true);
    }
  }

  // ── Google ───────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    _googleInit ??= GoogleSignIn.instance.initialize();
    await _googleInit;
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthCancelledException();
      }
      rethrow;
    }
  }

  // ── Facebook ─────────────────────────────────────────────────────
  Future<void> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );
    switch (result.status) {
      case LoginStatus.success:
        final token = result.accessToken!.tokenString;
        await _auth.signInWithCredential(FacebookAuthProvider.credential(token));
      case LoginStatus.cancelled:
        throw AuthCancelledException();
      default:
        throw FirebaseAuthException(
          code: 'facebook-failed',
          message: result.message ?? 'No se pudo iniciar sesión con Facebook.',
        );
    }
  }

  // ── Sesión y perfil ──────────────────────────────────────────────
  Future<void> signOut() async {
    await _safe(() async {
      if (_googleInit != null) await GoogleSignIn.instance.signOut();
    });
    await _safe(() => FacebookAuth.instance.logOut());
    await _auth.signOut();
  }

  Future<void> _safe(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }

  /// Sube la foto a Storage y la asigna al perfil. Con nombre único por
  /// subida para que la caché de imágenes no muestre la foto anterior.
    Future<void> updateProfilePhoto(Uint8List bytes) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('No hay sesión activa');

    final url = kUseFirebaseStorage
        ? await _uploadToFirebaseStorage(user.uid, bytes)
        : await _uploadToCloudinary(bytes);

    await user.updatePhotoURL(url);
    await user.reload();
  }

  Future<String> _uploadToFirebaseStorage(String uid, Uint8List bytes) async {
    final ref = _storage.ref(
      'users/$uid/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<String> _uploadToCloudinary(Uint8List bytes) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$kCloudinaryCloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = kCloudinaryUploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: 'avatar.jpg'),
      );

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200) {
      throw Exception('Error al subir la imagen (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['secure_url'] as String;
  }
}