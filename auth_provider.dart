import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// ─── Auth Service ─────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn(scopes: [
    'email',
    'profile',
    'https://www.googleapis.com/auth/calendar.readonly',
    'https://www.googleapis.com/auth/calendar.events',
  ]);
  final _db = FirebaseFirestore.instance;

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);

    // Create/update user doc in Firestore
    await _createOrUpdateUserDoc(userCred.user!);
    return userCred;
  }

  // Email/Password Sign-In
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _createOrUpdateUserDoc(userCred.user!);
    return userCred;
  }

  // Email/Password Sign-Up
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCred.user!.updateDisplayName(displayName);
    await _createOrUpdateUserDoc(userCred.user!);
    return userCred;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _createOrUpdateUserDoc(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();

    if (!snap.exists) {
      // Generate a unique share code for new users
      final code = _generateShareCode(user.uid);
      await ref.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? user.email?.split('@').first,
        'photoURL': user.photoURL,
        'shareCode': code,
        'partnerUid': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update({
        'email': user.email,
        'displayName': user.displayName ?? user.email?.split('@').first,
        'photoURL': user.photoURL,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }
  }

  String _generateShareCode(String uid) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final hash = uid.hashCode.abs();
    final p1 = String.fromCharCodes([
      chars.codeUnitAt(hash % chars.length),
      chars.codeUnitAt((hash ~/ 32) % chars.length),
    ]);
    final p2 = String.fromCharCodes([
      chars.codeUnitAt((hash ~/ 1024) % chars.length),
      chars.codeUnitAt((hash ~/ 32768) % chars.length),
      chars.codeUnitAt((hash ~/ 1048576) % chars.length),
      chars.codeUnitAt((hash ~/ 33554432) % chars.length),
    ]);
    return '$p1-$p2';
  }
}

// ─── User Profile Provider ────────────────────────────────────────────────────

final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snap) => snap.data());
});
