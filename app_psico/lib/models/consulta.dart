enum StatusConsulta { agendada, confirmada, cancelada, realizada }

class Consulta {
  final String id;
  final String pacienteId;
  final String pacienteNome;
  final DateTime dataHora;
  final int duracaoMinutos;
  StatusConsulta status;
  String observacoes;

  Consulta({
    required this.id,
    required this.pacienteId,
    required this.pacienteNome,
    required this.dataHora,
    this.duracaoMinutos = 50,
    this.status = StatusConsulta.agendada,
    this.observacoes = '',
  });

  String get statusLabel {
    switch (status) {
      case StatusConsulta.agendada:
        return 'Agendada';
      case StatusConsulta.confirmada:
        return 'Confirmada';
      case StatusConsulta.cancelada:
        return 'Cancelada';
      case StatusConsulta.realizada:
        return 'Realizada';
    }
  }
}
