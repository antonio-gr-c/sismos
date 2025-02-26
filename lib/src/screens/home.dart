import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/earthquake_list.dart';
import '../widgets/earthquake_map.dart';
import '../providers/view_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewProvider = Provider.of<ViewProvider>(context); // Obtener el Provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medidor de Sismos'),
      ),
      body: viewProvider.currentIndex == 0
          ?  ListaSismos() // Muestra la lista si currentIndex es 0
          :  MapaSismos(), // Muestra el mapa si currentIndex es 1
      bottomNavigationBar: BottomNavBar(
        currentIndex: viewProvider.currentIndex, // Índice actual
        onTap: (index) => viewProvider.changeView(index), // Cambia la vista
      ),
    );
  }
}
