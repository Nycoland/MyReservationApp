import 'package:flutter/material.dart';
import 'package:my_reservation_app/models/reservation.dart';

class ReservationProvider extends ChangeNotifier {
  final List<Reservation> _reservations = [];

  List<Reservation> get reservations => _reservations;

  void addReservation(Reservation reservation) {
    _reservations.add(reservation);
    notifyListeners();
  }

  void removeReservation(String id) {
    _reservations.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  int get reservationCount => _reservations.length;
}
