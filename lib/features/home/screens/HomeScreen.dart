import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_reservation_app/features/home/widgets/menu_card.dart';
import 'package:my_reservation_app/features/reservations/screens/reservations_screen.dart';
import 'package:my_reservation_app/features/reservations/screens/general_reservations_screen.dart';
import 'package:my_reservation_app/providers/reservation_provider.dart';
import 'package:my_reservation_app/widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.home, color: Colors.white),
        title: const Text(
          'Bem-Vindo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF194098),
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(currentRoute: 'home'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeaderCard(),
            const SizedBox(height: 24),

            MenuCard(
              title: 'Reservar Sala e Equipamento',
              subtitle: 'Agende laboratórios, auditórios ou itens móveis.',
              icon: Icons.book,
              color: const Color(0xFFD4F1D4), // Verde suave
              textColor: const Color(0xFF2E7D32), // Verde escuro para texto
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const ReservationsScreen(initialTab: 0),
                  ),
                );
              },
            ),

            Consumer<ReservationProvider>(
              builder: (context, reservationProvider, child) {
                return MenuCard(
                  title:
                      'Minhas Reservas (${reservationProvider.reservationCount})',
                  subtitle:
                      'Visualize, gerencie ou cancele seus agendamentos futuros.',
                  icon: Icons.calendar_today,
                  color: const Color(0xFFFFF9C4), // Amarelo suave
                  textColor: const Color(
                    0xFFF57C00,
                  ), // Laranja/marrom para texto
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                const ReservationsScreen(initialTab: 1),
                      ),
                    );
                  },
                );
              },
            ),

            MenuCard(
              title: 'Reservas Gerais',
              subtitle:
                  'Veja a disponibilidade de todos os recursos da escola.',
              icon: Icons.grid_view,
              color: const Color(0xFFE1D5F5), // Roxo suave
              textColor: const Color(0xFF6A1B9A), // Roxo escuro para texto
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GeneralReservationsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF194098),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gestão de Recursos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Escola do Mar',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            'Faça sua reserva de salas ou equipamentos em poucos passos!',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
