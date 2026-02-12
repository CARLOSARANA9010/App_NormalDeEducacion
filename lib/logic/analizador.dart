import '../data/derechos_data.dart'; // Donde pegaste la lista de los 20

List<Map<String, dynamic>> vincularTextoConDerechos(String textoAlumno) {
  List<Map<String, dynamic>> derechosEncontrados = [];
  String textoLimpio = textoAlumno.toLowerCase();

  for (var derecho in derechosInfancia) {
    // Buscamos si alguna palabra clave del derecho está en el texto de la alumna
    bool existeCoincidencia = derecho['palabras_clave'].any((palabra) => 
      textoLimpio.contains(palabra.toLowerCase())
    );

    if (existeCoincidencia) {
      derechosEncontrados.add(derecho);
    }
  }
  return derechosEncontrados;
}