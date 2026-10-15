// NOTE: Native FirebaseAuth SDK is not in pubspec.yaml because the app uses pure
// REST APIs in lib/data/firebase_rest_service.dart.
// If you configure native Firebase Auth in the future, uncomment the code below and
// add firebase_auth and cloud_firestore to pubspec.yaml.
/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'auth_service.dart';

/// Firebase-backed auth: accounts survive uninstalls/reinstalls.
/// Replaces LocalAuthService for production.
class FirebaseAuthService implements AuthService {
  FirebaseRestService();

  fb.FirebaseAuth get _auth => fb.FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final error = AuthValidator.validateRegister(
        name: name, email: email, password: password);
    if (error != null) return AuthResult.failure(error);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final profile = AuthProfile(name: name.trim(), email: email.trim());
      await cred.user?.updateDisplayName(profile.name);
      // Store profile in Firestore
      await _db.collection('users').doc(cred.user!.uid).set({
        ...profile.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return AuthResult.success(profile);
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(_friendlyError(e));
    } catch (e) {
      return AuthResult.failure('Registration failed. Please try again.');
    }
  }

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final error = AuthValidator.validateLogin(email: email, password: password);
    if (error != null) return AuthResult.failure(error);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Load profile from Firestore, fallback to Auth display name
      String name = cred.user?.displayName ?? '';
      String emailAddr = cred.user?.email ?? email.trim();
      try {
        final doc =
            await _db.collection('users').doc(cred.user!.uid).get();
        if (doc.exists) {
          final data = doc.data()!;
          name = (data['name'] ?? name).toString();
          emailAddr = (data['email'] ?? emailAddr).toString();
        }
      } catch (_) {}
      return AuthResult.success(
          AuthProfile(name: name, email: emailAddr));
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(_friendlyError(e));
    } catch (e) {
      return AuthResult.failure('Login failed. Please try again.');
    }
  }

  @override
  Future<AuthProfile?> currentProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    String name = user.displayName ?? '';
    String email = user.email ?? '';
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        name = (data['name'] ?? name).toString();
        email = (data['email'] ?? email).toString();
      }
    } catch (_) {}
    if (email.isEmpty) return null;
    return AuthProfile(name: name, email: email);
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  String _friendlyError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please log in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
*/
