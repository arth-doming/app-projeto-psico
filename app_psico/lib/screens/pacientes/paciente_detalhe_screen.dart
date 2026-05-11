import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/paciente.dart';
import '../../data/dados_locais.dart';
import '../../models/evolucao.dart';

class PacienteDetalheScreen extends StatelessWidget {
  final Paciente paciente;
  const PacienteDetalheScreen({super.key, required this.paciente});

  List<Evolucao> get _evolucoes => evolucoesLocais
      .where((e) => e.pacienteId == paciente.id)
      .toList()
    ..sort((a, b) => b.data.compareTo(a.data));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(paciente.nome)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar e info principal
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFF7C6FCD),
              child: Text(
                paciente.iniciais,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(paciente.nome,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Text('${paciente.idade} anos',
                style: TextStyle(color: Colors.grey[600])),
          ),
          const SizedBox(height: 24),

          // Dados de contato
          _secao(context, 'Informações de contato'),
          _infoTile(Icons.phone, 'Telefone', paciente.telefone),
          _infoTile(Icons.email, 'E-mail', paciente.email),
          _infoTile(
            Icons.cake,
            'Nascimento',
            DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR')
                .format(paciente.dataNascimento),
          ),

          if (paciente.observacoes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _secao(context, 'Observações gerais'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(paciente.observacoes,
                  style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
          ],

          const SizedBox(height: 8),
          _secao(context, 'Evoluções recentes'),
          if (_evolucoes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('Nenhuma evolução registrada',
                    style: TextStyle(color: Colors.grey[400])),
              ),
            )
          else
            ..._evolucoes.take(3).map((e) => _evolucaoCard(e)),
        ],
      ),
    );
  }

  Widget _secao(BuildContext context, String titulo) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 10),
        child: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFF7C6FCD),
          ),
        ),
      );

  Widget _infoTile(IconData icon, String label, String valor) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF7C6FCD)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                Text(valor,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      );

  Widget _evolucaoCard(Evolucao e) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR').format(e.data),
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              e.anotacao,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      );
}
