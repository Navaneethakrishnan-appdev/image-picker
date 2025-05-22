import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      print("🚀 Starting signup process...");
      
      // Create user
      print("👤 Creating user account...");
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      print("✅ User account created with UID: $uid");

      // Save to Firestore
      print("📝 Saving user data to Firestore...");
      try {
        await _firestore.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'uid': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("✅ User data saved to Firestore successfully.");
        return null; // Success
      } catch (firestoreError) {
        print("❌ Firestore error: $firestoreError");
        return "Failed to save user data: $firestoreError";
      }
    } catch (e) {
      print("🔥 Error during signup: $e");
      if (e is FirebaseAuthException) {
        return "Authentication error: ${e.message}";
      } else if (e is FirebaseException) {
        return "Firebase error: ${e.message}";
      }
      return "Unexpected error: $e";
    }
  }

  // Sign In with Email and Password
  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      print("🚀 Starting sign in process...");
      
      // Sign in user
      print("👤 Signing in user...");
      UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      print("✅ User signed in successfully with UID: $uid");

      // Get user data from Firestore
      print("📝 Fetching user data from Firestore...");
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (userDoc.exists) {
        print("✅ User data retrieved successfully");
        return null; // Success
      } else {
        print("❌ User data not found in Firestore");
        return "User data not found";
      }
    } catch (e) {
      print("🔥 Error during sign in: $e");
      if (e is FirebaseAuthException) {
        return "Authentication error: ${e.message}";
      } else if (e is FirebaseException) {
        return "Firebase error: ${e.message}";
      }
      return "Unexpected error: $e";
    }
  }

  // Forgot Password
  Future<String?> forgotPassword(String email) async {
    try {
      print("🚀 Starting password reset process...");
      await _auth.sendPasswordResetEmail(email: email);
      print("✅ Password reset email sent successfully");
      return null; // Success
    } catch (e) {
      print("🔥 Error during password reset: $e");
      if (e is FirebaseAuthException) {
        return "Authentication error: ${e.message}";
      }
      return "Unexpected error: $e";
    }
  }
}
