class Hike {
  int? id;
  String name;
  String location;
  DateTime date;
  double length;
  String difficulty;
  bool parkingAvailable;
  String? description;
  int? groupSize;
  DateTime? createdAt;
  DateTime? updatedAt;

  Hike({
    this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.length,
    required this.difficulty,
    required this.parkingAvailable,
    this.description,
    this.groupSize,
    this.createdAt,
    this.updatedAt,
  });

  // Convert to/from Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'date': date.millisecondsSinceEpoch,
      'length': length,
      'difficulty': difficulty,
      'parkingAvailable': parkingAvailable ? 1 : 0,
      'description': description,
      'groupSize': groupSize,
      'createdAt': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Hike.fromMap(Map<String, dynamic> map) {
    return Hike(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      length: map['length'],
      difficulty: map['difficulty'],
      parkingAvailable: map['parkingAvailable'] == 1,
      description: map['description'],
      groupSize: map['groupSize'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
}
