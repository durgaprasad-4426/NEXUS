import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Models/badge_model.dart';

class BadgesProvider with ChangeNotifier {
  List<BadgeModel> allBadges = [];

  Future<void> fetchBadges() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection("badges").get();
      allBadges = snapshot.docs
          .map((doc) => BadgeModel.fromMap(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching badges: $e");
    }
  }

  BadgeModel? getBadgeById(String id) {
    return allBadges.firstWhere((badge) => badge.id == id, orElse: () => BadgeModel(id: '', name: '', colorValue: 0xFFFFFFFF, type: 'topic'));
  }

  Future<List<String>> checkAndAwardTopicBadges(List<String> completedTopics, List<String>? userBadges, String uid) async {
    userBadges ??= [];

    List<String> newBadges = [];


    Map<int, String> topicBadgeMap = {
      1: "B0001",
      3: "B0002",
      5: "B0003",
      15: "B0004",
      20: "B0005",
    };

    for (var threshold in topicBadgeMap.keys) {
      if (completedTopics.length >= threshold) {
        String badgeId = topicBadgeMap[threshold]!;
        if (!userBadges.contains(badgeId)) {
          userBadges.add(badgeId);
          newBadges.add(badgeId);
        }
      }
    }

    // Update user badges in Firestore
    if (newBadges.isNotEmpty) {
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "badges": userBadges,
      }, SetOptions(merge: true));
      notifyListeners();
    }

    return newBadges;
  }
}
