import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:my_reservation_app/models/reservation.dart';
import 'package:my_reservation_app/providers/reservation_provider.dart';

class GeneralReservationsScreen extends StatefulWidget {
  const GeneralReservationsScreen({super.key});

  @override
  State<GeneralReservationsScreen> createState() => _GeneralReservationsScreenState();
}

class _GeneralReservationsScreenState extends State<GeneralReservationsScreen> {
  DateTime selectedDate = DateTime.now();
  final String currentUser = 'Prof. Brunna M.';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2962FF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  List<Reservation> _getReservationsForDate(List<Reservation> allReservations) {
    return allReservations.where((reservation) {
      return reservation.date.year == selectedDate.year &&
          reservation.date.month == selectedDate.month &&
          reservation.date.day == selectedDate.day;
    }).toList()
      ..sort((a, b) {
        // Sort by period/time
        return (a.period ?? '').compareTo(b.period ?? '');
      });
  }

  Widget _buildReservationCard(Reservation reservation) {
    final bool isMyReservation = reservation.professorName == currentUser;
    final Color indicatorColor = isMyReservation ? Colors.green : Colors.grey;
    final String statusText = isMyReservation ? 'Sua Reserva' : 'Ocupado';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left colored indicator
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Row(
                      children: [
                        Icon(
                          isMyReservation ? Icons.bookmark : Icons.meeting_room,
                          color: indicatorColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: indicatorColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Room/Location
                    Text(
                      reservation.room ?? 'Sala não especificada',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Professor name
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          reservation.professorName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    
                    // Equipment if applicable
                    if (reservation.equipment != 'Não se Aplica (Apenas Sala)') ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.computer, size: 16, color: Color(0xFFAB47BC)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Equipamento Anexo: ${reservation.equipment}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFAB47BC),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    
                    // Date and time
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd/MM/yyyy').format(reservation.date),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          reservation.period ?? 'Período não especificado',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2962FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.home, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Bem-vindo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Header section
          Container(
            color: const Color(0xFF2962FF),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Agenda Geral de Recursos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Visualização de todas as reservas de salas e equipamentos.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Date selector
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today, color: Color(0xFF2962FF), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down, color: Color(0xFF2962FF)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Reservations list
          Expanded(
            child: Consumer<ReservationProvider>(
              builder: (context, provider, child) {
                final reservations = _getReservationsForDate(provider.reservations);
                
                if (reservations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma reserva para esta data',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    return _buildReservationCard(reservations[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
