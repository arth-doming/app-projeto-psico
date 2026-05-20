import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/consulta.dart';
import '../../models/paciente.dart';
import '../../services/consulta_service.dart';
import '../../services/paciente_service.dart';

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
  String? _erroHorario;
  List<Consulta> _consultasDoDia = [];
  List<Paciente> _pacientes = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    ConsultaService.listar().listen((consultas) {
      setState(() {
        _consultasDoDia = consultas
            .where((c) => DateUtils.isSameDay(c.dataHora, widget.diaSelecionado)
                && c.status != StatusConsulta.cancelada)
            .toList();
      });
    });
    PacienteService.listar().listen((pacientes) {
      setState(() => _pacientes = pacientes);
    });
  }

  bool _horarioOcupado(TimeOfDay horario) {
    return _consultasDoDia.any((c) =>
        c.dataHora.hour == horario.hour && c.dataHora.minute == horario.minute);
  }

  Future<void> _selecionarHorario() async {
    final t = await showTimePicker(
      context: context,
      initialTime: _horario,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (t == null) return;
    if (_horarioOcupado(t)) {
      setState(() => _erroHorario =
          'Já existe uma consulta às ${t.format(context)} neste dia.');
    } else {
      setState(() { _horario = t; _erroHorario = null; });
    }
  }

  void _agendar() {
    if (_pacienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione um paciente')));
      return;
    }
    if (_erroHorario != null) return;
    if (_horarioOcupado(_horario)) {
      setState(() => _erroHorario = 'Já existe uma consulta neste horário.');
      return;
    }
    final dataHora = DateTime(widget.diaSelecionado.year,
        widget.diaSelecionado.month, widget.diaSelecionado.day,
        _horario.hour, _horario.minute);
    final nova = Consulta(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      pacienteId: _pacienteSelecionado!.id,
      pacienteNome: _pacienteSelecionado!.nome,
      dataHora: dataHora,
      duracaoMinutos: _duracao,
    );
    Navigator.pop(context, nova);
  }

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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
            items: _pacientes.map((p) =>
                DropdownMenuItem(value: p, child: Text(p.nome))).toList(),
            onChanged: (p) => setState(() => _pacienteSelecionado = p),
          ),
          const SizedBox(height: 20),
          const Text('Data', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.calendar_today, color: Color(0xFF7C6FCD)),
              const SizedBox(width: 12),
              Text(DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR').format(widget.diaSelecionado),
                  style: const TextStyle(fontSize: 16)),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Horário', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_consultasDoDia.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              children: _consultasDoDia.map((c) {
                final label =
                    '${c.dataHora.hour.toString().padLeft(2, '0')}:${c.dataHora.minute.toString().padLeft(2, '0')}';
                return Chip(
                  label: Text(label, style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red[300],
                  avatar: const Icon(Icons.block, size: 16, color: Colors.white),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Horários em vermelho já estão ocupados',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ),
          ],
          InkWell(
            onTap: _selecionarHorario,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: _erroHorario != null ? Colors.red : Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                Icon(Icons.access_time,
                    color: _erroHorario != null ? Colors.red : const Color(0xFF7C6FCD)),
                const SizedBox(width: 12),
                Text(_horario.format(context), style: const TextStyle(fontSize: 16)),
                const Spacer(),
                Text('Toque para alterar',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400])),
              ]),
            ),
          ),
          if (_erroHorario != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Row(children: [
                const Icon(Icons.error_outline, size: 16, color: Colors.red),
                const SizedBox(width: 6),
                Text(_erroHorario!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ]),
            ),
          const SizedBox(height: 20),
          const Text('Duração (minutos)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [30, 50, 60, 90].map((min) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('$min min'),
                selected: _duracao == min,
                selectedColor: const Color(0xFF7C6FCD).withOpacity(0.2),
                onSelected: (_) => setState(() => _duracao = min),
              ),
            )).toList(),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _erroHorario != null ? null : _agendar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C6FCD),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Agendar consulta', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}