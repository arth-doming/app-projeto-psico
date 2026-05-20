import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/consulta.dart';

class ConsultaService {
  static CollectionReference get _col => FirebaseFirestore.instance
      .collection('usuarios')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('consultas');

  static Stream<List<Consulta>> listar() {
    return _col.orderBy('dataHora').snapshots().map((snap) =>
        snap.docs.map((d) => _fromDoc(d)).toList());
  }

  static Future<void> salvar(Consulta c) async {
    await _col.doc(c.id).set({
      'pacienteId': c.pacienteId,
      'pacienteNome': c.pacienteNome,
      'dataHora': c.dataHora.toIso8601String(),
      'duracaoMinutos': c.duracaoMinutos,
      'status': c.status.name,
      'observacoes': c.observacoes,
    });
  }

  static Future<void> atualizarStatus(String id, StatusConsulta status) async {
    await _col.doc(id).update({'status': status.name});
  }

  static Future<void> deletar(String id) async {
    await _col.doc(id).delete();
  }

  static Consulta _fromDoc(DocumentSnapshot d) {
    final data = d.data() as Map<String, dynamic>;
    return Consulta(
      id: d.id,
      pacienteId: data['pacienteId'] ?? '',
      pacienteNome: data['pacienteNome'] ?? '',
      dataHora: DateTime.parse(data['dataHora']),
      duracaoMinutos: data['duracaoMinutos'] ?? 50,
      status: StatusConsulta.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => StatusConsulta.agendada,
      ),
      observacoes: data['observacoes'] ?? '',
    );
  }
}