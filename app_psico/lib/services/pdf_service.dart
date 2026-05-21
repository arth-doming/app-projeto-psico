import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/paciente.dart';
import '../models/evolucao.dart';

class PdfService {
  static Future<void> exportarEvolucoes({
    required Paciente paciente,
    required List<Evolucao> evolucoes,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR');
    final agora = dateFormat.format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Relatório de Evoluções',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('7C6FCD'),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Paciente: ${paciente.nome}',
                      style: const pw.TextStyle(fontSize: 13),
                    ),
                    if (paciente.cpf.isNotEmpty)
                      pw.Text(
                        'CPF: ${paciente.cpf}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    pw.Text(
                      'Data de nascimento: ${dateFormat.format(paciente.dataNascimento)}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Gerado em: $agora',
                      style: pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey600),
                    ),
                    pw.Text(
                      '${evolucoes.length} registro(s)',
                      style: pw.TextStyle(
                          fontSize: 10, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColor.fromHex('7C6FCD'), thickness: 1.5),
            pw.SizedBox(height: 8),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Documento confidencial — uso exclusivo do profissional',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
            ),
            pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
            ),
          ],
        ),
        build: (context) => [
          if (evolucoes.isEmpty)
            pw.Center(
              child: pw.Text(
                'Nenhuma evolução registrada para este paciente.',
                style: pw.TextStyle(color: PdfColors.grey500),
              ),
            )
          else
            ...evolucoes.map((e) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('F0EEFF'),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(6)),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Container(
                            width: 8,
                            height: 8,
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('7C6FCD'),
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Text(
                            dateFormat.format(e.data),
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('7C6FCD'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Padding(
                      padding:
                          const pw.EdgeInsets.symmetric(horizontal: 4),
                      child: pw.Text(
                        e.anotacao,
                        style: const pw.TextStyle(
                            fontSize: 12, lineSpacing: 4),
                      ),
                    ),
                    pw.SizedBox(height: 16),
                    pw.Divider(color: PdfColors.grey300),
                    pw.SizedBox(height: 16),
                  ],
                )),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'evolucoes_${paciente.nome.replaceAll(' ', '_').toLowerCase()}.pdf',
    );
  }
}