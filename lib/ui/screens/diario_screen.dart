import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analisis_screen.dart';
import 'package:derechos_infancia_app/data/database/pedagogia_db.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DiarioScreen extends StatefulWidget {
  const DiarioScreen({super.key});

  @override
  _DiarioScreenState createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  final _myBox = Hive.box('box_reflexiones');
  List<Map<String, dynamic>> _notasDeEstudio = [];
  String _nombreDocente = "Docente";

  @override
  void initState() {
    super.initState();
    _cargarNotasDeHive();
    _cargarNombre();
  }

  void _cargarNombre() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombreDocente = prefs.getString('nombre_alumna') ?? "Docente";
    });
  }

  void _cargarNotasDeHive() {
    final datosRaw = _myBox.get('lista_notas');
    if (datosRaw != null) {
      setState(() {
        _notasDeEstudio = List<Map<String, dynamic>>.from(
          (datosRaw as List).map((item) => Map<String, dynamic>.from(item)),
        );
        _notasDeEstudio.sort(
          (a, b) => _parseFecha(b['fecha']).compareTo(_parseFecha(a['fecha'])),
        );
      });
    }
  }

  DateTime _parseFecha(String fecha) {
    try {
      if (fecha.contains('T')) return DateTime.parse(fecha);
      List<String> partes = fecha.split('/');
      return DateTime(
        int.parse(partes[2]),
        int.parse(partes[1]),
        int.parse(partes[0]),
      );
    } catch (e) {
      return DateTime.now();
    }
  }

  String _formatearFechaVista(String fechaRaw) {
    DateTime dt = _parseFecha(fechaRaw);
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  Future<void> _guardarEnHive() async {
    await _myBox.put('lista_notas', _notasDeEstudio);
  }

  // --- UI DIÁLOGOS ---

  void _explicarMetaSemanal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Row(
          children: [
            Icon(Icons.tips_and_updates, color: Colors.orange[400]),
            const SizedBox(width: 10),
            const Text(
              "Meta Semanal",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Para un seguimiento pedagógico efectivo, se recomienda realizar al menos 5 registros semanales.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }

  void _mostrarTextoCompleto(Map<String, dynamic> nota) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          "Observación Completa",
          style: TextStyle(
            color: Colors.indigo[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            nota['contenido'] ?? "",
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          "Mi Diario",
          style: TextStyle(
            color: Colors.indigo[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf, color: Colors.red[400]),
            onPressed: () =>
                _crearArchivoPDF("REPORTE PEDAGÓGICO", _notasDeEstudio),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _notasDeEstudio.isEmpty
                ? Center(
                    child: Text(
                      "Sin registros aún",
                      style: TextStyle(color: Colors.indigo[100]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _notasDeEstudio.length,
                    itemBuilder: (context, index) =>
                        _buildNotaCard(_notasDeEstudio[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnalisisScreen()),
          );
          if (res != null) {
            setState(() {
              final n = Map<String, dynamic>.from(res);
              n['fecha'] = DateTime.now().toIso8601String();

              // Lógica de Perfección Inteligente
              String textoLower = (n['contenido'] ?? "")
                  .toLowerCase()
                  .replaceAll(RegExp(r'[.,!?;()]'), ' ');
              List<String> palabras = textoLower.split(RegExp(r'\s+'));
              List marcados = n['derechos'] ?? [];
              List<String> sugerenciasAuto = [];

              PedagogiaDB.derechos.forEach((nombre, datos) {
                if (!marcados.contains(nombre)) {
                  List<String> keywords = List<String>.from(
                    datos['keywords'] ?? [],
                  );
                  if (keywords.any((k) => palabras.contains(k.toLowerCase()))) {
                    if (nombre == "Alimentación" &&
                        (textoLower.contains("cayó") ||
                            textoLower.contains("riieron")))
                      return;
                    sugerenciasAuto.add(nombre);
                  }
                }
              });

              n['analisis_perfecto'] = sugerenciasAuto.isEmpty;
              _notasDeEstudio.insert(0, n);
              _guardarEnHive();

              // Logro Investigadora
              if (_notasDeEstudio.length == 5) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.indigo[900],
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      "🏆 ¡Felicidades $_nombreDocente! Logro 'Investigadora' obtenido.",
                    ),
                  ),
                );
              }
            });
          }
        },
        backgroundColor: Colors.indigo[900],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nuevo Registro",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Total", "${_notasDeEstudio.length}", null),
          _statItem("Docente", _nombreDocente, Icons.person),
          _statItem(
            "Semana",
            "${_notasDeEstudio.length}/5",
            Icons.search_rounded,
          ),
        ],
      ),
    );
  }

  Widget _statItem(
    String label,
    String value,
    IconData? icon,
  ) => GestureDetector(
    onTap: label == "Semana" ? _explicarMetaSemanal : null,
    child: Column(
      children: [
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
              ),
            ),
            if (icon != null) Icon(icon, size: 14, color: Colors.indigo[300]),
          ],
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    ),
  );

  Widget _buildNotaCard(Map<String, dynamic> nota) {
    List<dynamic> derechos = nota['derechos'] ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatearFechaVista(nota['fecha'] ?? ""),
                style: TextStyle(
                  color: Colors.indigo[200],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (nota['analisis_perfecto'] == true)
                const Icon(Icons.verified, color: Colors.green, size: 16),
              TextButton(
                onPressed: () => _mostrarTextoCompleto(nota),
                child: const Text("Ver nota"),
              ),
            ],
          ),
          Text(
            nota['contenido'] ?? "",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.indigo[900], fontSize: 15),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            children: derechos
                .map(
                  (d) => Chip(
                    label: Text(
                      "#${d.toString().toLowerCase()}",
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _mostrarAnalisisCompleto(nota),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text("Ver Análisis Pedagógico"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarAnalisisCompleto(Map<String, dynamic> nota) {
    List<dynamic> marcados = nota['derechos'] ?? [];
    String textoCuerpo = (nota['contenido'] ?? "").toLowerCase();
    List<String> sugerencias = [];

    PedagogiaDB.derechos.forEach((nombre, datos) {
      if (!marcados.contains(nombre)) {
        List<String> keywords = List<String>.from(datos['keywords'] ?? []);
        if (keywords.any((k) => textoCuerpo.contains(k)))
          sugerencias.add(nombre);
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => Container(
        height: MediaQuery.of(c).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
        ),
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Análisis Pedagógico",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              const SizedBox(height: 25),
              _itemIcono("💡", _obtenerFeedbackPro(textoCuerpo)),
              const SizedBox(height: 30),
              const Text(
                "📚 LO QUE IDENTIFICASTE:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...marcados.map(
                (d) => _buildDetailBox(
                  d,
                  PedagogiaDB.derechos[d]?['significado'] ?? "",
                  false,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "🧐 TE SUGERIMOS INTEGRAR:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              ...sugerencias.map(
                (d) => _buildDetailBox(
                  d,
                  PedagogiaDB.derechos[d]?['sugerencia'] ?? "",
                  true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailBox(String titulo, String desc, bool esSugerencia) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: esSugerencia
            ? Colors.orange.withOpacity(0.05)
            : Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: esSugerencia ? Colors.orange[900] : Colors.indigo[900],
            ),
          ),
          Text(desc, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  String _obtenerFeedbackPro(String t) {
    String texto = t.toLowerCase();
    if (texto.contains("cayó") || texto.contains("riieron"))
      return "¡$_nombreDocente! Gran sensibilidad al detectar este conflicto de convivencia.";
    if (texto.contains("jug") || texto.contains("recreo"))
      return "Excelente enfoque $_nombreDocente. El juego es un derecho vital.";
    return "Buen registro $_nombreDocente, documentas el desarrollo integral con éxito.";
  }

  Widget _itemIcono(String i, String t) => Row(
    children: [
      Text(i, style: const TextStyle(fontSize: 22)),
      const SizedBox(width: 15),
      Expanded(
        child: Text(t, style: const TextStyle(fontStyle: FontStyle.italic)),
      ),
    ],
  );

  Future<void> _crearArchivoPDF(
    String titulo,
    List<Map<String, dynamic>> notas,
  ) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    titulo,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo900,
                    ),
                  ),
                  pw.Text(
                    "Reporte de Observaciones Pedagógicas",
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "Fecha: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                  ),
                  pw.Text("Registros: ${notas.length}"),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Divider(thickness: 2, color: PdfColors.indigo900),
          pw.SizedBox(height: 20),
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(80),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(1),
            },
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.indigo900),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      "FECHA",
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      "OBSERVACIÓN",
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      "DERECHOS",
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              ...notas.map(
                (n) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        _formatearFechaVista(n['fecha'] ?? ""),
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        n['contenido'] ?? "",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        (n['derechos'] as List).join(", "),
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.indigo700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 40),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 150,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.black, width: 1),
                ),
              ),
              padding: const pw.EdgeInsets.only(top: 5),
              child: pw.Center(
                child: pw.Text(
                  "Firma del Docente",
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name:
          'Reporte_${_nombreDocente}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}
