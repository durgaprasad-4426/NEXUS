import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nexus/Models/concept_progress_model.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  String? photoUrl;
  int level;
  int points;
  int streak; 
  DateTime? lastLogin;
  final DateTime createdAt;
  List<String> badges;
  Map<String, dynamic> stats;
  Map<String, dynamic> lastActivity; 
  Map<String, bool> streakMap;
  List<String> completedTopics;
  Map<String, bool> dailyChallenges;
  Map<String, ConceptProgress> conceptProgress;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.level = 0,
    this.points = 0,
    this.streak = 0,
    this.lastLogin,
    required this.createdAt,
    this.stats = const {},
    this.badges = const [],
    Map<String, dynamic>? lastActivity,
    this.streakMap = const {},
    this.completedTopics = const [],
    this.dailyChallenges = const {},
    this.conceptProgress = const {},
  }) : lastActivity = lastActivity ?? {};


  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'level': level,
      'points': points,
      'streak': streak,
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'badges': badges,
      'stats': stats,
      'lastActivity': lastActivity,
      'streakMap': streakMap, // ✅ Save streak map
      'completedTopics': completedTopics,
      'dailyChallenges': dailyChallenges,
      'conceptProgress':
          conceptProgress.map((k, v) => MapEntry(k, v.toMap())),
    };
  }


  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      level: (map['level'] ?? 0) is int
          ? map['level']
          : int.tryParse(map['level'].toString()) ?? 0,
      points: (map['points'] ?? 0) is int
          ? map['points']
          : int.tryParse(map['points'].toString()) ?? 0,
      streak: (map['streak'] ?? 0) is int
          ? map['streak']
          : int.tryParse(map['streak'].toString()) ?? 0,
      lastLogin: map['lastLogin'] is Timestamp
          ? (map['lastLogin'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      badges: map['badges'] != null ? List<String>.from(map['badges']) : [],
      stats: map['stats'] != null
          ? Map<String, dynamic>.from(map['stats'])
          : {},
      lastActivity: map['lastActivity'] != null
          ? Map<String, dynamic>.from(map['lastActivity'])
          : {},
      streakMap: map['streakMap'] != null
          ? Map<String, bool>.from(map['streakMap'])
          : {},
      completedTopics: map['completedTopics'] != null
          ? List<String>.from(map['completedTopics'])
          : [],
      dailyChallenges: map['dailyChallenges'] != null
          ? Map<String, bool>.from(map['dailyChallenges'])
          : {},
      conceptProgress: map['conceptProgress'] != null
          ? (map['conceptProgress'] as Map<String, dynamic>)
              .map((key, value) =>
                  MapEntry(key, ConceptProgress.fromMap(value)))
          : {},
    );
  }

  String toJson() => jsonEncode(toMap());
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(jsonDecode(source));

  // -----------------------------
  // CopyWith
  // -----------------------------
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    int? level,
    int? points,
    int? streak,
    DateTime? createdAt,
    DateTime? lastLogin,
    List<String>? badges,
    Map<String, dynamic>? stats,
    Map<String, dynamic>? lastActivity,
    Map<String, bool>? streakMap,
    List<String>? completedTopics,
    Map<String, bool>? dailyChallenges,
    Map<String, ConceptProgress>? conceptProgress,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      level: level ?? this.level,
      points: points ?? this.points,
      streak: streak ?? this.streak,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      badges: badges ?? this.badges,
      stats: stats ?? this.stats,
      lastActivity: lastActivity ?? this.lastActivity,
      streakMap: streakMap ?? this.streakMap,
      completedTopics: completedTopics ?? this.completedTopics,
      dailyChallenges: dailyChallenges ?? this.dailyChallenges,
      conceptProgress: conceptProgress ?? this.conceptProgress,
    );
  }
}


// Progress & Streak Handling

extension UserProgress on UserModel {
 
  void completeConcept({
    required String conceptId,
    required int pointsEarned,
  }) {
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

   
    streakMap[todayStr] = true;

    final allDates = streakMap.keys.toList()..sort();
    int newStreak = 0;
    DateTime? prev;
    for (final dateStr in allDates) {
      DateTime d = DateTime.parse(dateStr);
      if (prev == null) {
        newStreak = 1;
      } else if (d.difference(prev).inDays == 1) {
        newStreak++;
      }
      prev = d;
    }
    streak = newStreak;

    points += pointsEarned;
    level = (points / 100).floor();

   
    if (!completedTopics.contains(conceptId)) {
      completedTopics.add(conceptId);
    }

   
    stats[conceptId] = (stats[conceptId] ?? 0) + 1;
    conceptProgress[conceptId] = ConceptProgress(progress: 1, isCompleted: true);

   
    lastActivity = {
      "conceptId": conceptId,
      "date": DateTime.now().toIso8601String(),
      "progress": 1,
    };
  }


  void completeDailyChallenge(String challengeId) {
    dailyChallenges[challengeId] = true;
  }
}
