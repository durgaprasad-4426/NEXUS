import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexus/Models/concept_progress_model.dart';
import '../Models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  UserModel? get user => _user;

  String? _uid;
  String? get uid => _uid;

  Map<String, ConceptProgress> _conceptProgress = {};
  Map<String, ConceptProgress> get conceptProgress => _conceptProgress;

  StreamSubscription? _progressSub;

  
  Future<void> setUserId(String uid) async {
    _uid = uid;
    await loadUser(uid);
    _listenToProgress(uid);
  }


  Future<void> loadUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      _user = UserModel.fromMap(doc.data()!);
      _conceptProgress = _user!.conceptProgress;
    }
    notifyListeners();
  }

 
  void _listenToProgress(String uid) {
    _progressSub?.cancel(); 
    _progressSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('conceptProgress')
        .snapshots()
        .listen((snapshot) {
      final Map<String, ConceptProgress> map = {
        for (var doc in snapshot.docs)
          doc.id: ConceptProgress.fromMap(doc.data())
      };
      _conceptProgress = map;

   
      if (_user != null) {
        _user!.conceptProgress = map;
      }

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _progressSub?.cancel();
    super.dispose();
  }

 
  Future<void> updateUser(UserModel updatedUser) async {
    _user = updatedUser;
    _conceptProgress = updatedUser.conceptProgress;
    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(updatedUser.uid)
          .set(updatedUser.toMap());
    } catch (e) {
      debugPrint("Error updating user: $e");
    }
  }


  Future<void> completeConcept(String conceptId, int pointsEarned) async {
    if (_user == null) return;

    _user!.completeConcept(conceptId: conceptId, pointsEarned: pointsEarned);

    await _firestore.collection('users').doc(_user!.uid).update({
      'points': _user!.points,
      'level': _user!.level,
      'streak': _user!.streak,
      'lastActivity': _user!.lastActivity,
      'completedTopics': _user!.completedTopics,
      'conceptProgress':
          _user!.conceptProgress.map((k, v) => MapEntry(k, v.toMap())),
    });

   
    _conceptProgress[conceptId] =
        _user!.conceptProgress[conceptId] ?? ConceptProgress(progress: 1, isCompleted: true);

    notifyListeners(); 
  }
}
