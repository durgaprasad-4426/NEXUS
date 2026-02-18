import 'package:cloud_firestore/cloud_firestore.dart';

class ConceptProgress {
  final int   progress;
  final bool isCompleted;
  final DateTime? lastAccessed;
  final DateTime?  completedAt;

  ConceptProgress({
    this.progress = 0,
    this.isCompleted = false,
    this.lastAccessed,
    this.completedAt,
  });

  factory ConceptProgress.fromMap(Map<String, dynamic>? map) {
    if (map == null) return ConceptProgress();
    return ConceptProgress(
      progress: (map['progress'] ?? 0) is int
          ? map['progress']
          : int.tryParse(map['progress'].toString()) ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      lastAccessed: map['lastAccessed'] is Timestamp
          ? (map['lastAccessed'] as Timestamp).toDate()
          : null,
      completedAt: map['completedAt'] is Timestamp
          ? (map['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "progress": progress,
      "isCompleted": isCompleted,
      "lastAccessed":
          lastAccessed != null ? Timestamp.fromDate(lastAccessed!) : null,
      "completedAt":
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }
}
