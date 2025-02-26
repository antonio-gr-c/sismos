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
  List listaFiltrada = []; // Nueva lista filtrada
  bool cargando = false;
  bool primeraCarga = true;
  double magnitudMinima = 0.0; // Magnitud mínima seleccionada

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
        aplicarFiltro(); // Filtrar los sismos con la magnitud mínima seleccionada
        cargando = false;
        primeraCarga = false;
      });
    }
  }

  // Función para aplicar el filtro de magnitud
  void aplicarFiltro() {
    setState(() {
      listaFiltrada = listaSismos
          .where((sismo) => sismo['magnitud'] >= magnitudMinima)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Scaffold(
        appBar: AppBar(title: const Text("Lista de Sismos")),
        body: const Center(child: CircularProgressIndicator()),
        floatingActionButton: FloatingActionButton(
          onPressed: obtenerSismos,
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.download, color: Colors.white),
        ),
      );
    } else {
      return Scaffold(
       
        body: primeraCarga
            ? const Center(child: Text("Presiona el botón para cargar los sismos"))
            : Column(
                children: [
                  // Slider para seleccionar la magnitud mínima
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const Text("Filtrar por magnitud mínima:", style: TextStyle(color: Colors.white)),
                        Slider(
                          value: magnitudMinima,
                          min: 0.0,
                          max: 10.0,
                          divisions: 20,
                          label: magnitudMinima.toStringAsFixed(1),
                          onChanged: (valor) {
                            setState(() {
                              magnitudMinima = valor;
                              aplicarFiltro(); // Aplicar filtro al cambiar el slider
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Lista de sismos filtrados
                  Expanded(
                    child: listaFiltrada.isEmpty
                        ? const Center(child: Text("No hay sismos recientes con esta magnitud"))
                        : ListView.builder(
                            itemCount: listaFiltrada.length,
                            itemBuilder: (context, indice) {
                              final sismo = listaFiltrada[indice];

                              return Card(
                                color: Colors.grey[900],
                                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    "${sismo['ubicacion']}\nFecha: ${sismo['fecha']}",
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: obtenerSismos,
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.download, color: Colors.white),
        ),
      );
    }
  }
}
