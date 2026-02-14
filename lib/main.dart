import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Importa Hive
import 'ui/screens/registro_screen.dart';
import 'ui/screens/lobby_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar SharedPreferences (Para el nombre)
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? nombreAlumna = prefs.getString('nombre_alumna');

  // 2. Inicializar Hive (Para las notas/reflexiones)
  await Hive.initFlutter();
  await Hive.openBox('box_reflexiones'); // Abrimos el cajón de las notas

  runApp(MyApp(nombreInicial: nombreAlumna));
}

class MyApp extends StatelessWidget {
  final String? nombreInicial;
  const MyApp({super.key, this.nombreInicial});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Derechos Infancia Normal',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        // Estilo "Child-ish" global
        scaffoldBackgroundColor: Color(0xFFF0F4FF),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
      // Si tenemos el nombre, vamos al Lobby. Si no, al Registro.
      home: nombreInicial == null
          ? RegistroScreen()
          : LobbyScreen(nombreAlumna: nombreInicial!),
    );
  }
}
