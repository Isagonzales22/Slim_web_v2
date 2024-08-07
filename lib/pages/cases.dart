import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:slim_web/components/menu.dart';
import 'package:slim_web/components/pallete.dart';
import 'package:slim_web/pages/caseAssig.dart';

class Cases extends StatefulWidget {
  @override
  State<Cases> createState() => _CasesState();
}

class _CasesState extends State<Cases> {
  final CollectionReference _coleccion1 =
      FirebaseFirestore.instance.collection('cases');
  final CollectionReference _coleccion2 =
      FirebaseFirestore.instance.collection('users');

  String _formatFecha(Timestamp timestamp) {
    DateTime fecha = timestamp.toDate();
    String formattedDate = '${fecha.day}/${fecha.month}/${fecha.year}';
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Amiga'),
        backgroundColor: Pallete.pink,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 16,
              ),
              Text(
                'Casos',
                style: TextStyle(
                  color: Color(0xFFD15A7C),
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: EdgeInsets.all(20), // Margen para el DataTable
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFC06C84), // Color del borde
                    width: 1.0, // Ancho del borde
                  ),
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _coleccion1
                      .where('estado', isEqualTo: 'pendiente')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Text('No hay datos disponibles en la colección1.');
                    } else {
                      return FutureBuilder<List<DataRow>>(
                        future: _buildDataRows(snapshot.data!.docs),
                        builder: (context, dataRowSnapshot) {
                          if (dataRowSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else {
                            return DataTable(
                              columns: const [
                                //DataColumn(label: Text('ID Colección1')),
                                DataColumn(label: Text('Denunciante')),
                                DataColumn(label: Text('Telefono')),
                                DataColumn(label: Text('CI')),
                                DataColumn(label: Text('Supervisor')),
                                DataColumn(label: Text('Estado')),
                                DataColumn(label: Text('Alerta')),
                                DataColumn(label: Text('Fecha')),
                                DataColumn(label: Text('Asignar')),
                              ],
                              rows: dataRowSnapshot.data!,
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      drawer: MenuWidget(), // Usa el widget MenuWidget
    );
  }

  Future<List<DataRow>> _buildDataRows(
      List<QueryDocumentSnapshot> documents1) async {
    List<Future<DataRow>> futures =
        documents1.map((DocumentSnapshot document1) async {
      Map<String, dynamic> data1 = document1.data() as Map<String, dynamic>;
      String idColeccion2 = data1['supervisor'].toString();
      String idColeccion22 = data1['user'].toString();
      DocumentSnapshot document22 = await _coleccion2.doc(idColeccion22).get();
      Map<String, dynamic> data22 = document22.data() as Map<String, dynamic>;
      if (idColeccion2 != null || idColeccion2 == "") {
        DocumentSnapshot document2 = await _coleccion2.doc(idColeccion2).get();

        if (document2.exists) {
          Map<String, dynamic> data2 = document2.data() as Map<String, dynamic>;

          return DataRow(
            cells: [
              DataCell(Text(data22['fullname'] ?? 'Dato no encontrado')),
              DataCell(
                  Text(data22['phone'].toString() ?? 'Dato no encontrado')),
              DataCell(Text(data22['ci'].toString() ?? 'Dato no encontrado')),
              DataCell(Text(data2['fullname'].toString() ?? 'Sin Asignar')),
              DataCell(
                  Text(data1['estado'].toString() ?? 'Dato no encontrado')),
              DataCell(Text(data1['alert'].toString())),
              DataCell(Text(_formatFecha(data1['fecha']))),
              DataCell(
                Row(
                  children: [
                    /*
                    IconButton(
                      icon: Icon(
                        Icons.visibility,
                        color: Color(0xFFC06C84),
                      ),
                      onPressed: () {
                        // Agregar aquí la lógica para visualizar el caso
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  ReportCase(caseId: document1.id)),
                        );
                      },
                    ),
                    */
                    /*
                    IconButton(
                      icon: Icon(
                        Icons.visibility,
                        color: Color(0xFFC06C84),
                      ),
                      onPressed: () {
                        // Agregar aquí la lógica para visualizar el caso
                        /*
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                Casos(documentId: document1.id),
                          ),
                        );
                        */
                      },
                    ),
                    */
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Color(0xFFC06C84),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CaseAssign(
                              documentId: document1.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      }

      // En caso de que idColeccion2 o idColeccion22 sea nulo, o los documentos no existan, devolver una fila con valores predeterminados
      return DataRow(
        cells: [
          DataCell(Text(data22['fullname'] ?? 'Dato no encontrado')),
          DataCell(Text(data22['phone'].toString() ?? 'Dato no encontrado')),
          DataCell(Text(data22['ci'].toString() ?? 'Dato no encontrado')),
          DataCell(Text('Sin Asignar')),
          DataCell(Text(data1['estado'] ?? 'Dato no encontrado')),
          DataCell(Text(data1['alert'].toString())),
          DataCell(Text('sin fecha')),
          DataCell(
            Row(
              children: [
                /*
                IconButton(
                  icon: Icon(
                    Icons.visibility,
                    color: Color(0xFFC06C84),
                  ),
                  onPressed: () {
                    // Agregar aquí la lógica para visualizar el caso
                    /*
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              ReportCase(caseId: document1.id)),
                    );
                    */
                  },
                ),
                */
                /*
                IconButton(
                  icon: Icon(
                    Icons.visibility,
                    color: Color(0xFFC06C84),
                  ),
                  onPressed: () {
                    // Agregar aquí la lógica para visualizar el caso
                    /*
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Casos(documentId: document1.id),
                      ),
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => Casos(
                                documentId: document1.id,
                              )),
                    );
                    */
                  },
                ),
                */
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Color(0xFFC06C84),
                  ),
                  onPressed: () {
                    // Agregar aquí la lógica para editar el usuario
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => CaseAssign(
                                documentId: document1.id,
                              )),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();

    // Esperar a que todos los futuros se completen
    List<DataRow> dataRows = await Future.wait(futures);

    return dataRows;
  }
}
