// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_unnecessary_containers, prefer_const_constructors, prefer_final_fields, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:slim_web/components/pallete.dart';
import 'package:slim_web/pages/AuthenticationService%20.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  AuthenticationService _authService =
      AuthenticationService(); // Mover la definición aquí

  int _selectedIndex = 5;

  final List<MenuItem> _menuItems = [
    MenuItem('Perfil', Icons.person),
    MenuItem('Supervisores', Icons.supervisor_account),
    MenuItem('Casos', Icons.business_center),
    MenuItem('Reporte', Icons.insert_chart),
    MenuItem('Contraseña', Icons.lock),
    MenuItem('dashboard', Icons.dashboard),
    MenuItem('Usuarios', Icons.people),
    MenuItem('Cerrar Sesión', Icons.exit_to_app),
  ];

  Future<void> _signOut(BuildContext context) async {
    try {
      final storage = FlutterSecureStorage();

      await storage.deleteAll();

      await _authService.signOut();
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      print("Error al cerrar la sesión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            child: DrawerHeader(
              decoration: BoxDecoration(color: Pallete.white),
              child: Center(
                child: Image.asset('lib/images/logo.png'),
              ),
            ),
          ),
          Divider(),
          ..._menuItems
              .asMap()
              .entries
              .map((entry) => ListTile(
                    onTap: () {
                      setState(() {
                        _selectedIndex = entry.key;
                        Navigator.of(context).pop();
                        // Navegación a las páginas correspondientes
                        if (entry.value.title == 'Perfil') {
                          Navigator.of(context).pushNamed('/perfil');
                        } else if (entry.value.title == 'Supervisores') {
                          Navigator.of(context).pushNamed('/supervisores');
                        } else if (entry.value.title == 'Casos') {
                          Navigator.of(context).pushNamed('/casos');
                        } else if (entry.value.title == 'Reporte') {
                          Navigator.of(context).pushNamed('/reporte');
                        } else if (entry.value.title == 'Contraseña') {
                          Navigator.of(context).pushNamed('/contrasenia');
                        } else if (entry.value.title == 'dashboard') {
                          Navigator.of(context).pushNamed('/dashboard');
                        } else if (entry.value.title == 'Usuarios') {
                          Navigator.of(context).pushNamed('/usuarios');
                        } else if (entry.value.title == 'Cerrar Sesión') {
                          _signOut(context);
                        }
                      });
                    },
                    leading: Icon(
                      entry.value.icon,
                      color: _selectedIndex == entry.key
                          ? Pallete.lightpink
                          : Pallete.grey,
                    ),
                    title: Text(
                      entry.value.title,
                      style: TextStyle(
                        color: _selectedIndex == entry.key
                            ? Pallete.lightpink
                            : Pallete.grey,
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;

  MenuItem(this.title, this.icon);
}
