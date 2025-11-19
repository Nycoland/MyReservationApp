import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_reservation_app/models/reservation.dart';

class ReservationService {
  static const String _reservationsKey = 'reservations_database';

  // Singleton pattern
  static final ReservationService _instance = ReservationService._internal();
  factory ReservationService() => _instance;
  ReservationService._internal();

  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ============================================================================
  // CREATE RESERVATION
  // ============================================================================

  Future<Map<String, dynamic>> createReservation({
    required String userId,
    required String professorName,
    required String room,
    required String equipment,
    required DateTime date,
    required String period,
  }) async {
    await _initPrefs();

    try {
      // Validate inputs
      if (room.isEmpty || room == 'Selecione a Sala') {
        return {'success': false, 'message': 'Por favor, selecione uma sala'};
      }

      if (equipment.isEmpty || equipment == 'Selecione o Equipamento') {
        return {
          'success': false,
          'message': 'Por favor, selecione um equipamento',
        };
      }

      if (period.isEmpty || period == 'Selecione o Horário') {
        return {'success': false, 'message': 'Por favor, selecione um horário'};
      }

      // Check if date is in the past
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final reservationDate = DateTime(date.year, date.month, date.day);

      if (reservationDate.isBefore(today)) {
        return {
          'success': false,
          'message': 'Não é possível fazer reservas para datas passadas',
        };
      }

      // Check for conflicts
      final conflict = await _checkReservationConflict(
        room: room,
        date: date,
        period: period,
        excludeReservationId: null,
      );

      if (conflict != null) {
        return {
          'success': false,
          'message':
              'Esta sala já está reservada para este horário. Por favor, escolha outro horário ou sala.',
        };
      }

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Create new reservation
      final reservationId = 'res_${DateTime.now().millisecondsSinceEpoch}';

      final newReservation = Reservation(
        id: reservationId,
        userId: userId,
        professorName: professorName,
        room: room,
        equipment: equipment,
        date: date,
        period: period,
      );

      // Save reservation
      await _saveReservation(newReservation);

      return {
        'success': true,
        'message': 'Reserva criada com sucesso!',
        'reservation': newReservation,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao criar reserva. Tente novamente.',
      };
    }
  }

  // ============================================================================
  // DELETE RESERVATION
  // ============================================================================

  Future<Map<String, dynamic>> deleteReservation({
    required String reservationId,
    required String userId,
  }) async {
    await _initPrefs();

    try {
      // Get reservation
      final reservation = await _getReservationById(reservationId);

      if (reservation == null) {
        return {'success': false, 'message': 'Reserva não encontrada'};
      }

      // Check if user owns the reservation
      if (reservation.userId != userId) {
        return {
          'success': false,
          'message': 'Você não tem permissão para cancelar esta reserva',
        };
      }

      // Check if reservation can be cancelled (30 minutes before)
      final now = DateTime.now();
      final reservationDateTime = _getReservationDateTime(reservation);
      // Check if reservation has already started (can't cancel past reservations)
      // But allow cancellation of future reservations anytime for demo purposes
      if (now.isAfter(reservationDateTime)) {
        return {
          'success': false,
          'message': 'Não é possível cancelar reservas que já começaram.',
        };
      }

      // For demo: Allow cancellation with warning if less than 30 minutes
      final thirtyMinutesBefore = reservationDateTime.subtract(
        const Duration(minutes: 30),
      );

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Delete reservation
      await _deleteReservation(reservationId);

      // Show appropriate message based on timing
      if (now.isAfter(thirtyMinutesBefore)) {
        return {
          'success': true,
          'message':
              'Reserva cancelada! (Aviso: menos de 30 min de antecedência)',
        };
      }

      return {'success': true, 'message': 'Reserva cancelada com sucesso!'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao cancelar reserva. Tente novamente.',
      };
    }
  }

  // ============================================================================
  // GET USER RESERVATIONS
  // ============================================================================

  Future<List<Reservation>> getUserReservations(String userId) async {
    await _initPrefs();

    final allReservations = await _getAllReservations();
    return allReservations.where((r) => r.userId == userId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // ============================================================================
  // GET ALL RESERVATIONS
  // ============================================================================

  Future<List<Reservation>> getAllReservations() async {
    await _initPrefs();

    final allReservations = await _getAllReservations();
    return allReservations..sort((a, b) => a.date.compareTo(b.date));
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  Future<void> _saveReservation(Reservation reservation) async {
    final reservations = await _getReservationsMap();
    reservations[reservation.id] = reservation.toJson();

    final reservationsJson = jsonEncode(reservations);
    await _prefs!.setString(_reservationsKey, reservationsJson);
  }

  Future<void> _deleteReservation(String reservationId) async {
    final reservations = await _getReservationsMap();
    reservations.remove(reservationId);

    final reservationsJson = jsonEncode(reservations);
    await _prefs!.setString(_reservationsKey, reservationsJson);
  }

  Future<Map<String, dynamic>> _getReservationsMap() async {
    final reservationsJson = _prefs!.getString(_reservationsKey);
    if (reservationsJson == null) return {};

    return Map<String, dynamic>.from(jsonDecode(reservationsJson));
  }

  Future<List<Reservation>> _getAllReservations() async {
    final reservations = await _getReservationsMap();

    return reservations.values
        .map((data) => Reservation.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }

  Future<Reservation?> _getReservationById(String id) async {
    final reservations = await _getReservationsMap();
    final data = reservations[id];

    if (data == null) return null;

    return Reservation.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Reservation?> _checkReservationConflict({
    required String room,
    required DateTime date,
    required String period,
    String? excludeReservationId,
  }) async {
    final allReservations = await _getAllReservations();

    for (final reservation in allReservations) {
      // Skip the reservation we're updating (if any)
      if (excludeReservationId != null &&
          reservation.id == excludeReservationId) {
        continue;
      }

      // Check if same room, date, and period
      if (reservation.room == room &&
          _isSameDate(reservation.date, date) &&
          _isTimeConflict(reservation.period, period)) {
        return reservation;
      }
    }

    return null;
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isTimeConflict(String period1, String period2) {
    // If exactly the same period, it's a conflict
    if (period1 == period2) return true;

    // Check if one is a large block that encompasses the other
    if (period1 == 'Dia Inteiro' || period2 == 'Dia Inteiro') {
      return true;
    }

    // Check morning block (07:00 - 12:00)
    if (period1 == 'Manhã') {
      return period2 == 'Manhã' ||
          period2.startsWith('07:') ||
          period2.startsWith('08:') ||
          period2.startsWith('09:') ||
          period2.startsWith('10:') ||
          period2.startsWith('11:');
    }
    if (period2 == 'Manhã') {
      return period1 == 'Manhã' ||
          period1.startsWith('07:') ||
          period1.startsWith('08:') ||
          period1.startsWith('09:') ||
          period1.startsWith('10:') ||
          period1.startsWith('11:');
    }

    // Check afternoon block (12:00 - 18:00)
    if (period1 == 'Tarde') {
      return period2 == 'Tarde' ||
          period2.startsWith('12:') ||
          period2.startsWith('13:') ||
          period2.startsWith('14:') ||
          period2.startsWith('15:') ||
          period2.startsWith('16:') ||
          period2.startsWith('17:');
    }
    if (period2 == 'Tarde') {
      return period1 == 'Tarde' ||
          period1.startsWith('12:') ||
          period1.startsWith('13:') ||
          period1.startsWith('14:') ||
          period1.startsWith('15:') ||
          period1.startsWith('16:') ||
          period1.startsWith('17:');
    }

    // Check night block (18:00 - 22:00)
    if (period1 == 'Noite') {
      return period2 == 'Noite' ||
          period2.startsWith('18:') ||
          period2.startsWith('19:') ||
          period2.startsWith('20:') ||
          period2.startsWith('21:');
    }
    if (period2 == 'Noite') {
      return period1 == 'Noite' ||
          period1.startsWith('18:') ||
          period1.startsWith('19:') ||
          period1.startsWith('20:') ||
          period1.startsWith('21:');
    }

    // No conflict
    return false;
  }

  DateTime _getReservationDateTime(Reservation reservation) {
    // Extract hour from period (e.g., "07:00-08:00" -> 7)
    int hour = 7; // default

    final period = reservation.period;
    if (period.contains(':')) {
      final parts = period.split(':');
      if (parts.isNotEmpty) {
        hour = int.tryParse(parts[0]) ?? 7;
      }
    } else if (period == 'Manhã') {
      hour = 7;
    } else if (period == 'Tarde') {
      hour = 12;
    } else if (period == 'Noite') {
      hour = 18;
    } else if (period == 'Dia Inteiro') {
      hour = 7;
    }

    return DateTime(
      reservation.date.year,
      reservation.date.month,
      reservation.date.day,
      hour,
      0,
    );
  }

  // ============================================================================
  // CLEAR ALL DATA (for testing/demo reset)
  // ============================================================================

  Future<void> clearAllData() async {
    await _initPrefs();
    await _prefs!.remove(_reservationsKey);
  }
}
