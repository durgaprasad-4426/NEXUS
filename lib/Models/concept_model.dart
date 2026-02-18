import 'package:nexus/Models/concept_progress_model.dart';

class TopicsData {
  final String id;
  final String topicName;
  final String description;
  final String content;
  final String algorithm;
  final List<String> problems;
  final String difficulty;
  final String estimatedtime;
  final int progress;
  final bool isCompleted;
  final List<int> levelThresholds = [
    0,
    100,
    200,
    800,
    1400,
    2200,
    3200,
    4200,
    5400,
    10000
  ];

  TopicsData({
    required this.id,
    required this.topicName,
    required this.description,
    required this.content,
    required this.algorithm,
    required this.problems,
    required this.difficulty,
    required this.estimatedtime,
    required this.progress,
    required this.isCompleted,
  });

  factory TopicsData.fromMap(Map<String, dynamic> map, String id) {
    List<String> safeProblems = <String>[];
    if (map.containsKey("problems") && map["problems"] != null) {
      try {
        safeProblems = List<String>.from(map["problems"] as List<dynamic>);
      } catch (e) {
        safeProblems = <String>[];
      }
    }

    return TopicsData(
      id: id,
      topicName: (map["topicName"] as String?) ?? "",
      description: (map["description"] as String?) ?? "",
      content: (map["content"] as String?) ?? "",
      algorithm: (map["algorithm"] as String?) ?? "",
      problems: safeProblems,
      difficulty: (map["difficulty"] as String?) ?? "",
      estimatedtime: (map["estimatedtime"] as String?) ?? "",
      progress: (map["progress"] is num) ? (map["progress"] as num).toInt() : 0,
      isCompleted: (map["isCompleted"] is bool) ? map["isCompleted"] as bool : false,
    );
  }


  int get totalSteps {
    int steps = 0;
    if (content.trim().isNotEmpty) steps++;
    steps += problems.length;
    return steps;
  }


  double get progressPercent {
    if (totalSteps == 0) return 0.0;
    return progress / totalSteps;
  }

  int calculateLevel(int points){
   for(int i = levelThresholds.length-1; i>=0; i--){
    if(points >= levelThresholds[i]){
      return i+1;
    }
   }

   return 1;
  }

  int nextLevelPoints(int level){
    if(level >= levelThresholds.length){
      return levelThresholds.last;
    }
    return levelThresholds[level];
  }

  Map<String, dynamic> toMap() {
    return {
      "topicName": topicName,
      "description": description,
      "content": content,
      "algorithm": algorithm,
      "problems": problems,
      "difficulty": difficulty,
      "estimatedtime": estimatedtime,
      "progress": progress,
      "isCompleted": isCompleted,
    };
  }
}

class UserConceptView{
  final TopicsData concept;
  final ConceptProgress progress;

  UserConceptView({
    required this.concept,
    required this.progress
  });

  double get progressPercent{
    if(concept.totalSteps == 0) return 0.0;
    return progress.progress/concept.totalSteps;
  }
}