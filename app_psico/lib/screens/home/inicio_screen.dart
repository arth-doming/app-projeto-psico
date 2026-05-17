import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/dados_locais.dart';
import '../../models/consulta.dart';
import '../../models/evolucao.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  List<Consulta> get _consultasHoje => consultasLocais
      .where((c) => DateUtils.isSameDay(c.dataHora, DateTime.now()))
      .toList()
    ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

  List<Consulta> get _proximasConsultas => consultasLocais
      .where((c) =>
          c.dataHora.isAfter(DateTime.now()) &&
          !DateUtils.isSameDay(c.dataHora, DateTime.now()) &&
          c.status != StatusConsulta.cancelada)
      .toList()
    ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

  Color _corStatus(StatusConsulta status) {
    switch (status) {
      case StatusConsulta.agendada:
        return Colors.orange;
      case StatusConsulta.confirmada:
        return Colors.green;
      case StatusConsulta.cancelada:
        return Colors.red;
      case StatusConsulta.realizada:
        return Colors.grey;
    }
  }

  String _saudacao() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Bom dia! ';
    if (hora < 18) return 'Boa tarde! ';
    return 'Boa noite!';
  }

  @override
  Widget build(BuildContext context) {
    final hoje = _consultasHoje;
    final proximas = _proximasConsultas.take(3).toList();
    final realizadas = consultasLocais
        .where((c) => c.status == StatusConsulta.realizada)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _saudacao(),
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const Text(
            'Aqui está seu dia',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Cards de resumo
          Row(
            children: [
              _resumoCard(
                icon: Icons.today,
                label: 'Hoje',
                valor: '${hoje.length}',
                sub: 'consulta(s)',
                cor: const Color(0xFF7C6FCD),
              ),
              const SizedBox(width: 12),
              _resumoCard(
                icon: Icons.check_circle_outline,
                label: 'Realizadas',
                valor: '$realizadas',
                sub: 'no total',
                cor: Colors.green,
              ),
              const SizedBox(width: 12),
              _resumoCard(
                icon: Icons.people_outline,
                label: 'Pacientes',
                valor: '${pacientesLocais.length}',
                sub: 'cadastrados',
                cor: const Color(0xFF4CAADC),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Consultas de hoje
          _secao('Consultas de hoje'),
          if (hoje.isEmpty)
            _vazio('Nenhuma consulta agendada para hoje')
          else
            ...hoje.map((c) => _consultaCard(c)),

          // Próximas consultas
          if (proximas.isNotEmpty) ...[
            _secao('Próximas consultas'),
            ...proximas.map((c) => _consultaCard(c, mostrarData: true)),
          ],

          // Últimas evoluções
          _secao('Evoluções recentes'),
          if (evolucoesLocais.isEmpty)
            _vazio('Nenhuma evolução registrada ainda')
          else
            ...(evolucoesLocais.toList()
                  ..sort((a, b) => b.data.compareTo(a.data)))
                .take(3)
                .map((e) => _evolucaoCard(e)),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _resumoCard({
    required IconData icon,
    required String label,
    required String valor,
    required String sub,
    required Color cor,
  }) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: cor, size: 22),
              const SizedBox(height: 8),
              Text(valor,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: cor)),
              Text(sub,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ),
      );

  Widget _secao(String titulo) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 10),
        child: Text(
          titulo,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF7C6FCD)),
        ),
      );

  Widget _vazio(String msg) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(msg, style: TextStyle(color: Colors.grey[400])),
      );

  Widget _consultaCard(Consulta c, {bool mostrarData = false}) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF7C6FCD).withOpacity(0.1),
              child: Text(
                c.pacienteNome.split(' ').first[0].toUpperCase(),
                style: const TextStyle(
                    color: Color(0xFF7C6FCD),
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.pacienteNome,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    mostrarData
                        ? DateFormat("d MMM", 'pt_BR').format(c.dataHora) +
                            ' • ' +
                            DateFormat('HH:mm').format(c.dataHora)
                        : DateFormat('HH:mm').format(c.dataHora) +
                            ' • ${c.duracaoMinutos} min',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _corStatus(c.status).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                c.statusLabel,
                style: TextStyle(
                  color: _corStatus(c.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _evolucaoCard(Evolucao e) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  e.pacienteNome.split(' ').first,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yyyy').format(e.data),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              e.anotacao,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      );
}