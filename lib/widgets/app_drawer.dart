import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_reservation_app/features/home/screens/HomeScreen.dart';
import 'package:my_reservation_app/features/reservations/screens/reservations_screen.dart';
import 'package:my_reservation_app/features/reservations/screens/general_reservations_screen.dart';
import 'package:my_reservation_app/features/profile/screens/profile_screen.dart';
import 'package:my_reservation_app/features/auth/screens/login_screen.dart';
import 'package:my_reservation_app/providers/reservation_provider.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            color: const Color(0xFF2962FF),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  context: context,
                  icon: Icons.home,
                  title: 'Início',
                  isActive: currentRoute == 'home',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    if (currentRoute != 'home') {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.book,
                  title: 'Reservar Sala e Equipamento',
                  isActive: currentRoute == 'new_reservation',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    if (currentRoute != 'new_reservation') {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  const ReservationsScreen(initialTab: 0),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
                Consumer<ReservationProvider>(
                  builder: (context, reservationProvider, child) {
                    return _buildDrawerItem(
                      context: context,
                      icon: Icons.calendar_today,
                      title:
                          'Minhas Reservas (${reservationProvider.reservationCount})',
                      isActive: currentRoute == 'my_reservations',
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        if (currentRoute != 'my_reservations') {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const ReservationsScreen(initialTab: 1),
                            ),
                            (route) => false,
                          );
                        }
                      },
                    );
                  },
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.grid_view,
                  title: 'Reservas Gerais',
                  isActive: currentRoute == 'general_reservations',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    if (currentRoute != 'general_reservations') {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const GeneralReservationsScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
                const Divider(height: 32, thickness: 1),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.person,
                  title: 'Meu Perfil',
                  isActive: currentRoute == 'profile',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'profile') {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // Logout button at bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sair / Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isActive
                ? const Color(0xFF4CAF50).withOpacity(0.1)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFF4CAF50) : Colors.grey.shade700,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFF4CAF50) : Colors.grey.shade800,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        trailing:
            isActive
                ? const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF4CAF50),
                  size: 16,
                )
                : null,
        enabled: !isActive, // Disable if already on this page
        onTap: isActive ? null : onTap,
      ),
    );
  }
}
