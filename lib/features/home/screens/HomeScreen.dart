import 'package:flutter/material.dart';
import 'package:my_reservation_app/features/home/widgets/menu_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.home, color: Colors.white),
        title: const Text('Bem-Vindo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF194098),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
            // Ação do botão de menu
            },
          ),  
       ]
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeaderCard(),
            const SizedBox(height: 24),

            MenuCard(
              title: 'Reservar Sala e Equipamentos',
              subtitle: 'Agende laboratórios, auditórios ou equipamentos.',
              icon: Icons.book,
              color: const Color(0xFF4CAF50), // Verde
              onTap: () {
              // Ação ao tocar no card
              },
            ),

            MenuCard(
              title: 'Minhas Reservas (0)',
              subtitle: 'Visualize, gerencie ou cancele seus agendamentos futuros.',
              icon: Icons.calendar_today,
              color: const Color(0xFFFFEB3B), // Amarelo
              onTap: () {
              // Ação ao tocar no card
              },
            ),

            MenuCard(
              title: 'Reservas Gerais',
              subtitle: 'Veja a disponibilidade de todos os recursos da escola.',
              icon: Icons.grid_view,
              color: const Color(0xFF9C27B0), // Roxo
              onTap: () {
              // Ação ao tocar no card
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
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Faça sua reserva de salas ou equipamentos em poucos passos!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          )
        ],
      ),
    );
  }
}
