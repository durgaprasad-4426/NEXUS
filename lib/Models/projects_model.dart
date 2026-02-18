class ProjectsModel {
  final String projectId;
  final String projectName;
  final String difficulty;
  String decription;
  final String steps;
  String codes;
  final String onTopic;
  final String codeLang;

  ProjectsModel({
    required this.projectId,
    required this.projectName,
    required this.difficulty,
    required this.decription,
    required this.steps,
    required this.codes,
    required this.onTopic,
    required this.codeLang
  });

factory ProjectsModel.fromMap(Map<String, dynamic> map){
  return ProjectsModel(
  projectId: map['projectId'] ?? '', 
  projectName: map['projectName'] ?? '', 
  difficulty: map['difficulty'] ?? '', 
  decription: map['decription'] ?? '', 
  steps: map['steps'] ?? '', 
  codes: map['codes'] ?? '', 
  onTopic: map['onTopic'] ?? '',
  codeLang: map['codeLang'] ?? ''
  );
}

Map<String, dynamic> toMap(){
  return{
    'projectId':projectId,
    'projectName':projectName,
    'difficulty':difficulty,
    'decription':decription,
    'steps':steps,
    'codes':codes,
    'onTopic':onTopic,
    'codeLang':codeLang
  };
}


 
}