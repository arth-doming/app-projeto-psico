import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/paciente.dart';

class PacienteService {
  static CollectionReference get _col => FirebaseFirestore.instance
      .collection('usuarios')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('pacientes');

  static Stream<List<Paciente>> listar() {
    return _col.orderBy('nome').snapshots().map((snap) =>
        snap.docs.map((d) => _fromDoc(d)).toList());
  }

  static Future<void> salvar(Paciente p) async {
    await _col.doc(p.id).set({
      'nome': p.nome,
      'telefone': p.telefone,
      'email': p.email,
      'dataNascimento': p.dataNascimento.toIso8601String(),
      'observacoes': p.observacoes,
      'cpf': p.cpf, // ← novo campo
    });
  }

  static Future<void> deletar(String id) async {
    await _col.doc(id).delete();
  }

  static Paciente _fromDoc(DocumentSnapshot d) {
    final data = d.data() as Map<String, dynamic>;
    return Paciente(
      id: d.id,
      nome: data['nome'] ?? '',
      telefone: data['telefone'] ?? '',
      email: data['email'] ?? '',
      dataNascimento: DateTime.parse(data['dataNascimento']),
      observacoes: data['observacoes'] ?? '',
      cpf: data['cpf'] ?? '', // ← novo campo
    );
  }
}