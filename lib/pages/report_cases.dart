// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, library_private_types_in_public_api, unused_local_variable, body_might_complete_normally_nullable, non_constant_identifier_names, avoid_print, deprecated_member_use

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:slim_web/components/menu.dart';
import 'package:slim_web/components/pallete.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:slim_web/pages/viewreport.dart';
import 'package:slim_web/pages/widgets/custom_app_bar.dart';
import 'package:slim_web/pages/widgets/custom_button.dart';
import 'package:slim_web/pages/widgets/custom_date_piker.dart';

class Reports extends StatefulWidget {
  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  TextEditingController fullnameDenunciante = TextEditingController();

  TextEditingController fechaFinController = TextEditingController();

  TextEditingController fechaInicioController = TextEditingController();

  List<Case> cases = [];

  List<Case> filteredCases = [];

  Future<void> getData() async {
    filteredCases = await getCasesFromFirestore();
    cases = filteredCases;
    print('cases: ${cases.length}');
    setState(() {});
  }

  Future<List<Case>> getCasesFromFirestore({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('cases')
          .where('estado', isEqualTo: 'finalizado')
          .where('fecha',
              isGreaterThanOrEqualTo:
                  fechaInicio != null ? Timestamp.fromDate(fechaInicio) : null)
          .where('fecha',
              isLessThanOrEqualTo:
                  fechaFin != null ? Timestamp.fromDate(fechaFin) : null)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final casesList = querySnapshot.docs.map((e) async {
          final data = e.data() as Map<String, dynamic>;
          final supervisorId = data['supervisor'] ?? '';
          String caseId = e.id;
          print('supervisorId: $caseId');

          Supervisor supervisorClass = Supervisor.empty();

          if (supervisorId.isNotEmpty) {
            print('llegaaaaaa');
            final dataSupervisor = await FirebaseFirestore.instance
                .collection('users')
                .doc(supervisorId)
                .get();

            if (dataSupervisor.data() != null) {
              print('existe');
              supervisorClass =
                  Supervisor.fromJson(dataSupervisor.data()!, supervisorId);
            }
          }

          // Obtener datos del denunciante
          final denuncianteData = data['denunciante'] as Map<String, dynamic>;
          final denunciante = Denunciante.fromJson(denuncianteData);

          //obtener evidencias

          final dataEvidence = await FirebaseFirestore.instance
              .collection('evidence')
              .where('case', isEqualTo: caseId)
              .get();

          final evidenceList = dataEvidence.docs.map((e) {
            final data = e.data();
            final evidenceId = e.id;
            return Evidence.fromJson(data, evidenceId);
          }).toList();

          return Case.fromJson(data, supervisorClass, evidenceList);
        }).toList();

        return Future.wait(casesList);
      } else {
        print(
            'No hay documentos que cumplan con los criterios de la consulta.');
        return [];
      }
    } on FirebaseException catch (e) {
      print('Error de Firebase: $e');
      return [];
    } on Exception catch (e) {
      print('Error desconocido: $e');
      return [];
    }
  }

  Future<void> _printPdf(List<Case> cases) async {
    final pdf = pw.Document();

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);

    pdf.addPage(
      pw.MultiPage(
        header: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(bottom: 20.0),
            child: pw.Text(
              'Reporte de Casos',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20.0),
            child: pw.Text(
              'Fecha de impresión: $formattedDate',
              style: pw.TextStyle(fontSize: 12),
            ),
          );
        },
        build: (pw.Context context) => [
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              <String>['Nombre', 'Teléfono', 'CI', 'Supervisor', 'Estado'],
              for (var caseItem in cases)
                <String>[
                  caseItem.denunciante.fullname,
                  caseItem.denunciante.phone.toString(),
                  caseItem.denunciante.ci.toString(),
                  caseItem.supervisor.fullname,
                  caseItem.estado,
                ],
            ],
          ),
        ],
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'reporte.pdf');
  }

  void Next(BuildContext context, Case caseData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportCase(caseData: caseData),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Container(
        margin: EdgeInsets.only(right: 20, left: 20, top: 20, bottom: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(
                child: Text(
                  'Reportes por fechas',
                  style: TextStyle(
                    color: Color(0xFFD15A7C),
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: CustomDatePiker(
                      controller: fechaInicioController,
                      label: 'Fecha Inico',
                      hint: 'Fecha inicio',
                      widthLineR: 0.1,
                      colorIcon: Pallete.pink)),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: CustomDatePiker(
                      controller: fechaFinController,
                      label: 'Fecha Final',
                      hint: 'Fecha final',
                      widthLineR: 0.1,
                      colorIcon: Pallete.pink)),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: CustomButton(
                    label: 'Filtrar',
                    onPressed: () async {
                      final fechaInicio = fechaInicioController.text.trim();
                      final fechaFin = fechaFinController.text.trim();

                      if (fechaInicio.isEmpty || fechaFin.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Theme.of(context).errorColor,
                            content: Text(
                                'Debe ingresar una fecha de inicio y una fecha final.'),
                          ),
                        );
                        return;
                      }

                      if (fechaInicio.compareTo(fechaFin) > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Theme.of(context).errorColor,
                            content: Text(
                                'La fecha de inicio debe ser menor a la fecha final.'),
                          ),
                        );
                        return;
                      }

                      final fechaInicioDate = DateTime.parse(fechaInicio);
                      final fechaFinDate = DateTime.parse(fechaFin);

                      final casos = await getCasesFromFirestore();

                      setState(() {
                        filteredCases = casos
                            .where((caseItem) =>
                                caseItem.fecha.isAfter(fechaInicioDate) &&
                                caseItem.fecha.isBefore(
                                    fechaFinDate.add(Duration(days: 1))))
                            .toList();
                      });
                    }),
              ),
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width / 1.2,
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Spacer(),
                          CircleAvatar(
                            backgroundColor: Pallete.pink,
                            child: IconButton(
                              onPressed: () async {
                                final casesNew = await getCasesFromFirestore();

                                setState(() {
                                  filteredCases = casesNew;
                                });
                              },
                              icon: Icon(
                                Icons.restore,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          CircleAvatar(
                            backgroundColor: Pallete.pink,
                            child: IconButton(
                              onPressed: () async {
                                final casesNew = await getCasesFromFirestore();

                                await _printPdf(casesNew);
                              },
                              icon: Icon(
                                Icons.print,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: Pallete.pink,
                        thickness: 2,
                      ),
                    ],
                  ),
                ),
              ),
              filteredCases.isEmpty
                  ? Center(
                      child: Text(
                        'No hay casos registrados.',
                        style: TextStyle(
                          color: Pallete.pink,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    )
                  : Container(
                      margin: EdgeInsets.all(20),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: Pallete.pink),
                        ),
                        child: DataTable(
                          headingRowColor: MaterialStateColor.resolveWith(
                              (Set<MaterialState> states) => Pallete.pink),
                          columns: [
                            DataColumn(
                                label: Text('Nombre',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Teléfono',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('CI',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Supervisor',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Fecha',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Estado',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            DataColumn(
                                label: Text('Acción',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                          rows: (filteredCases)
                              .asMap()
                              .entries
                              .map(
                                (entry) => DataRow(
                                  color:
                                      MaterialStateProperty.resolveWith<Color>(
                                    (Set<MaterialState> states) {
                                      return entry.key.isEven
                                          ? Colors.white
                                          : Colors.grey[200] ?? Colors.white;
                                    },
                                  ),
                                  cells: [
                                    DataCell(
                                        Text(entry.value.denunciante.fullname)),
                                    DataCell(Text(entry.value.denunciante.phone
                                        .toString())),
                                    DataCell(Text(
                                        entry.value.denunciante.ci.toString())),
                                    DataCell(
                                        Text(entry.value.supervisor.fullname)),
                                    DataCell(Text(entry.value.fecha
                                        .toString()
                                        .substring(0, 10))),
                                    DataCell(Text(entry.value.estado)),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.visibility,
                                                color: Colors.pink),
                                            onPressed: () {
                                              // Lógica para ver detalles del usuario
                                              Next(context, entry.value);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.print,
                                                color: Colors.pink),
                                            onPressed: () async {
                                              // Lógica para imprimir el PDF
                                              await _printPdf(cases);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      drawer: MenuWidget(),
    );
  }
}

class Case {
  Case({
    required this.supervisor,
    required this.incidente,
    required this.fecha,
    required this.oficial,
    required this.estado,
    required this.denunciante,
    required this.user,
    required this.caseId,
    required this.evidence,
  });

  final Supervisor supervisor;
  final Incidente incidente;
  final DateTime fecha;
  final String oficial;
  final String estado;
  final Denunciante denunciante;
  final String user;
  final String caseId;
  final List<Evidence> evidence;

  factory Case.fromJson(Map<String, dynamic> json, Supervisor supervisor,
      List<Evidence> evidence) {
    Timestamp firestoreTimestamp = json['fecha'];
    DateTime dateTime = firestoreTimestamp.toDate();

    return Case(
      supervisor: Supervisor(
          id: supervisor.id,
          email: supervisor.email,
          fullname: supervisor.fullname,
          password: supervisor.password,
          phone: supervisor.phone,
          ci: supervisor.ci),
      incidente: Incidente.fromJson(json['incidente']),
      fecha: dateTime,
      oficial: json['oficial'] ?? '',
      estado: json['estado'] ?? '',
      denunciante: Denunciante.fromJson(json['denunciante']),
      user: json['user'] ?? '',
      caseId: json['caseId'] ?? '',
      evidence: evidence.map((e) => e).toList(),
    );
  }
}

class Incidente {
  Incidente({
    required this.lat,
    required this.long,
    required this.userid,
    required this.audioUrl,
    required this.imageUrl,
    required this.descriptionIncidente,
    required this.fechaIncidente,
  });
  final double lat;
  final double long;
  final String userid;
  final String audioUrl;
  final List<String> imageUrl;
  final String descriptionIncidente;
  final DateTime fechaIncidente;

  factory Incidente.fromJson(Map<String, dynamic> json) {
    Timestamp firestoreTimestamp = json['fechaIncidente'];
    List<dynamic> images = json['imageUrl'];
    DateTime dateTime = firestoreTimestamp.toDate();
    return Incidente(
        lat: json['lat'] ?? 0.0,
        long: json['long'] ?? 0.0,
        userid: json['userid'] ?? '',
        audioUrl: json['audioUrl'] ?? '',
        imageUrl: images.cast<String>(),
        descriptionIncidente: json['descripcionIncidente'] ?? '',
        fechaIncidente: dateTime);
  }
}

class Denunciante {
  Denunciante({
    required this.ci,
    required this.userId,
    required this.phone,
    required this.long,
    required this.lat,
    required this.fullname,
  });

  final int ci;
  final String userId;
  final int phone;
  final double long;
  final double lat;
  final String fullname;

  factory Denunciante.fromJson(Map<String, dynamic> json) {
    return Denunciante(
        ci: json['ci'] ?? 0,
        userId: json['userId'] ?? '',
        phone: json['phone'] ?? 0,
        long: json['long'] ?? 0.0,
        lat: json['lat'] ?? 0.0,
        fullname: json['fullname'] ?? '');
  }
}

class Supervisor {
  Supervisor({
    required this.id,
    required this.ci,
    required this.email,
    required this.fullname,
    required this.password,
    required this.phone,
  });

  final String id;
  final int ci;
  final String email;
  final String fullname;
  final String password;
  final int phone;

  factory Supervisor.fromJson(Map<String, dynamic> json, String id) {
    return Supervisor(
        id: id,
        ci: 0,
        email: json['email'] ?? '',
        fullname: json['fullname'] ?? '',
        password: json['password'] ?? '',
        phone: 0);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ci': ci,
        'email': email,
        'fullname': fullname,
        'password': password,
        'phone': phone,
      };

  Supervisor copyWith({
    String? id,
    int? ci,
    String? email,
    String? fullname,
    String? password,
    int? phone,
  }) {
    return Supervisor(
      id: id ?? this.id,
      ci: ci ?? this.ci,
      email: email ?? this.email,
      fullname: fullname ?? this.fullname,
      password: password ?? this.password,
      phone: phone ?? this.phone,
    );
  }

  static Supervisor empty() {
    return Supervisor(
      id: '',
      ci: 0,
      email: '',
      fullname: '',
      password: '',
      phone: 0,
    );
  }
}

class Evidence {
  final String id;
  final String audioUrl;
  final String caseId;
  final String description;
  final String document;
  final DateTime fecha;
  final List<String> imageUrl;
  final double lat;
  final double long;

  Evidence({
    required this.id,
    required this.audioUrl,
    required this.caseId,
    required this.description,
    required this.document,
    required this.fecha,
    required this.imageUrl,
    required this.lat,
    required this.long,
  });

  factory Evidence.fromJson(Map<String, dynamic> data, String id) {
    List<dynamic> images = data['imageUrl'];
    return Evidence(
      id: id,
      audioUrl: data['audioUrl'] ?? '',
      caseId: data['case'] ?? '',
      description: (data['descripcion'] ?? '') as String,
      document: data['document'] ?? '',
      fecha: DateTime.now(),
      imageUrl: images.cast<String>(),
      lat: data['lat'] ?? 0.0,
      long: data['long'] ?? 0.0,
    );
  }

  static Evidence empty = Evidence(
    id: '',
    audioUrl: '',
    caseId: '',
    description: '',
    document: '',
    fecha: DateTime.now(),
    imageUrl: [],
    lat: 0.0,
    long: 0.0,
  );

  Evidence copyWith({
    String? id,
    String? audioUrl,
    String? caseId,
    String? description,
    String? document,
    DateTime? fecha,
    List<String>? imageUrl,
    double? lat,
    double? long,
  }) {
    return Evidence(
      id: id ?? this.id,
      audioUrl: audioUrl ?? this.audioUrl,
      caseId: caseId ?? this.caseId,
      description: description ?? this.description,
      document: document ?? this.document,
      fecha: fecha ?? this.fecha,
      imageUrl: imageUrl ?? this.imageUrl,
      lat: lat ?? this.lat,
      long: long ?? this.long,
    );
  }
}
