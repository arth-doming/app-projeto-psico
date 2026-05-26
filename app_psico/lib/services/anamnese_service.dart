import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/anamnese.dart';

class AnamneseService {
  static CollectionReference get _col => FirebaseFirestore.instance
      .collection('usuarios')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('anamneses');

  static Future<Anamnese?> buscarPorPaciente(String pacienteId) async {
    final snap = await _col
        .where('pacienteId', isEqualTo: pacienteId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return _fromDoc(snap.docs.first);
  }

  static Future<void> salvar(Anamnese a) async {
    await _col.doc(a.id).set({
      'pacienteId': a.pacienteId,
      'data': a.data.toIso8601String(),
      'queixaPrincipal': a.queixaPrincipal,
      'inicioProblem': a.inicioProblem,
      'consequencias': a.consequencias,
      'infanciaAdolescencia': a.infanciaAdolescencia,
      'tratamentosAnteriores': a.tratamentosAnteriores,
      'pontosFortesRecursos': a.pontosFortesRecursos,
      'aspectosFisicos': a.aspectosFisicos,
      'expectativas': a.expectativas,
    });
  }

  static Anamnese _fromDoc(DocumentSnapshot d) {
    final data = d.data() as Map<String, dynamic>;
    return Anamnese(
      id: d.id,
      pacienteId: data['pacienteId'] ?? '',
      data: DateTime.parse(data['data']),
      queixaPrincipal: data['queixaPrincipal'] ?? '',
      inicioProblem: data['inicioProblem'] ?? '',
      consequencias: data['consequencias'] ?? '',
      infanciaAdolescencia: data['infanciaAdolescencia'] ?? '',
      tratamentosAnteriores: data['tratamentosAnteriores'] ?? '',
      pontosFortesRecursos: data['pontosFortesRecursos'] ?? '',
      aspectosFisicos: data['aspectosFisicos'] ?? '',
      expectativas: data['expectativas'] ?? '',
    );
  }
}