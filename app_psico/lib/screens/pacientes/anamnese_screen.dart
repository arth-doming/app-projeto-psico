import 'package:flutter/material.dart';
import '../../models/anamnese.dart';
import '../../models/paciente.dart';
import '../../services/anamnese_service.dart';

class AnamneseScreen extends StatefulWidget {
  final Paciente paciente;
  final Anamnese? anamnese;
  const AnamneseScreen({super.key, required this.paciente, this.anamnese});

  @override
  State<AnamneseScreen> createState() => _AnamneseScreenState();
}

class _AnamneseScreenState extends State<AnamneseScreen> {
  late final TextEditingController _queixaController;
  late final TextEditingController _inicioController;
  late final TextEditingController _consequenciasController;
  late final TextEditingController _infanciaController;
  late final TextEditingController _tratamentosController;
  late final TextEditingController _pontosController;
  late final TextEditingController _aspectosController;
  late final TextEditingController _expectativasController;
  bool _salvando = false;
  bool get _editando => widget.anamnese != null;

  @override
  void initState() {
    super.initState();
    _queixaController = TextEditingController(
        text: widget.anamnese?.queixaPrincipal ?? '');
    _inicioController = TextEditingController(
        text: widget.anamnese?.inicioProblem ?? '');
    _consequenciasController = TextEditingController(
        text: widget.anamnese?.consequencias ?? '');
    _infanciaController = TextEditingController(
        text: widget.anamnese?.infanciaAdolescencia ?? '');
    _tratamentosController = TextEditingController(
        text: widget.anamnese?.tratamentosAnteriores ?? '');
    _pontosController = TextEditingController(
        text: widget.anamnese?.pontosFortesRecursos ?? '');
    _aspectosController = TextEditingController(
        text: widget.anamnese?.aspectosFisicos ?? '');
    _expectativasController = TextEditingController(
        text: widget.anamnese?.expectativas ?? '');
  }

  @override
  void dispose() {
    _queixaController.dispose();
    _inicioController.dispose();
    _consequenciasController.dispose();
    _infanciaController.dispose();
    _tratamentosController.dispose();
    _pontosController.dispose();
    _aspectosController.dispose();
    _expectativasController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    final anamnese = Anamnese(
      id: widget.anamnese?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      pacienteId: widget.paciente.id,
      data: DateTime.now(),
      queixaPrincipal: _queixaController.text.trim(),
      inicioProblem: _inicioController.text.trim(),
      consequencias: _consequenciasController.text.trim(),
      infanciaAdolescencia: _infanciaController.text.trim(),
      tratamentosAnteriores: _tratamentosController.text.trim(),
      pontosFortesRecursos: _pontosController.text.trim(),
      aspectosFisicos: _aspectosController.text.trim(),
      expectativas: _expectativasController.text.trim(),
    );
    await AnamneseService.salvar(anamnese);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Anamnese' : 'Anamnese'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Cabeçalho
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF7C6FCD).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFF7C6FCD).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.assignment_outlined,
                    color: Color(0xFF7C6FCD)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Roteiro de Triagem',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7C6FCD))),
                    Text(widget.paciente.nome,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _pergunta(
            numero: '1',
            titulo: 'Queixa principal',
            controller: _queixaController,
          ),
          _pergunta(
            numero: '2',
            titulo:
                'Quando começou o problema/os sintomas (fatos associados)?',
            controller: _inicioController,
          ),
          _pergunta(
            numero: '3',
            titulo: 'Consequências (negativas) dos sintomas',
            controller: _consequenciasController,
          ),
          _pergunta(
            numero: '4',
            titulo:
                'Informações relevantes da infância e adolescência',
            controller: _infanciaController,
          ),
          _pergunta(
            numero: '5',
            titulo:
                'Tratamentos e/ou tentativas para lidar com o problema (Quais e por quanto tempo?)',
            controller: _tratamentosController,
          ),
          _pergunta(
            numero: '6',
            titulo: 'Pontos fortes/recursos',
            controller: _pontosController,
          ),
          _pergunta(
            numero: '7',
            titulo: 'Aspectos físicos e de saúde',
            controller: _aspectosController,
          ),
          _pergunta(
            numero: '8',
            titulo:
                'Expectativas em relação ao serviço de psicologia',
            controller: _expectativasController,
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _salvando ? null : _salvar,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C6FCD),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _salvando
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Salvar anamnese',
                    style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _pergunta({
    required String numero,
    required String titulo,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF7C6FCD),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    numero,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Escreva aqui...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF7C6FCD), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}