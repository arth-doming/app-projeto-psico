import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/dados_locais.dart';
import '../../models/consulta.dart';
import '../../models/paciente.dart';

class NovaConsultaScreen extends StatefulWidget {
  final DateTime diaSelecionado;
  const NovaConsultaScreen({super.key, required this.diaSelecionado});

  @override
  State<NovaConsultaScreen> createState() => _NovaConsultaScreenState();
}

class _NovaConsultaScreenState extends State<NovaConsultaScreen> {
  Paciente? _pacienteSelecionado;
  TimeOfDay _horario = const TimeOfDay(hour: 9, minute: 0);
  int _duracao = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova consulta')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Paciente', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<Paciente>(
            value: _pacienteSelecionado,
            hint: const Text('Selecione um paciente'),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            items: pacientesLocais
                .map((p) => DropdownMenuItem(value: p, child: Text(p.nome)))
                .toList(),
            onChanged: (p) => setState(() => _pacienteSelecionado = p),
          ),
          const SizedBox(height: 20),
          const Text('Data', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF7C6FCD)),
                const SizedBox(width: 12),
                Text(
                  DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR')
                      .format(widget.diaSelecionado),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Horário', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: _horario,
              );
              if (t != null) setState(() => _horario = t);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF7C6FCD)),
                  const SizedBox(width: 12),
                  Text(_horario.format(context),
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Duração (minutos)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              ...[30, 50, 60, 90].map((min) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$min min'),
                      selected: _duracao == min,
                      selectedColor:
                          const Color(0xFF7C6FCD).withOpacity(0.2),
                      onSelected: (_) => setState(() => _duracao = min),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _pacienteSelecionado == null
                ? null
                : () {
                    final dataHora = DateTime(
                      widget.diaSelecionado.year,
                      widget.diaSelecionado.month,
                      widget.diaSelecionado.day,
                      _horario.hour,
                      _horario.minute,
                    );
                    final nova = Consulta(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      pacienteId: _pacienteSelecionado!.id,
                      pacienteNome: _pacienteSelecionado!.nome,
                      dataHora: dataHora,
                      duracaoMinutos: _duracao,
                    );
                    Navigator.pop(context, nova);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C6FCD),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Agendar consulta',
                style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
