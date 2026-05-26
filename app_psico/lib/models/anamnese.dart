class Anamnese {
  final String id;
  final String pacienteId;
  final DateTime data;
  final String queixaPrincipal;
  final String inicioProblem;
  final String consequencias;
  final String infanciaAdolescencia;
  final String tratamentosAnteriores;
  final String pontosFortesRecursos;
  final String aspectosFisicos;
  final String expectativas;

  Anamnese({
    required this.id,
    required this.pacienteId,
    required this.data,
    this.queixaPrincipal = '',
    this.inicioProblem = '',
    this.consequencias = '',
    this.infanciaAdolescencia = '',
    this.tratamentosAnteriores = '',
    this.pontosFortesRecursos = '',
    this.aspectosFisicos = '',
    this.expectativas = '',
  });
}