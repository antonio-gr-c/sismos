import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.grey[900], // Fondo oscuro
      selectedItemColor: Colors.blueAccent, // Color del ícono seleccionado
      unselectedItemColor: Colors.grey, // Color del ícono no seleccionado
      currentIndex: currentIndex, // Índice actual
      onTap: onTap, // Llama a la función de cambio de vista
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Lista de Sismos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Mapa',
        ),
      ],
    );
  }
}
