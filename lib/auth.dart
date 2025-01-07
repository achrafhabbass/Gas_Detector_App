import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Add user to Firestore
    await _firestore.collection('users').doc(email).set({
      'email': email,
      'password': password, // Note: Avoid storing passwords in Firestore in production
    });
  }

  Future<void> deleteUser(String email) async {
    await _firestore.collection('users').doc(email).delete();
  }

  Future<void> updateUser(String oldEmail, String newEmail, String newPassword) async {
    await _firestore.collection('users').doc(oldEmail).update({
      'email': newEmail,
      'password': newPassword,
    });
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}