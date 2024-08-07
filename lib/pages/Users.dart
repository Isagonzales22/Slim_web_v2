// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:slim_web/components/menu.dart';
import 'package:slim_web/components/pallete.dart';


class Users extends StatefulWidget {
  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final CollectionReference _items =
      FirebaseFirestore.instance.collection('users');
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
                'Usuarios',
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
                  stream: _items.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Text('No hay documentos en la colección.');
                    } else {
                      return DataTable(
                        columns: [
                          DataColumn(label: Text('Nombre')),
                          DataColumn(label: Text('CI')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Telefono')),
                          DataColumn(label: Text('Rol'))

                          // Agrega más columnas según tus necesidades
                        ],
                        rows: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data() as Map<String, dynamic>;
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(data['fullname'] ?? ''),
                              ),
                              DataCell(Text(data['ci'].toString() ?? '')),
                              DataCell(Text(data['email'] ?? '')),
                              DataCell(Text(data['phone'].toString() ?? '')),
                              DataCell(Text(data['role'] ?? '')),
                              // Agrega más celdas según tus necesidades
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
      ),

      drawer: MenuWidget(), // Usa el widget MenuWidget
    );
  }
}
