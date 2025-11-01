class Reservation {
  final String id;
  final String professorName;
  final String? room;
  final String? equipment;
  final DateTime date;
  final String? period;

  Reservation({
    required this.id,
    required this.professorName,
    this.room,
    this.equipment,
    required this.date,
    this.period,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professorName': professorName,
      'room': room,
      'equipment': equipment,
      'date': date.toIso8601String(),
      'period': period,
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      professorName: json['professorName'],
      room: json['room'],
      equipment: json['equipment'],
      date: DateTime.parse(json['date']),
      period: json['period'],
    );
  }
}
