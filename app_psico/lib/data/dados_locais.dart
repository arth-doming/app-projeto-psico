import '../models/paciente.dart';
import '../models/consulta.dart';
import '../models/evolucao.dart';

final List<Paciente> pacientesLocais = [
  Paciente(
    id: '1',
    nome: 'Ana Clara Souza',
    telefone: '(11) 98765-4321',
    email: 'ana.souza@email.com',
    dataNascimento: DateTime(1990, 3, 15),
    observacoes: 'Paciente com histórico de ansiedade. Prefere sessões pela manhã.',
  ),
  Paciente(
    id: '2',
    nome: 'Bruno Mendes',
    telefone: '(11) 91234-5678',
    email: 'bruno.mendes@email.com',
    dataNascimento: DateTime(1985, 7, 22),
    observacoes: 'Em tratamento para depressão leve. Faz uso de medicação.',
  ),
  Paciente(
    id: '3',
    nome: 'Carla Ferreira',
    telefone: '(11) 99876-5432',
    email: 'carla.f@email.com',
    dataNascimento: DateTime(1998, 11, 5),
    observacoes: 'Início recente do tratamento. Questões relacionadas a autoestima.',
  ),
  Paciente(
    id: '4',
    nome: 'Diego Ramos',
    telefone: '(11) 97654-3210',
    email: 'diego.ramos@email.com',
    dataNascimento: DateTime(1992, 1, 30),
    observacoes: '',
  ),
];

final List<Consulta> consultasLocais = [
  Consulta(
    id: 'c1',
    pacienteId: '1',
    pacienteNome: 'Ana Clara Souza',
    dataHora: DateTime.now().copyWith(hour: 9, minute: 0),
    status: StatusConsulta.confirmada,
  ),
  Consulta(
    id: 'c2',
    pacienteId: '2',
    pacienteNome: 'Bruno Mendes',
    dataHora: DateTime.now().copyWith(hour: 10, minute: 0),
    status: StatusConsulta.agendada,
  ),
  Consulta(
    id: 'c3',
    pacienteId: '3',
    pacienteNome: 'Carla Ferreira',
    dataHora: DateTime.now().add(const Duration(days: 1)).copyWith(hour: 14, minute: 0),
    status: StatusConsulta.agendada,
  ),
  Consulta(
    id: 'c4',
    pacienteId: '4',
    pacienteNome: 'Diego Ramos',
    dataHora: DateTime.now().add(const Duration(days: 2)).copyWith(hour: 16, minute: 0),
    status: StatusConsulta.agendada,
  ),
  Consulta(
    id: 'c5',
    pacienteId: '1',
    pacienteNome: 'Ana Clara Souza',
    dataHora: DateTime.now().subtract(const Duration(days: 7)).copyWith(hour: 9, minute: 0),
    status: StatusConsulta.realizada,
  ),
];

final List<Evolucao> evolucoesLocais = [
  Evolucao(
    id: 'e1',
    pacienteId: '1',
    pacienteNome: 'Ana Clara Souza',
    data: DateTime.now().subtract(const Duration(days: 7)),
    anotacao:
        'Paciente relatou melhora significativa nos episódios de ansiedade durante a semana. Utilizou as técnicas de respiração ensinadas na sessão anterior com bons resultados. Continuaremos trabalhando em reestruturação cognitiva.',
    consultaId: 'c5',
  ),
  Evolucao(
    id: 'e2',
    pacienteId: '2',
    pacienteNome: 'Bruno Mendes',
    data: DateTime.now().subtract(const Duration(days: 14)),
    anotacao:
        'Bruno chegou mais disposto hoje. Relatou que conseguiu sair de casa três vezes durante a semana, o que é um avanço considerável. Trabalhamos em estratégias de ativação comportamental.',
  ),
  Evolucao(
    id: 'e3',
    pacienteId: '1',
    pacienteNome: 'Ana Clara Souza',
    data: DateTime.now().subtract(const Duration(days: 14)),
    anotacao:
        'Segunda sessão. Paciente ainda demonstra resistência ao processo terapêutico, mas apresentou abertura ao falar sobre a relação familiar. Ponto importante a explorar nas próximas sessões.',
  ),
  Evolucao(
    id: 'e4',
    pacienteId: '3',
    pacienteNome: 'Carla Ferreira',
    data: DateTime.now().subtract(const Duration(days: 3)),
    anotacao:
        'Primeira sessão com Carla. Realizamos o acolhimento inicial e levantamento de demandas. Paciente apresenta baixa autoestima associada a comparações sociais frequentes. Proposta de trabalho com TCC.',
  ),
];
