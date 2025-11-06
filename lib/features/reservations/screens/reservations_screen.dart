import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:my_reservation_app/models/reservation.dart';
import 'package:my_reservation_app/providers/reservation_provider.dart';
import 'package:my_reservation_app/widgets/custom_dropdown.dart';

class ReservationsScreen extends StatefulWidget {
  final int initialTab;

  const ReservationsScreen({super.key, this.initialTab = 0});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showSuccessBanner = false;

  // New Reservation Form State
  String? selectedRoom;
  String? selectedEquipment;
  DateTime selectedDate = DateTime.now();
  String? selectedPeriod;

  final List<String> rooms = [
    'Laboratório 1',
    'Laboratório 2',
    'Auditório Principal',
    'Sala de Reuniões',
    'Biblioteca',
  ];

  final List<String> equipment = [
    'Não se Aplica (Apenas Sala)',
    'Projetor',
    'Notebook',
    'Caixa de Som',
    'Microfone',
  ];

  final List<String> periods = [
    '07:00 - 08:00',
    '08:00 - 09:00',
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
    '18:00 - 19:00',
    '19:00 - 20:00',
    '20:00 - 21:00',
    '21:00 - 22:00',
    'Manhã (08:00 - 12:00)',
    'Tarde (13:00 - 17:00)',
    'Noite (18:00 - 22:00)',
    'Dia Inteiro',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
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

  void _makeReservation() {
    if (selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione uma sala'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um período'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create reservation object
    final reservation = Reservation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      professorName: 'Prof. Brunna M.',
      room: selectedRoom,
      equipment: selectedEquipment,
      date: selectedDate,
      period: selectedPeriod,
    );

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFFE8F5E9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Reserva efetuada!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  selectedRoom ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '(${_formatPeriod(selectedPeriod)})',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2E7D32),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add reservation to provider
                      Provider.of<ReservationProvider>(
                        context,
                        listen: false,
                      ).addReservation(reservation);

                      Navigator.pop(context); // Close dialog

                      // Switch to My Reservations tab and show banner
                      _tabController.animateTo(1);
                      setState(() {
                        _showSuccessBanner = true;
                      });

                      // Hide banner after 3 seconds
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) {
                          setState(() {
                            _showSuccessBanner = false;
                          });
                        }
                      });

                      // Reset form
                      setState(() {
                        selectedRoom = null;
                        selectedEquipment = null;
                        selectedDate = DateTime.now();
                        selectedPeriod = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _cancelReservation(Reservation reservation) {
    // Check if cancellation is within 30 minutes of the start time
    final canCancel = _canCancelReservation(reservation);

    if (!canCancel) {
      _showRestrictedCancellationDialog();
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancelar Reserva'),
            content: const Text(
              'Tem certeza que deseja cancelar esta reserva?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Não'),
              ),
              TextButton(
                onPressed: () {
                  // Remove from provider
                  Provider.of<ReservationProvider>(
                    context,
                    listen: false,
                  ).removeReservation(reservation.id);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reserva cancelada com sucesso!'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: const Text(
                  'Sim, Cancelar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  bool _canCancelReservation(Reservation reservation) {
    // Extract start time from period
    final periodMatch = RegExp(
      r'(\d{2}):(\d{2})',
    ).firstMatch(reservation.period ?? '');
    if (periodMatch == null) return true;

    final hour = int.parse(periodMatch.group(1)!);
    final minute = int.parse(periodMatch.group(2)!);

    // Create DateTime for reservation start
    final reservationStart = DateTime(
      reservation.date.year,
      reservation.date.month,
      reservation.date.day,
      hour,
      minute,
    );

    // Check if current time is more than 30 minutes before start
    final now = DateTime.now();
    final difference = reservationStart.difference(now);

    return difference.inMinutes > 30;
  }

  void _showRestrictedCancellationDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cancelamento Restrito',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD32F2F),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Esta reserva não pode ser cancelada. O prazo limite para cancelamento é de **30 minutos** antes do horário de início do agendamento.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Por favor, entre em contato com a administração caso seja uma emergência.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2962FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Entendido',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  String _formatPeriod(String? period) {
    if (period == null) return '';
    final timeMatch = RegExp(
      r'\((\d{2}:\d{2})\s*-\s*(\d{2}:\d{2})\)',
    ).firstMatch(period);
    if (timeMatch != null) {
      return '${timeMatch.group(1)} - ${timeMatch.group(2)}';
    }
    return period;
  }

  Widget _buildNewReservationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Row(
            children: [
              Icon(Icons.book, color: Color(0xFF2962FF), size: 32),
              SizedBox(width: 12),
              Text(
                'Nova Reserva',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Professor Name
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBBDEFB)),
            ),
            child: const Row(
              children: [
                Icon(Icons.person, color: Color(0xFF1976D2)),
                SizedBox(width: 12),
                Text(
                  'Reservando como: Prof. Brunna M.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Room Selection
          CustomDropdown(
            label: 'Sala / Local Físico (Obrigatório)',
            selectedValue: selectedRoom,
            items: rooms,
            onSelect: (value) {
              setState(() {
                selectedRoom = value;
              });
            },
            icon: Icons.home,
          ),
          const SizedBox(height: 24),

          // Equipment Selection
          CustomDropdown(
            label: 'Equipamento Móvel (Opcional)',
            selectedValue: selectedEquipment,
            items: equipment,
            onSelect: (value) {
              setState(() {
                selectedEquipment = value;
              });
            },
            icon: Icons.computer,
          ),
          const SizedBox(height: 24),

          // Date and Period Row
          Row(
            children: [
              // Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('dd/MM/yyyy').format(selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Period
              Expanded(
                child: CustomDropdown(
                  label: 'Período',
                  selectedValue: selectedPeriod,
                  items: periods,
                  onSelect: (value) {
                    setState(() {
                      selectedPeriod = value;
                    });
                  },
                  icon: Icons.access_time,
                  expandUpward: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Reserve Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _makeReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2962FF),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Reservar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyReservationsTab() {
    return Consumer<ReservationProvider>(
      builder: (context, reservationProvider, child) {
        final reservations = reservationProvider.reservations;
        final latestReservation =
            reservations.isNotEmpty ? reservations.last : null;

        return Column(
          children: [
            // Success Banner (shows for 3 seconds)
            if (_showSuccessBanner && latestReservation != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4CAF50), width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF4CAF50),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reserva efetuada: ${latestReservation.room}',
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '(${_formatPeriod(latestReservation.period)})',
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Reservations List
            Expanded(
              child:
                  reservations.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma reserva encontrada',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reservations.length,
                        itemBuilder: (context, index) {
                          final reservation = reservations[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF2962FF),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Room Name
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.meeting_room,
                                        color: Color(0xFF2962FF),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          reservation.room ??
                                              'Sala não especificada',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Professor Name
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        reservation.professorName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Equipment
                                  if (reservation.equipment != null &&
                                      reservation.equipment !=
                                          'Não se Aplica (Apenas Sala)')
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.devices,
                                          color: Color(0xFF9C27B0),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Equipamento Anexo: ${reservation.equipment}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF9C27B0),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (reservation.equipment != null &&
                                      reservation.equipment !=
                                          'Não se Aplica (Apenas Sala)')
                                    const SizedBox(height: 8),

                                  // Date and Time
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(reservation.date),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(
                                        Icons.access_time,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatPeriod(reservation.period),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Cancel Button
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed:
                                              () => _cancelReservation(
                                                reservation,
                                              ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFE53935,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Cancelar',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (!_canCancelReservation(reservation))
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          child: Text(
                                            '(Prazo expirado)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2962FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed:
              () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: const Text(
          'Bem-vindo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          tabs: [
            Tab(icon: const Icon(Icons.book), text: 'Nova Reserva'),
            Consumer<ReservationProvider>(
              builder: (context, reservationProvider, child) {
                return Tab(
                  icon: const Icon(Icons.calendar_today),
                  text:
                      'Minhas Reservas (${reservationProvider.reservationCount})',
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildNewReservationTab(), _buildMyReservationsTab()],
      ),
    );
  }
}
