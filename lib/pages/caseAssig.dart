// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:slim_web/components/menu.dart';
import 'package:slim_web/components/pallete.dart';
import 'package:slim_web/pages/cases.dart';

class CaseAssign extends StatefulWidget {
  final String documentId;

  CaseAssign({
    required this.documentId,
  });

  @override
  State<CaseAssign> createState() => _CaseAssignState();
}

class _CaseAssignState extends State<CaseAssign> {
  final TextEditingController _filtroController = TextEditingController();
  List<DocumentSnapshot> _documentosFiltrados = [];
  CollectionReference _coleccion =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _coleccion1 =
      FirebaseFirestore.instance.collection('cases');

  void updateSupervisor(String documentId, String newSupervisor) async {
    try {
      DocumentReference documentReference = _coleccion1.doc(documentId);

      if (!newSupervisor.isEmpty) {
        await documentReference.update({
          'supervisor': newSupervisor,
        });
      }
      print('Dato actualizado correctamente.');
    } catch (error) {
      print('Error al actualizar el dato: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Amiga'),
        backgroundColor: Pallete.pink,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.black),
                    controller: _filtroController,
                    onChanged: (filtro) {
                      _filtrarDocumentos(filtro.toLowerCase());
                    },
                    decoration: InputDecoration(
                      labelText: 'Filtrar por email',
                      contentPadding: const EdgeInsets.all(27),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Pallete.borderColor,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "Filtrar por email",
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _documentosFiltrados.isNotEmpty
                ? _construirTabla(_documentosFiltrados)
                : _construirTablaCompleta(),
          ),
        ],
      ),
      drawer: MenuWidget(),
    );
  }

  void _filtrarDocumentos(String filtro) {
    print('Filtro: $filtro');

    if (filtro.isEmpty) {
      setState(() {
        _documentosFiltrados.clear();
      });
      return;
    }

    _coleccion
        .where('email', isGreaterThanOrEqualTo: filtro)
        .get()
        .then((querySnapshot) {
      setState(() {
        _documentosFiltrados = querySnapshot.docs
            .where(
                (doc) => doc['email'].toString().toLowerCase().contains(filtro))
            .toList();
      });
    }).catchError((error) {
      print('Error al filtrar documentos: $error');
    });
  }

  Widget _construirTabla(List<DocumentSnapshot> documentos) {
    return DataTable(
      columns: [
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Nombre')),
        DataColumn(label: Text('ci')),
        DataColumn(label: Text('Asignar')),
      ],
      rows: documentos.map((documento) {
        Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
        return DataRow(
          cells: [
            DataCell(Text(data['email'].toString())),
            DataCell(Text(data['fullname'].toString())),
            DataCell(Text(data['ci'].toString())),
            DataCell(
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Color(0xFFC06C84),
                    ),
                    onPressed: () {
                      _mostrarDialogoConfirmacion(
                        context,
                        documento.id,
                        data['fullname'].toString(),
                      );
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

  Widget _construirTablaCompleta() {
    return StreamBuilder<QuerySnapshot>(
      stream: _coleccion.where('role', isEqualTo: 'Supervisor').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        List<DocumentSnapshot> documentos = snapshot.data!.docs;

        return _construirTabla(documentos);
      },
    );
  }

  void _mostrarDialogoConfirmacion(
      BuildContext context, String supervisorId, String supervisorName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Asignación'),
          content: Text(
              '¿Está seguro de asignar este caso al supervisor $supervisorName?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                updateSupervisor(widget.documentId, supervisorId);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Cases(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
