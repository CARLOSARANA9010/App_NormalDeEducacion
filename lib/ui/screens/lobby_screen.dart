import 'package:derechos_infancia_app/ui/screens/diario_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/scheduler.dart';
import 'analisis_screen.dart';
import 'diccionario_screen.dart';
import 'package:derechos_infancia_app/ui/screens/perfil_screen.dart';

class LobbyScreen extends StatefulWidget {
  final String nombreAlumna;
  const LobbyScreen({super.key, required this.nombreAlumna});

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen>
    with TickerProviderStateMixin {
  final List<String> _frases = [
    "Tu práctica de hoy garantiza un derecho mañana. ✨",
    "El juego es el trabajo más serio de la infancia. 🧩",
    "Escuchar a un niño es el primer paso para incluirlo. 👂",
    "Hoy estás transformando vidas. ❤️",
    "Donde hay un niño, hay un derecho que proteger. 🛡️",
    "La educación inclusiva no es un favor, es un derecho. 🌈",
    "Tu aula es el primer escenario de ciudadanía para ellos. 🏫",
    "Pequeños pasos en el aula dan grandes saltos en el futuro. 👣",
    "Tu paciencia es el lenguaje del amor pedagógico. 🌸",
    "Enseñar es dejar una huella en el corazón para siempre. 👣❤️",
    "Eres el faro que guía la curiosidad de tus alumnos. 🕯️",
    "La magia sucede cuando un niño se siente comprendido. 🪄",
    "Hoy es un gran día para descubrir un nuevo talento. ⭐",
    "Aprender a jugar es aprender a vivir en libertad. 🪁",
    "La infancia es el suelo donde se siembra la paz. 🌱",
    "Un niño que pregunta es un niño que confía en ti. 🗣️",
    "Mira el mundo con ojos de niño y encontrarás maravillas. 🎡",
    "Cada dibujo cuenta una historia; hoy sé parte de ella. 🎨",
    "La ternura es la técnica más avanzada de enseñanza. 🤗",
    "Tú no solo enseñas lecciones, tú construyes refugios. 🏠",
  ];

  int _indiceFrase = 0;
  Timer? _timerFrases;
  late AnimationController _slowFloatingController;

  @override
  void initState() {
    super.initState();
    _indiceFrase = math.Random().nextInt(_frases.length);
    _timerFrases = Timer.periodic(Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() => _indiceFrase = (_indiceFrase + 1) % _frases.length);
      }
    });
    _slowFloatingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timerFrases?.cancel();
    _slowFloatingController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN DE COLABORADORES ---
  void _mostrarColaboradores(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Derechos Infancia',
      applicationVersion: '1.2.0',
      applicationIcon: Icon(
        Icons.auto_stories,
        size: 50,
        color: Colors.indigo[900],
      ),
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "EQUIPO DE TRABAJO",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              Divider(),
              SizedBox(height: 10),
              Text(
                "• Carlos Adrian Arana Herrera",
                style: TextStyle(fontSize: 14),
              ),
              Text(
                "• Armando Josue Caamal Rosado",
                style: TextStyle(fontSize: 14),
              ),
              Text("• Carlos Eduardo Tuz Euan", style: TextStyle(fontSize: 14)),
              Text("• Carlos Rivera Rodriguez", style: TextStyle(fontSize: 14)),
              Text(
                "• ${widget.nombreAlumna} - Investigación Pedagógica",
                style: TextStyle(fontSize: 14),
              ),
              Text(
                "ITESCAM - Ingenieria en Sistemas Computacionales - Desarrollo de Software",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),
              Text(
                "Esta aplicación fue diseñada para facilitar la documentación "
                "de la práctica docente con enfoque en derechos humanos.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.indigo[900], size: 28),
            onPressed: () => _mostrarColaboradores(context),
            tooltip: "Colaboradores",
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Stack(
        children: [
          _FondoChibiFisico(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // --- SECCIÓN DE SALUDO CORREGIDA ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Text(
                        "¡Hola, ${widget.nombreAlumna}! 👋",
                        textAlign: TextAlign
                            .center, // Centra el texto si hay varias líneas
                        style: TextStyle(
                          fontSize: 26, // Reducido un poco para nombres largos
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                        ),
                        maxLines: 2, // Permite máximo 2 líneas
                        overflow: TextOverflow
                            .ellipsis, // Si es más largo, pone "..."
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "¿Qué aventura tendremos hoy?",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.indigo[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // -----------------------------------
                const Spacer(),

                // Bloque de la frase animada
                AnimatedBuilder(
                  animation: _slowFloatingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        10 *
                            math.sin(
                              _slowFloatingController.value * 2 * math.pi,
                            ),
                      ),
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45),
                    child: AnimatedSwitcher(
                      duration: const Duration(seconds: 2),
                      child: Text(
                        _frases[_indiceFrase],
                        key: ValueKey(_indiceFrase),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20, // Ajustado para evitar colisiones
                          color: Colors.indigo[800],
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          shadows: const [
                            Shadow(color: Colors.white, blurRadius: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Botonera inferior
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 50,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centra los botones
                    children: [
                      _buildChibiButton(
                        context,
                        "Reflexión",
                        Icons.auto_awesome,
                        Colors.purple[200]!,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const DiarioScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      _buildChibiButton(
                        context,
                        "Mi Perfil",
                        Icons.account_circle,
                        Colors.teal[300]!,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) =>
                                PerfilScreen(nombreAlumna: widget.nombreAlumna),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      _buildChibiButton(
                        context,
                        "Diccionario",
                        Icons.menu_book,
                        Colors.orange[200]!,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const DiccionarioScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChibiButton(
    BuildContext context,
    String titulo,
    IconData icono,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 50, color: color),
              SizedBox(height: 12),
              Text(
                titulo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- MOTOR DE FÍSICAS (Sin cambios, solo para que compile completo) ---
class _FondoChibiFisico extends StatefulWidget {
  @override
  __FondoChibiFisicoState createState() => __FondoChibiFisicoState();
}

class __FondoChibiFisicoState extends State<_FondoChibiFisico>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  List<IconParticle> particles = [];
  final int totalParticles = 10;

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    List<IconData> iconos = [
      Icons.child_friendly,
      Icons.face,
      Icons.star_border,
      Icons.palette_outlined,
      Icons.toys_outlined,
      Icons.music_note,
      Icons.auto_stories,
      Icons.cloud_outlined,
    ];
    for (int i = 0; i < totalParticles; i++) {
      particles.add(
        IconParticle(
          icon: iconos[random.nextInt(iconos.length)],
          x: random.nextDouble() * 300,
          y: random.nextDouble() * 600,
          vx: (random.nextDouble() - 0.5) * 1.5,
          vy: (random.nextDouble() - 0.5) * 1.5,
          radius: 30,
        ),
      );
    }
    _ticker = createTicker((elapsed) {
      if (mounted) {
        setState(() {
          _updatePhysics();
        });
      }
    })..start();
  }

  void _updatePhysics() {
    final size = MediaQuery.of(context).size;
    if (size.width == 0) return;
    for (int i = 0; i < particles.length; i++) {
      var p = particles[i];
      p.x += p.vx;
      p.y += p.vy;
      if (p.x < 0 || p.x > size.width - p.radius * 2) p.vx *= -1;
      if (p.y < 0 || p.y > size.height - p.radius * 2) p.vy *= -1;
      for (int j = i + 1; j < particles.length; j++) {
        var other = particles[j];
        double dx = other.x - p.x;
        double dy = other.y - p.y;
        double distance = math.sqrt(dx * dx + dy * dy);
        if (distance < p.radius + other.radius) {
          double tx = p.vx;
          double ty = p.vy;
          p.vx = other.vx;
          p.vy = other.vy;
          other.vx = tx;
          other.vy = ty;
        }
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2F1), Color(0xFFF3E5F5), Color(0xFFFFF9C4)],
        ),
      ),
      child: Stack(
        children: particles
            .map(
              (p) => Positioned(
                left: p.x,
                top: p.y,
                child: Opacity(
                  opacity: 0.12,
                  child: Icon(p.icon, size: p.radius * 2, color: Colors.indigo),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class IconParticle {
  IconData icon;
  double x, y, vx, vy, radius;
  IconParticle({
    required this.icon,
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
  });
}
