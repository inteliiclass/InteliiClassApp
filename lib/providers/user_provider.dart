import 'package:flutter/material.dart';
import 'package:inteliiclass/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch current user from Firestore

  Future<void> fetchCurrentUser(String uid, {String? expectedRole}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var query = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .get();

      if (query.docs.isNotEmpty) {
        _currentUser = UserModel.fromMap(query.docs.single.data());
      } else {
        _currentUser = null;
        _errorMessage = 'User not found';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
          results.add(UserModel.fromMap(doc.data()));
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    return results;
  }
}
