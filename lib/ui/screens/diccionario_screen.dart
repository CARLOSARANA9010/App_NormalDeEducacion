import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Importación necesaria

class DiccionarioScreen extends StatefulWidget {
  const DiccionarioScreen({super.key});

  @override
  _DiccionarioScreenState createState() => _DiccionarioScreenState();
}

class _DiccionarioScreenState extends State<DiccionarioScreen> {
  // 1. Instanciamos la caja de Hive
  final box = Hive.box('box_reflexiones');

  // LISTA COMPLETA CON RELACIONES DE PALABRAS CLAVE
  final List<Map<String, dynamic>> _derechosInfo = [
    {
      "titulo": "Identidad",
      "def": "Derecho a tener un nombre y una nacionalidad.",
      "color": const Color(0xFFFFE5E5),
      "icon": Icons.face_retouching_natural,
      "keywords": ["Nombre", "Nacionalidad", "Origen"],
    },
    {
      "titulo": "Familia",
      "def": "Derecho a vivir con su familia y ser cuidados por ella.",
      "color": const Color(0xFFE5F0FF),
      "icon": Icons.favorite_rounded,
      "keywords": ["Amor", "Cuidado", "Hogar", "Bienestar"],
    },
    {
      "titulo": "Salud",
      "def": "Derecho a recibir atención médica y estar sanos.",
      "color": const Color(0xFFE5FFEB),
      "icon": Icons.health_and_safety,
      "keywords": ["Médico", "Nutrición", "Prevención", "Cuidado", "Bienestar"],
    },
    {
      "titulo": "Educación",
      "def": "Derecho a aprender y asistir a una escuela.",
      "color": const Color(0xFFFFF7E5),
      "icon": Icons.auto_stories,
      "keywords": ["Aprendizaje", "Escuela", "Desarrollo", "Inclusión"],
    },
    {
      "titulo": "Juego",
      "def": "Derecho a jugar, descansar y divertirse.",
      "color": const Color(0xFFF3E5FF),
      "icon": Icons.toys,
      "keywords": ["Recreación", "Ocio", "Amigos", "Desarrollo"],
    },
    {
      "titulo": "Participación",
      "def": "Derecho a decir lo que piensan y ser escuchados.",
      "color": const Color(0xFFFFE5F7),
      "icon": Icons.record_voice_over,
      "keywords": ["Opinión", "Voz", "Escucha", "Inclusión"],
    },
    {
      "titulo": "Protección",
      "def": "Derecho a estar seguros contra cualquier daño.",
      "color": const Color(0xFFE5FFFF),
      "icon": Icons.shield_moon,
      "keywords": ["Seguridad", "Refugio", "Cuidado", "Paz"],
    },
    {
      "titulo": "Igualdad",
      "def": "Derecho a ser tratados igual sin importar nada.",
      "color": const Color(0xFFF1FFE5),
      "icon": Icons.balance,
      "keywords": ["Inclusión", "Equidad", "Respeto", "Justicia"],
    },
    {
      "titulo": "Expresión",
      "def": "Derecho a buscar y compartir información e ideas.",
      "color": const Color(0xFFFFEEE5),
      "icon": Icons.chat_bubble_rounded,
      "keywords": ["Ideas", "Comunicación", "Escucha", "Creatividad"],
    },
    {
      "titulo": "Buen Trato",
      "def": "Derecho a una crianza basada en el respeto.",
      "color": const Color(0xFFE5E7FF),
      "icon": Icons.volunteer_activism,
      "keywords": ["No violencia", "Afecto", "Paz", "Respeto", "Cuidado"],
    },
    {
      "titulo": "Nacionalidad",
      "def": "Derecho a pertenecer a un país.",
      "color": const Color(0xFFFFF0F0),
      "icon": Icons.public,
      "keywords": ["País", "Registro", "Ciudadanía", "Nombre", "Identidad"],
    },
    {
      "titulo": "Vivienda",
      "def": "Derecho a tener una casa limpia y segura.",
      "color": const Color(0xFFE5FAFF),
      "icon": Icons.home_rounded,
      "keywords": ["Techo", "Higiene", "Estabilidad", "Bienestar", "Seguridad"],
    },
    {
      "titulo": "Alimentación",
      "def": "Derecho a comer sano cada día.",
      "color": const Color(0xFFFFF9E5),
      "icon": Icons.restaurant,
      "keywords": ["Comida", "Dieta", "Crecimiento", "Salud", "Bienestar"],
    },
    {
      "titulo": "Auxilio",
      "def": "Derecho a ser primeros en emergencias.",
      "color": const Color(0xFFFFE5E5),
      "icon": Icons.emergency,
      "keywords": ["Prioridad", "Socorro", "Rescate", "Seguridad", "Cuidado"],
    },
    {
      "titulo": "Integración",
      "def": "Derecho a vivir plenamente con discapacidad.",
      "color": const Color(0xFFE5FFE5),
      "icon": Icons.accessibility_new,
      "keywords": ["Habilidad", "Apoyo", "Acceso", "Inclusión", "Igualdad"],
    },
    {
      "titulo": "Vida",
      "def": "Derecho a que se respete su existencia.",
      "color": const Color(0xFFFFE5FB),
      "icon": Icons.spa,
      "keywords": ["Nacimiento", "Futuro", "Bienestar", "Salud"],
    },
    {
      "titulo": "Intimidad",
      "def": "Derecho a tener una vida privada.",
      "color": const Color(0xFFEBEEFF),
      "icon": Icons.lock_person,
      "keywords": ["Privacidad", "Espacio", "Secreto", "Seguridad"],
    },
    {
      "titulo": "Información",
      "def": "Derecho a libros y medios adecuados.",
      "color": const Color(0xFFF0FFE5),
      "icon": Icons.library_books,
      "keywords": ["Lectura", "Medios", "Verdad", "Educación"],
    },
    {
      "titulo": "Cultura",
      "def": "Derecho a su lengua y tradiciones.",
      "color": const Color(0xFFFFF5E5),
      "icon": Icons.palette,
      "keywords": ["Arte", "Lenguaje", "Costumbres", "Respeto", "Desarrollo"],
    },
    {
      "titulo": "No Violencia",
      "def": "Derecho a ser protegidos contra el abandono.",
      "color": const Color(0xFFFFEBF0),
      "icon": Icons.handshake,
      "keywords": ["Denuncia", "Refugio", "Justicia", "Paz", "Protección"],
    },
  ];

  List<Map<String, dynamic>> _resultadosBusqueda = [];

  @override
  void initState() {
    super.initState();
    _resultadosBusqueda = _derechosInfo;
  }

  // LOGICA PARA REGISTRAR LA CONSULTA (INVESTIGADORA)
  void _registrarConsulta() {
    int consultasActuales = box.get('consultas_diccionario', defaultValue: 0);
    box.put('consultas_diccionario', consultasActuales + 1);
  }

  void _filtrarBusqueda(String value) {
    setState(() {
      final query = value.toLowerCase();
      _resultadosBusqueda = _derechosInfo.where((derecho) {
        final tituloMatch = derecho['titulo']!.toLowerCase().contains(query);
        final keywordMatch = (derecho['keywords'] as List<String>).any(
          (k) => k.toLowerCase().contains(query),
        );
        return tituloMatch || keywordMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFD),
      appBar: AppBar(
        title: Text(
          "Biblioteca de Derechos",
          style: TextStyle(
            color: Colors.indigo[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.indigo[900]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _filtrarBusqueda,
                decoration: InputDecoration(
                  hintText: "Busca por derecho o palabra clave...",
                  hintStyle: TextStyle(color: Colors.indigo[100], fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.indigo[200],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: _resultadosBusqueda.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: _resultadosBusqueda.length,
                    itemBuilder: (context, index) {
                      final derecho = _resultadosBusqueda[index];
                      return _buildRealCard(derecho);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.indigo[50]),
          const SizedBox(height: 15),
          Text(
            "No encontramos ese derecho...\n¡Intenta con otra palabra!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.indigo[200], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRealCard(Map<String, dynamic> derecho) {
    return GestureDetector(
      onTap: () {
        _registrarConsulta(); // <-- Se activa el contador aquí
        _mostrarDetalleCute(derecho);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: (derecho['color'] as Color).withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (derecho['color'] as Color).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: derecho['color'],
                shape: BoxShape.circle,
              ),
              child: Icon(
                derecho['icon'],
                size: 35,
                color: Colors.indigo[900]?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              derecho['titulo']!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalleCute(Map<String, dynamic> derecho) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.elasticOut.transform(anim1.value);
        return Transform.scale(
          scale: curvedValue,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    derecho['icon'],
                    size: 60,
                    color: (derecho['color'] as Color).withOpacity(0.8),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    derecho['titulo'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    alignment: WrapAlignment.center,
                    children: (derecho['keywords'] as List<String>)
                        .map(
                          (word) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (derecho['color'] as Color).withOpacity(
                                0.3,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "#$word",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[700],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    derecho['def'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.indigo[400],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: derecho['color'],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      "Entendido",
                      style: TextStyle(
                        color: Colors.indigo[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
