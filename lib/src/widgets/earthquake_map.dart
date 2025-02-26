import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class MapaSismos extends StatefulWidget {
  const MapaSismos({super.key});

  @override
  State<MapaSismos> createState() => _MapaSismosEstado();
}

class _MapaSismosEstado extends State<MapaSismos> {
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

        double latitud;
        if (sismo['geometry']['coordinates'][1] is int) {
          latitud = (sismo['geometry']['coordinates'][1] as int).toDouble();
        } else {
          latitud = sismo['geometry']['coordinates'][1];
        }

        double longitud;
        if (sismo['geometry']['coordinates'][0] is int) {
          longitud = (sismo['geometry']['coordinates'][0] as int).toDouble();
        } else {
          longitud = sismo['geometry']['coordinates'][0];
        }

        String fecha;
if (sismo['properties']['time'] != null) {
  int tiempo = sismo['properties']['time'];
  fecha = DateTime.fromMillisecondsSinceEpoch(tiempo).toLocal().toString();
} else {
  fecha = "Fecha desconocida";
}


        sismosTemporales.add({
          "magnitud": magnitud,
          "ubicacion": ubicacion,
          "latitud": latitud,
          "longitud": longitud,
          "fecha": fecha,
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
        child: Icon(Icons.map, color: Colors.white),
      ),
    );
  } else {
    if (primeraCarga) {
      return Scaffold(
        body: Center(
          child: Text("Presiona el botón para cargar los sismos en el mapa"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: obtenerSismos,
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.map, color: Colors.white),
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
            child: Icon(Icons.map, color: Colors.white),
          ),
        );
      } else {
        return Scaffold(
          body: FlutterMap(
            mapController: MapController(), // Se agrega el controlador del mapa
            options: MapOptions(
              initialCenter: LatLng(0, 0), // Mapa centrado en el mundo
              initialZoom: 2, // Zoom alejado para ver todos los sismos
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),

              // Capa de marcadores
              MarkerLayer(
                markers: listaSismos.map((sismo) {
                  return Marker(
                    point: LatLng(sismo['latitud'], sismo['longitud']),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        // Mostrar un AlertDialog con la información del sismo
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.grey[900], // Color oscuro
                              title: Text(
                                "Sismo detectado",
                                style: TextStyle(color: Colors.white),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Magnitud: ${sismo['magnitud']}",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Ubicación: ${sismo['ubicacion']}",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Fecha: ${sismo['fecha']}",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cerrar", style: TextStyle(color: Colors.blueAccent)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Icon(
                        Icons.location_on,
                        color: sismo['magnitud'] >= 5 ? Colors.red : Colors.amber,
                        size: 30,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: obtenerSismos,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.map, color: Colors.white),
          ),
        );
      }
    }
  }
}
}