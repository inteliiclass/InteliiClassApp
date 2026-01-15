import 'package:flutter/material.dart';
import 'package:inteliiclass/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isInstructor => _currentUser?.role == 'instructor';
  bool get isStudent => _currentUser?.role == 'student';

  // Fetch current user from Firestore
  Future<void> fetchCurrentUser(String uid, {String? expectedRole}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Query by uid field, and optionally by role if provided
      Query query = FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid);

      if (expectedRole != null) {
        query = query.where('role', isEqualTo: expectedRole);
      }

      final result = await query.limit(1).get();

      if (result.docs.isNotEmpty) {
        _currentUser = UserModel.fromMap(
          result.docs.first.data() as Map<String, dynamic>,
        );
      } else {
        _errorMessage = 'User not found in database';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<void> loginUser(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await fetchCurrentUser(credential.user!.uid);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Auto-login on app start if user is already authenticated
  Future<void> autoLoginUser() async {
    final currentAuthUser = FirebaseAuth.instance.currentUser;
    if (currentAuthUser != null) {
      await fetchCurrentUser(currentAuthUser.uid);
    }
  }

  // Register user
  Future<void> registerUser(UserModel user, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: user.email,
            password: password,
          );

      if (credential.user != null) {
        final newUser = UserModel(
          uid: credential.user!.uid,
          email: user.email,
          name: user.name,
          role: user.role,
          phoneNumber: user.phoneNumber,
          profileImageUrl: user.profileImageUrl,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.uid)
            .set(newUser.toMap());

        _currentUser = newUser;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(user.toMap());

      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    await FirebaseAuth.instance.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Clear user data
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  // Fetch multiple users by their UIDs. Handles batching when list > 10.
  Future<List<UserModel>> fetchUsersByIds(List<String> uids) async {
    final List<UserModel> results = [];
    if (uids.isEmpty) return results;

    try {
      // Firestore whereIn supports up to 10 items per query
      const batchSize = 10;
      for (var i = 0; i < uids.length; i += batchSize) {
        final end = (i + batchSize < uids.length) ? i + batchSize : uids.length;
        final batch = uids.sublist(i, end);
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', whereIn: batch)
            .get();

        for (final doc in snapshot.docs) {
          results.add(UserModel.fromMap(doc.data() as Map<String, dynamic>));
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    return results;
  }
}
