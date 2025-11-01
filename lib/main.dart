import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_reservation_app/features/home/screens/HomeScreen.dart';
import 'package:my_reservation_app/providers/reservation_provider.dart';

void main() {
  runApp(const MyReservation());
}

class MyReservation extends StatelessWidget {
  const MyReservation({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReservationProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyReservation',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

