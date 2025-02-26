import 'package:flutter/material.dart';
import 'src/screens/home.dart';
import 'src/providers/view_provider.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ViewProvider(), // se agrega el provider
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Aplicamos el tema oscuro
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black, // Fondo negro
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.grey, // Barra superior gris oscuro
          titleTextStyle: TextStyle(
            color: Colors.white, // Texto de la barra superior en blanco
            fontSize: 20, 
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white), // Íconos en blanco
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Texto en blanco
          bodyMedium: TextStyle(color: Colors.white70), // Texto gris claro
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey, // Color del botón
            foregroundColor: Colors.white, // Texto del botón en blanco
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)), // Bordes redondeados
            ),
          ),
        ),
      ),

      home: const HomeScreen(), // Pantalla principal
    );
  }
}
