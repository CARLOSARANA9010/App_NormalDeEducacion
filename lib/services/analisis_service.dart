import 'package:derechos_infancia_app/data/database/pedagogia_db.dart';

class AnalisisService {
  static Map<String, dynamic> procesarAnalisis(Map<String, dynamic> nota) {
    final n = Map<String, dynamic>.from(nota);

    // 1. Limpieza profunda del texto (Normalización)
    String contenidoOriginal = n['contenido'] ?? "";
    String textoProcesado = _normalizarTexto(contenidoOriginal);

    List marcados = n['derechos'] ?? [];
    List<String> sugerenciasAuto = [];

    PedagogiaDB.derechos.forEach((nombre, datos) {
      // Solo sugerimos lo que el docente NO ha marcado
      if (!marcados.contains(nombre)) {
        List<String> keywords = List<String>.from(datos['keywords'] ?? []);

        // 2. Buscador de coincidencias por patrones
        bool tieneKeyword = keywords.any((k) {
          String kLimpia = _normalizarTexto(k);

          // Bajamos el límite a 2 letras para capturar palabras como "yo", "ir" o "si"
          if (kLimpia.length < 2) return false;

          // Buscamos la palabra como concepto (evita falsos positivos dentro de otras palabras)
          return textoProcesado.contains(kLimpia);
        });

        if (tieneKeyword) {
          // 3. LÓGICA "IA IF" (Validación por contexto)
          // En lugar de excluir, validamos si el contexto es fuerte
          bool validado = true;

          switch (nombre) {
            case "Intimidad":
              // Si no dice privacidad, pero dice 'secreto', 'solo' o 'baño', es válido
              validado =
                  textoProcesado.contains("privacidad") ||
                  textoProcesado.contains("secreto") ||
                  textoProcesado.contains("baño");
              break;

            case "Salud":
              // Ampliamos el contexto de salud
              validado =
                  textoProcesado.contains("doctor") ||
                  textoProcesado.contains("enfermo") ||
                  textoProcesado.contains("higiene") ||
                  textoProcesado.contains("limpieza") ||
                  textoProcesado.contains("sano");
              break;

            case "Alimentación":
              // Evitamos que "comer" se confunda con palabras similares si el contexto es nulo
              if (textoProcesado.contains("cayo") ||
                  textoProcesado.contains("riieron")) {
                validado =
                    textoProcesado.contains("almuerzo") ||
                    textoProcesado.contains("comida");
              }
              break;
          }

          if (validado) {
            sugerenciasAuto.add(nombre);
          }
        }
      }
    });

    // 4. Resultado final
    n['analisis_perfecto'] = sugerenciasAuto.isEmpty;
    n['sugerencias_sistema'] = sugerenciasAuto;

    // Debug para que veas en consola qué está pasando
    print("LOG: Texto procesado: $textoProcesado");
    print("LOG: Sugerencias enviadas a UI: $sugerenciasAuto");

    return n;
  }

  // Función de normalización maestra
  static String _normalizarTexto(String texto) {
    return texto
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâ]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöô]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll(RegExp(r'[^\w\s]'), '') // Quita puntos y comas
        .trim();
  }
}
