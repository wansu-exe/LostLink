import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// The currently signed-in user, or null if logged out.
  User? get currentUser => _auth.currentUser;

  /// Stream that emits whenever auth state changes (login / logout).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register with email & password, then write a user document to Firestore.
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update display name on the Auth profile
    await cred.user!.updateDisplayName(name);

    // Create the /users/{uid} document with role = 'user'
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'role': 'user', // 'admin' set manually in Firestore console
      'createdAt': FieldValue.serverTimestamp(),
    });

    return cred;
  }

  /// Sign in with email & password.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out.
  Future<void> signOut() async => _auth.signOut();

  /// Send a password-reset email.
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Fetch the user's Firestore document (includes their role).
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  /// True if the signed-in user has the 'admin' role in Firestore.
  Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    final data = await getUserData(currentUser!.uid);
    return data?['role'] == 'admin';
  }
}
