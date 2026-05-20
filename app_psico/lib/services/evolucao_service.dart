import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/evolucao.dart';

class EvolucaoService {
  static CollectionReference get _col => FirebaseFirestore.instance
      .collection('usuarios')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('evolucoes');

  static Stream<List<Evolucao>> listarPorPaciente(String pacienteId) {
    return _col
        .where('pacienteId', isEqualTo: pacienteId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _fromDoc(d)).toList());
  }

  static Stream<List<Evolucao>> listarTodas() {
    return _col
        .orderBy('data', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _fromDoc(d)).toList());
  }

  static Future<void> salvar(Evolucao e) async {
    await _col.doc(e.id).set({
      'pacienteId': e.pacienteId,
      'pacienteNome': e.pacienteNome,
      'data': e.data.toIso8601String(),
      'anotacao': e.anotacao,
      'consultaId': e.consultaId ?? '',
    });
  }

  static Future<void> atualizar(Evolucao e) async {
    await _col.doc(e.id).update({'anotacao': e.anotacao});
  }

  static Future<void> deletar(String id) async {
    await _col.doc(id).delete();
  }

  static Future<void> deletarPorPaciente(String pacienteId) async {
    final snap = await _col
        .where('pacienteId', isEqualTo: pacienteId)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  static Evolucao _fromDoc(DocumentSnapshot d) {
    final data = d.data() as Map<String, dynamic>;
    return Evolucao(
      id: d.id,
      pacienteId: data['pacienteId'] ?? '',
      pacienteNome: data['pacienteNome'] ?? '',
      data: DateTime.parse(data['data']),
      anotacao: data['anotacao'] ?? '',
      consultaId: data['consultaId'],
    );
  }
}