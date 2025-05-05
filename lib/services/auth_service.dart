import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:water_delivery_app/models/app_user.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Create user object from Firebase User
  AppUser? _userFromFirebaseUser(User? user) {
    if (user == null) {
      print('Firebase user is null');
      return null;
    }
    
    print('Creating AppUser from Firebase user: ${user.uid}');
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      role: 'staff', // Default role
    );
  }
  
  // Auth change user stream
  Stream<AppUser?> get user {
    print('Getting auth state stream');
    return _auth.authStateChanges().map((User? user) {
      print('Auth state changed: ${user?.uid}');
      return _userFromFirebaseUser(user);
    });
  }
  
  // Sign in with email & password
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('Attempting to sign in with email: $email');
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      User? user = result.user;
      print('Sign in successful for user: ${user?.uid}');
      
      // Get additional user data from Firestore
      if (user != null) {
        print('Fetching additional user data from Firestore');
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          print('User document exists in Firestore');
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          return AppUser(
            uid: user.uid,
            email: user.email ?? '',
            name: userData['name'] ?? '',
            role: userData['role'] ?? 'staff',
          );
        } else {
          print('User document does not exist in Firestore, creating one');
          // User exists in Auth but not in Firestore
          // Create a new document for them
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName ?? email.split('@')[0],
            'email': email,
            'role': 'staff',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      return _userFromFirebaseUser(user);
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }
  
  // Register with email & password
  Future<AppUser?> registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      print('Attempting to register with email: $email');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      User? user = result.user;
      print('Registration successful for user: ${user?.uid}');
      
      // Create a new document for the user with uid
      if (user != null) {
        print('Creating user document in Firestore');
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'role': 'staff',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Update display name
        print('Updating display name');
        await user.updateDisplayName(name);
      }
      
      return _userFromFirebaseUser(user);
    } catch (e) {
      print('Error registering: $e');
      return null;
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      print('Signing out');
      await _auth.signOut();
      notifyListeners();
      print('Signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}