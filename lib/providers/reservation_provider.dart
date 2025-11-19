import 'package:flutter/material.dart';
import 'package:my_reservation_app/models/reservation.dart';
import 'package:my_reservation_app/models/user.dart';
import 'package:my_reservation_app/services/auth_service.dart';
import 'package:my_reservation_app/services/reservation_service.dart';

class ReservationProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ReservationService _reservationService = ReservationService();

  List<Reservation> _reservations = [];
  User? _currentUser;
  bool _isLoading = false;

  List<Reservation> get reservations => _reservations;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  int get reservationCount =>
      _reservations.where((r) => r.userId == _currentUser?.id).length;

  // Initialize - load user and reservations
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _authService.getCurrentUser();
    await loadReservations();

    _isLoading = false;
    notifyListeners();
  }

  // Load all reservations
  Future<void> loadReservations() async {
    try {
      _reservations = await _reservationService.getAllReservations();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading reservations: $e');
    }
  }

  // Get user's reservations
  List<Reservation> getUserReservations() {
    if (_currentUser == null) return [];
    return _reservations.where((r) => r.userId == _currentUser!.id).toList();
  }

  // Add reservation
  Future<Map<String, dynamic>> addReservation({
    required String room,
    required String equipment,
    required DateTime date,
    required String period,
  }) async {
    if (_currentUser == null) {
      return {'success': false, 'message': 'Usuário não autenticado'};
    }

    final result = await _reservationService.createReservation(
      userId: _currentUser!.id,
      professorName: _currentUser!.name,
      room: room,
      equipment: equipment,
      date: date,
      period: period,
    );

    if (result['success'] == true) {
      await loadReservations();
    }

    return result;
  }

  // Remove reservation
  Future<Map<String, dynamic>> removeReservation(String id) async {
    if (_currentUser == null) {
      return {'success': false, 'message': 'Usuário não autenticado'};
    }

    final result = await _reservationService.deleteReservation(
      reservationId: id,
      userId: _currentUser!.id,
    );

    if (result['success'] == true) {
      await loadReservations();
    }

    return result;
  }

  // Set current user
  void setUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  // Update current user
  void updateCurrentUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _reservations = [];
    notifyListeners();
  }
}
