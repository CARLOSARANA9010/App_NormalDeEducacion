import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PerfilScreen extends StatefulWidget {
  final String nombreAlumna;

  const PerfilScreen({super.key, required this.nombreAlumna});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final box = Hive.box('box_reflexiones');

  @override
  void initState() {
    super.initState();
    _cargarFoto();
  }

  // --- FUNCIÓN DE SEGURIDAD PARA FECHAS ---
  DateTime _parseFechaSegura(dynamic fecha) {
    if (fecha == null || fecha.toString().isEmpty) return DateTime.now();
    String f = fecha.toString();
    try {
      // Intenta el formato ISO (nuevo)
      return DateTime.parse(f);
    } catch (_) {
      try {
        // Intenta el formato DD/MM/YYYY (viejo)
        List<String> p = f.split('/');
        if (p.length == 3) {
          return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
        }
      } catch (e) {
        debugPrint("Error parseando fecha en Perfil: $f");
      }
      return DateTime.now();
    }
  }

  void _cargarFoto() {
    String? pathGuardado = box.get('foto_perfil');
    if (pathGuardado != null && pathGuardado.isNotEmpty) {
      setState(() {
        _imageFile = File(pathGuardado);
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (selectedImage != null) {
      setState(() {
        _imageFile = File(selectedImage.path);
      });
      await box.put('foto_perfil', selectedImage.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List notasRaw = box.get('lista_notas') ?? [];
    int totalNotas = notasRaw.length;
    int consultasDiccionario = box.get('consultas_diccionario') ?? 0;

    // --- LÓGICA DE ESCANEO DE LOGROS (BLINDADA) ---
    bool tieneNotaLarga = notasRaw.any(
      (n) => (n['contenido'] ?? "").length > 400,
    );

    bool tieneMuchosDerechos = notasRaw.any(
      (n) => (n['derechos'] as List? ?? []).length >= 3,
    );

    // Aquí usamos la función segura para evitar el crash
    bool esMadrugadora = notasRaw.any((n) {
      DateTime fecha = _parseFechaSegura(n['fecha']);
      return fecha.hour >= 5 && fecha.hour < 8;
    });

    bool esNoctambula = notasRaw.any((n) {
      DateTime fecha = _parseFechaSegura(n['fecha']);
      return fecha.hour >= 21 || fecha.hour < 1;
    });

    int notasPerfectas = notasRaw
        .where((n) => n['analisis_perfecto'] == true)
        .length;

    // Lógica de Niveles
    String nivel = "Novato 🐣";
    Color colorNivel = Colors.orange;
    if (totalNotas >= 20) {
      nivel = "Master Pedagógico 🏆";
      colorNivel = Colors.amber;
    } else if (totalNotas >= 10) {
      nivel = "Avanzado ⭐";
      colorNivel = Colors.teal;
    } else if (totalNotas >= 5) {
      nivel = "Aprendiz 📚";
      colorNivel = Colors.blue;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: Colors.indigo[900],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.indigo[900]!, Colors.indigo[800]!],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white24,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : null,
                            child: _imageFile == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.teal[400],
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.nombreAlumna,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorNivel.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorNivel.withOpacity(0.5)),
                      ),
                      child: Text(
                        nivel,
                        style: TextStyle(
                          color: colorNivel,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Resumen de Actividad",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildStatCard(
                        "Notas",
                        "$totalNotas",
                        Icons.edit_note,
                        Colors.blue,
                      ),
                      const SizedBox(width: 15),
                      _buildStatCard(
                        "Perfectas",
                        "$notasPerfectas",
                        Icons.star,
                        Colors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Muro de Logros",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildLogroTile(
                    "Primer Paso",
                    "Tu primer registro",
                    totalNotas >= 1,
                    Icons.auto_awesome,
                  ),
                  _buildLogroTile(
                    "Constancia",
                    "Llegaste a 10 notas",
                    totalNotas >= 10,
                    Icons.trending_up,
                  ),
                  _buildLogroTile(
                    "Perfecto!",
                    "Derechos correctos a la primera",
                    notasPerfectas >= 1,
                    Icons.verified,
                  ),
                  _buildLogroTile(
                    "Ojo Clínico",
                    "Detectaste 3+ derechos",
                    tieneMuchosDerechos,
                    Icons.psychology,
                  ),
                  _buildLogroTile(
                    "Inspirada",
                    "Escribiste una nota detallada",
                    tieneNotaLarga,
                    Icons.history_edu,
                  ),
                  _buildLogroTile(
                    "Madrugadora",
                    "Registro antes de las 8 AM",
                    esMadrugadora,
                    Icons.wb_sunny,
                  ),
                  _buildLogroTile(
                    "Noctámbula",
                    "Reflexión antes de dormir",
                    esNoctambula,
                    Icons.dark_mode,
                  ),
                  _buildLogroTile(
                    "Investigadora",
                    "Diccionario 5 veces",
                    consultasDiccionario >= 5,
                    Icons.menu_book,
                  ),
                  _buildLogroTile(
                    "Guardián Infantil",
                    "25 notas registradas",
                    totalNotas >= 25,
                    Icons.shield,
                  ),
                  _buildLogroTile(
                    "Excelencia",
                    "10 notas perfectas",
                    notasPerfectas >= 10,
                    Icons.workspace_premium,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              valor,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogroTile(
    String titulo,
    String desc,
    bool check,
    IconData icono,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: check ? Colors.white : Colors.grey[100]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: check ? Colors.indigo.withOpacity(0.1) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: check ? Colors.amber[50] : Colors.grey[200],
            child: Icon(
              icono,
              color: check ? Colors.amber[700] : Colors.grey[400],
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: check ? Colors.indigo[900] : Colors.grey[500],
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: check ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          if (check)
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ),
    );
  }
}
