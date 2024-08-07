// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:slim_web/components/button.dart';
import 'package:slim_web/components/menu.dart';
import 'package:slim_web/components/pallete.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slim_web/pages/supervisor.dart';
import 'package:slim_web/pages/supervisorUpdate.dart';

class ReportSupervisor extends StatefulWidget {
  @override
  State<ReportSupervisor> createState() => _ReportSupervisorState();
}

class _ReportSupervisorState extends State<ReportSupervisor> {
  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('users');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Amiga'),
        backgroundColor: Pallete.pink,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'Supervisores',
                style: TextStyle(
                  color: Pallete.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 850),
                Expanded(
                  child: Button(
                    text: 'Crear Supervisor',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SupervisorPage(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 400),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              margin: EdgeInsets.all(20), // Margen para el DataTable
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color(0xFFC06C84), // Color del borde
                  width: 1.0, // Ancho del borde
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _collectionReference
                    .where('role', isEqualTo: 'Supervisor')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('No hay supervisores disponibles.');
                  } else {
                    return DataTable(
                      columns: const [
                        DataColumn(label: Text('Nombre')),
                        DataColumn(label: Text('CI')),
                        DataColumn(label: Text('Correo')),
                        DataColumn(label: Text('Telefono')),
                        DataColumn(label: Text('Rol')),
                        DataColumn(label: Text('Editar  Borrar')),
                      ],
                      rows:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String userId = document.id;
                        String userName =
                            data['fullname'] ?? 'Nombre no encontrado';
                        String userCI =
                            data['ci'].toString() ?? 'CI no encontrado';
                        String userCorreo =
                            data['email'] ?? 'Correo no encontrado';
                        String userTelefono = data['phone'].toString() ??
                            'telefono no encontrado';
                        String userRol = data['role'] ?? 'Rol no encontrado';

                        return DataRow(
                          cells: [
                            DataCell(Text(userName)),
                            DataCell(Text(userCI)),
                            DataCell(Text(userCorreo)),
                            DataCell(Text(userTelefono)),
                            DataCell(Text(userRol)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      color: Color(
                                          0xFFC06C84), // Color C06C84 para el icono de editar
                                    ),
                                    onPressed: () {
                                      // Agregar aquí la lógica para editar el usuario
                                      //Next(context);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SupervisorUpdate(
                                                  documentId: document.id,
                                                  ci: data['ci'].toString(),
                                                  email:
                                                      data['email'].toString(),
                                                  phone:
                                                      data['phone'].toString(),
                                                  fullname: data['fullname']
                                                      .toString()),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      color: Color(
                                          0xFFC06C84), // Color C06C84 para el icono de eliminar
                                    ),
                                    onPressed: () {
                                      // Agregar aquí la lógica para eliminar el usuario
                                      showDeleteConfirmationDialog(
                                          context, document.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      drawer: MenuWidget(), // Usa el widget MenuWidget
    );
  }
}

void showDeleteConfirmationDialog(BuildContext context, String documentId) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Confirmación'),
        content: Text('¿Estás seguro de que deseas borrar este supervisor?'),
        actions: [
          TextButton(
            onPressed: () {
              // Cerrar el cuadro de diálogo sin borrar el documento
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Borrar el documento después de la confirmación
              Navigator.of(context).pop(); // Cerrar el cuadro de diálogo
              deleteDocument(documentId);
            },
            child: Text('Aceptar'),
          ),
        ],
      );
    },
  );
}

void deleteDocument(String documentId) async {
  try {
    final CollectionReference _items =
        FirebaseFirestore.instance.collection('users');
    // Obtener una referencia al documento
    DocumentReference documentReference = _items.doc(documentId);

    // Borrar el documento
    await documentReference.delete();
    print('Documento borrado correctamente.');
  } catch (error) {
    print('Error al borrar el documento: $error');
  }
}
