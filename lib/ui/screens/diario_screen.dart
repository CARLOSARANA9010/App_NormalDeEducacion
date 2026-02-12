import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'analisis_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DiarioScreen extends StatefulWidget {
  @override
  _DiarioScreenState createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  final _myBox = Hive.box('box_reflexiones');
  List<Map<String, dynamic>> _notasDeEstudio = [];

  @override
  void initState() {
    super.initState();
    _cargarNotasDeHive();
  }

  // --- PERSISTENCIA Y CARGA ---
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

  Future<void> _guardarEnHive() async {
    await _myBox.put('lista_notas', _notasDeEstudio);
    await _myBox.flush();
  }

  // --- UTILIDADES ---
  String _limpiarEmojis(String texto) {
    if (texto == null) return "";
    return texto.replaceAll(
      RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E6}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true,
      ),
      '',
    );
  }

  String _obtenerRangoSemana(DateTime fecha) {
    List<String> meses = [
      "",
      "Ene",
      "Feb",
      "Mar",
      "Abr",
      "May",
      "Jun",
      "Jul",
      "Ago",
      "Sep",
      "Oct",
      "Nov",
      "Dic",
    ];
    DateTime lunes = fecha.subtract(Duration(days: fecha.weekday - 1));
    DateTime viernes = lunes.add(Duration(days: 4));
    return "Semana de ${meses[lunes.month]} ${lunes.day} al ${viernes.day}";
  }

  // --- LÓGICA DE PDF CON MENÚ ---
  void _mostrarOpcionesPDF() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Exportar Reporte",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo[50],
                child: Icon(Icons.view_week, color: Colors.indigo),
              ),
              title: Text("Esta Semana"),
              subtitle: Text("Solo registros de los últimos 7 días"),
              onTap: () {
                Navigator.pop(context);
                String semanaActual = _obtenerRangoSemana(DateTime.now());
                final notas = _notasDeEstudio
                    .where(
                      (n) =>
                          _obtenerRangoSemana(_parseFecha(n['fecha'])) ==
                          semanaActual,
                    )
                    .toList();
                _crearArchivoPDF("REPORTE SEMANAL", notas);
              },
            ),
            Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange[50],
                child: Icon(Icons.history, color: Colors.orange),
              ),
              title: Text("Historial Completo"),
              subtitle: Text("Todas las notas guardadas"),
              onTap: () {
                Navigator.pop(context);
                _crearArchivoPDF("REPORTE HISTORICO TOTAL", _notasDeEstudio);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _crearArchivoPDF(
    String titulo,
    List<Map<String, dynamic>> lista,
  ) async {
    if (lista.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No hay notas para este reporte")));
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  titulo,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                pw.Text(
                  "Docente: Carlos",
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.Divider(thickness: 1),
              ],
            ),
          ),
          ...lista
              .map(
                (nota) => pw.Container(
                  margin: pw.EdgeInsets.only(top: 15),
                  padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border(
                      left: pw.BorderSide(width: 3, color: PdfColors.indigo900),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            "Fecha: ${nota['fecha']}",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            "Derechos: ${(nota['derechos'] ?? []).join(', ')}",
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.indigo700,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        "Observación:",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        _limpiarEmojis(nota['contenido'] ?? ""),
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        "Análisis Pedagógico:",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                          color: PdfColors.indigo900,
                        ),
                      ),
                      pw.Text(
                        _limpiarEmojis(nota['feedback'] ?? ""),
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: '${titulo.replaceAll(" ", "_")}_${DateTime.now().day}.pdf',
    );
  }

  // --- CONSTRUCCIÓN DE INTERFAZ ---
  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> grupos = {};
    for (var nota in _notasDeEstudio) {
      String rango = _obtenerRangoSemana(_parseFecha(nota['fecha']));
      if (!grupos.containsKey(rango)) grupos[rango] = [];
      grupos[rango]!.add(nota);
    }
    final nombresSemanas = grupos.keys.toList();

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FE),
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
            onPressed: _mostrarOpcionesPDF,
            tooltip: "Exportar PDF",
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(), // Aquí se muestra el contador actualizado
          Expanded(
            child: _notasDeEstudio.isEmpty
                ? Center(
                    child: Text(
                      "No hay registros aún",
                      style: TextStyle(color: Colors.indigo[100]),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(20),
                    itemCount: nombresSemanas.length,
                    itemBuilder: (context, index) {
                      String semana = nombresSemanas[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              semana.toUpperCase(),
                              style: TextStyle(
                                color: Colors.indigo[200],
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          ...grupos[semana]!
                              .map((nota) => _buildNotaCard(nota))
                              .toList(),
                          SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AnalisisScreen()),
          );
          if (resultado != null) {
            setState(() {
              final n = Map<String, dynamic>.from(resultado);
              n['fecha'] =
                  "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
              _notasDeEstudio.insert(0, n);
              _guardarEnHive();
            });
          }
        },
        backgroundColor: Colors.indigo[900],
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          "Nuevo Registro",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    // Cálculo para el contador de la semana
    String semanaActual = _obtenerRangoSemana(DateTime.now());
    int notasEstaSemana = _notasDeEstudio
        .where(
          (n) => _obtenerRangoSemana(_parseFecha(n['fecha'])) == semanaActual,
        )
        .length;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn("Total", _notasDeEstudio.length.toString()),
          _buildStatColumn("Esta Semana", "$notasEstaSemana/5"),
          _buildStatColumn(
            "Nivel",
            _notasDeEstudio.length > 5 ? "Experto" : "Novato",
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo[900],
          ),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildNotaCard(Map<String, dynamic> nota) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nota['fecha'],
            style: TextStyle(
              color: Colors.indigo[100],
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            nota['contenido'] ?? "",
            style: TextStyle(
              color: Colors.indigo[900],
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
