class Reservation {
  final String id;
  final String userId;
  final String professorName;
  final String room;
  final String equipment;
  final DateTime date;
  final String period;

  Reservation({
    required this.id,
    required this.userId,
    required this.professorName,
    required this.room,
    required this.equipment,
    required this.date,
    required this.period,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'professorName': professorName,
      'room': room,
      'equipment': equipment,
      'date': date.toIso8601String(),
      'period': period,
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      professorName: json['professorName'] as String,
      room: json['room'] as String? ?? '',
      equipment: json['equipment'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      period: json['period'] as String? ?? '',
    );
  }
}
