import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Sign in with Google
  Future<String?> signInWithGoogle() async {
    try {
      print("🚀 Starting Google sign in process...");
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print("❌ Google sign in was cancelled by user");
        return "Sign in cancelled";
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          // Create new user document if it doesn't exist
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName,
            'email': user.email,
            'uid': user.uid,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        
        print("✅ Google sign in successful");
        return null;
      } else {
        print("❌ Failed to get user from Google sign in");
        return "Failed to get user information";
      }
    } catch (e) {
      print("🔥 Error during Google sign in: $e");
      if (e is FirebaseAuthException) {
        return "Authentication error: ${e.message}";
      }
      return "Unexpected error: $e";
    }
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
