import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnalisisScreen extends StatefulWidget {
  @override
  _AnalisisScreenState createState() => _AnalisisScreenState();
}

class _AnalisisScreenState extends State<AnalisisScreen>
    with TickerProviderStateMixin {
  List<String> _derechosSeleccionados = [];
  final TextEditingController _textController = TextEditingController();

  final List<String> _todosLosDerechos = [
    "Identidad",
    "Familia",
    "Salud",
    "Educación",
    "Juego",
    "Participación",
    "Protección",
    "No Discriminación",
    "Expresión",
    "Buen Trato",
    "Nacionalidad",
    "Vivienda",
    "Alimentación",
    "Igualdad",
    "Auxilio",
    "Integración",
    "Vida",
    "Intimidad",
    "Información",
    "Cultura",
  ];

  late AnimationController _fadeController;
  late List<Animation<double>> _listAnimations;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _listAnimations = List.generate(
      4,
      (index) => CurvedAnimation(
        parent: _fadeController,
        curve: Interval(0.2 * index, 1.0, curve: Curves.easeOut),
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _guardarReflexion() {
    final DateTime ahora = DateTime.now();
    final String fechaFormateada = "${ahora.day}/${ahora.month}/${ahora.year}";

    // Creamos el mapa sin objetos complejos como 'Color' para no corromper Hive
    Map<String, dynamic> nuevaNota = {
      "fecha": fechaFormateada,
      "derechos": List<String>.from(_derechosSeleccionados),
      "contenido": _textController.text,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("¡Reflexión guardada con éxito! ✨"),
        backgroundColor: Colors.purple[400],
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );

    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) Navigator.pop(context, nuevaNota);
    });
  }

  @override
  Widget build(BuildContext context) {
    bool canWrite = _derechosSeleccionados.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Nueva Reflexión",
          style: TextStyle(
            color: Colors.indigo[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.indigo[900]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF3E5F5), Colors.white],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                  "¿Qué derechos observaste? ✨",
                  "Selecciona al menos uno para escribir",
                  0,
                ),
                SizedBox(height: 20),
                FadeTransition(
                  opacity: _listAnimations[1],
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: _todosLosDerechos
                        .map((d) => _buildCuteChoiceChip(d))
                        .toList(),
                  ),
                ),
                SizedBox(height: 35),
                _buildTextField(canWrite),
                SizedBox(height: 40),
                _buildSubmitButton(canWrite),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, int animIndex) {
    return FadeTransition(
      opacity: _listAnimations[animIndex],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[800],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.indigo[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(bool enabled) {
    return FadeTransition(
      opacity: _listAnimations[2],
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: enabled ? Colors.purple[200]! : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: TextField(
            controller: _textController,
            enabled: enabled,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: enabled
                  ? "Describe la situación..."
                  : "🔒 Selecciona un derecho arriba...",
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool enabled) {
    return FadeTransition(
      opacity: _listAnimations[3],
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: (enabled && _textController.text.isNotEmpty)
              ? _guardarReflexion
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            "Guardar en mi Diario 💖",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCuteChoiceChip(String label) {
    bool isSelected = _derechosSeleccionados.contains(label);
    return GestureDetector(
      onTap: () => setState(() {
        isSelected
            ? _derechosSeleccionados.remove(label)
            : _derechosSeleccionados.add(label);
      }),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purple[400]
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.indigo[900],
          ),
        ),
      ),
    );
  }
}
