class Evolucao {
  final String id;
  final String pacienteId;
  final String pacienteNome;
  final DateTime data;
  final String anotacao;
  final String? consultaId;

  Evolucao({
    required this.id,
    required this.pacienteId,
    required this.pacienteNome,
    required this.data,
    required this.anotacao,
    this.consultaId,
  });
}
