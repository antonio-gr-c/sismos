import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListaSismos extends StatefulWidget {
  const ListaSismos({super.key});

  @override
  State<ListaSismos> createState() => _ListaSismosEstado();
}

class _ListaSismosEstado extends State<ListaSismos> {
  List listaSismos = [];
  bool cargando = false;
  bool primeraCarga = true;

  // Función para obtener los sismos de la API
  Future<void> obtenerSismos() async {
  setState(() {
    cargando = true;
  });

   final url =
      "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&orderby=time&limit=50";

    final respuesta = await http.get(Uri.parse(url));

    if (respuesta.statusCode == 200) {
      final datos = json.decode(respuesta.body);
      List lista = datos['features'];

      List sismosTemporales = [];

      for (var sismo in lista) {
        double magnitud;
        if (sismo['properties']['mag'] is int) {
          magnitud = (sismo['properties']['mag'] as int).toDouble();
        } else if (sismo['properties']['mag'] is double) {
          magnitud = sismo['properties']['mag'];
        } else {
          magnitud = 0.0;
        }

        String ubicacion;
        if (sismo['properties']['place'] != null) {
          ubicacion = sismo['properties']['place'];
        } else {
          ubicacion = "Ubicación desconocida";
        }

        int tiempo = sismo['properties']['time'];
        DateTime fecha = DateTime.fromMillisecondsSinceEpoch(tiempo).toLocal();

        sismosTemporales.add({
          "magnitud": magnitud,
          "ubicacion": ubicacion,
          "fecha": fecha.toString(),
        });
      }

      setState(() {
        listaSismos = sismosTemporales;
        cargando = false;
        primeraCarga = false;
      });

      
    }
  
}


  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: obtenerSismos,
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.download, color: Colors.white),
        ),
      );
    } else {
      if (primeraCarga) {
        return Scaffold(
          body: Center(
            child: Text("Presiona el botón para cargar los sismos"),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: obtenerSismos,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.download, color: Colors.white),
          ),
        );
      } else {
        if (listaSismos.isEmpty) {
          return Scaffold(
            body: Center(
              child: Text("No hay sismos recientes"),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: obtenerSismos,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.download, color: Colors.white),
            ),
          );
        } else {
          return Scaffold(
            body: ListView.builder(
              itemCount: listaSismos.length,
              itemBuilder: (context, indice) {
                final sismo = listaSismos[indice];

                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.broadcast_on_personal_sharp,
                      color: sismo['magnitud'] >= 5 ? Colors.red : Colors.amber,
                    ),
                    title: Text(
                      "Magnitud: ${sismo['magnitud']}",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      // ignore: prefer_interpolation_to_compose_strings
                      sismo['ubicacion'] + "\nFecha: " + sismo['fecha'],
                      style: TextStyle(color: Colors.white70),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: obtenerSismos,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.download, color: Colors.white),
            ),
          );
        }
      }
    }
  }
}
