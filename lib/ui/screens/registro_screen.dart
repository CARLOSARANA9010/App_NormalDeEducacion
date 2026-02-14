import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lobby_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController _nameController = TextEditingController();

  Future<void> _guardarNombreYContinuar() async {
    if (_nameController.text.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Guardamos con la llave 'nombre_alumna'
      await prefs.setString('nombre_alumna', _nameController.text);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (c) => LobbyScreen(nombreAlumna: _nameController.text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.face, size: 100, color: Colors.lightBlue[300]),
            const SizedBox(height: 20),
            const Text(
              "¡Bienvenid@!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text("Escribe tu nombre para comenzar"),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                hintText: "Tu nombre aquí...",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _guardarNombreYContinuar,
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: const Text("Empezar"),
            ),
          ],
        ),
      ),
    );
  }
}
