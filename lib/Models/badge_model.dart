

class BadgeModel {
  final String id; 
  final String name;
  final int colorValue; 
  final String type; 

  BadgeModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.type,
  });

  factory BadgeModel.fromMap(Map<String, dynamic> map) {
    return BadgeModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      colorValue: map['colorValue'] ?? 0xFFFFFFFF,
      type: map['type'] ?? 'topic',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'type': type,
    };
  }
}
