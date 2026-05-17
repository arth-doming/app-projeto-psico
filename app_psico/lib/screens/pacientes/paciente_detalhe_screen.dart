import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/paciente.dart';
import '../../models/evolucao.dart';
import '../../data/dados_locais.dart';
import 'paciente_form_screen.dart';

class PacienteDetalheScreen extends StatefulWidget {
  final Paciente paciente;
  const PacienteDetalheScreen({super.key, required this.paciente});

  @override
  State<PacienteDetalheScreen> createState() => _PacienteDetalheScreenState();
}

class _PacienteDetalheScreenState extends State<PacienteDetalheScreen> {
  late Paciente _paciente;
  late List<Evolucao> _evolucoes;

  @override
  void initState() {
    super.initState();
    _paciente = widget.paciente;
    _carregarEvolucoes();
  }

  void _carregarEvolucoes() {
    _evolucoes = evolucoesLocais
        .where((e) => e.pacienteId == _paciente.id)
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  void _editarPaciente() async {
    final atualizado = await Navigator.push<Paciente>(
      context,
      MaterialPageRoute(
        builder: (_) => PacienteFormScreen(paciente: _paciente),
      ),
    );
    if (atualizado != null) {
      setState(() => _paciente = atualizado);
    }
  }

  void _deletarPaciente() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Deletar paciente'),
        content: Text(
            'Tem certeza que deseja deletar ${_paciente.nome}? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              pacientesLocais.removeWhere((p) => p.id == _paciente.id);
              evolucoesLocais.removeWhere((e) => e.pacienteId == _paciente.id);
              Navigator.pop(context);
              Navigator.pop(context, 'deletado');
            },
            child: const Text('Deletar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _novaEvolucao() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes, color: Color(0xFF7C6FCD)),
                const SizedBox(width: 10),
                Text(
                  'Nova evolução — ${_paciente.nome.split(' ').first}',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR')
                  .format(DateTime.now()),
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 6,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Escreva as anotações da sessão...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: Color(0xFF7C6FCD), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;
                  final nova = Evolucao(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    pacienteId: _paciente.id,
                    pacienteNome: _paciente.nome,
                    data: DateTime.now(),
                    anotacao: controller.text.trim(),
                  );
                  setState(() {
                    _evolucoes.insert(0, nova);
                    evolucoesLocais.add(nova);
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C6FCD),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Salvar evolução',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _verEvolucao(Evolucao e) {
    final controller = TextEditingController(text: e.anotacao);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, scroll) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR').format(e.data),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF7C6FCD)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Deletar evolução',
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _evolucoes.removeWhere((ev) => ev.id == e.id);
                        evolucoesLocais.removeWhere((ev) => ev.id == e.id);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Edite a anotação...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: Color(0xFF7C6FCD), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;
                  setState(() {
                    final index =
                        _evolucoes.indexWhere((ev) => ev.id == e.id);
                    final globalIndex =
                        evolucoesLocais.indexWhere((ev) => ev.id == e.id);
                    final atualizada = Evolucao(
                      id: e.id,
                      pacienteId: e.pacienteId,
                      pacienteNome: e.pacienteNome,
                      data: e.data,
                      anotacao: controller.text.trim(),
                      consultaId: e.consultaId,
                    );
                    if (index != -1) _evolucoes[index] = atualizada;
                    if (globalIndex != -1)
                      evolucoesLocais[globalIndex] = atualizada;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C6FCD),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Salvar edição',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_paciente.nome.split(' ').first),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar paciente',
            onPressed: _editarPaciente,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Deletar paciente',
            onPressed: _deletarPaciente,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _novaEvolucao,
        icon: const Icon(Icons.add),
        label: const Text('Nova evolução'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: const Color(0xFF7C6FCD),
              child: Text(
                _paciente.iniciais,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(_paciente.nome,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Center(
            child: Text('${_paciente.idade} anos',
                style: TextStyle(color: Colors.grey[600])),
          ),
          const SizedBox(height: 20),
          _secao('Informações de contato'),
          _infoTile(Icons.phone, 'Telefone', _paciente.telefone),
          _infoTile(Icons.email, 'E-mail', _paciente.email),
          _infoTile(
            Icons.cake,
            'Nascimento',
            DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR')
                .format(_paciente.dataNascimento),
          ),
          if (_paciente.observacoes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _secao('Observações gerais'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(_paciente.observacoes,
                  style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _secao('Evoluções'),
              if (_evolucoes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    '${_evolucoes.length} registro(s)',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ),
            ],
          ),
          if (_evolucoes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.notes_outlined,
                        size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Nenhuma evolução registrada ainda',
                        style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 6),
                    Text('Toque em "Nova evolução" para começar',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[400])),
                  ],
                ),
              ),
            )
          else
            ..._evolucoes.map((e) => _evolucaoCard(e)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _secao(String titulo) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 10),
        child: Text(
          titulo,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF7C6FCD)),
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

  Widget _evolucaoCard(Evolucao e) => GestureDetector(
        onTap: () => _verEvolucao(e),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF7C6FCD),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR').format(e.data),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C6FCD)),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right,
                      size: 18, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                e.anotacao,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
      );
}