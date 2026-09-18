import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:sisan/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:sisan/features/ocorrencias/domain/entities/ocorrencia.dart';

// ─── Paleta primária ("Água Viva", decisions/008) ────────────────────────

const _azulAcento = PdfColor.fromInt(0xFF0288D1);
const _azulLight = PdfColor.fromInt(0xFFE1F5FE);
const _verde = PdfColor.fromInt(0xFF2E7D32);
const _verdeLight = PdfColor.fromInt(0xFFE8F5E9);
const _laranja = PdfColor.fromInt(0xFFEF6C00);
const _laranjaLight = PdfColor.fromInt(0xFFFFF3E0);
const _vermelho = PdfColor.fromInt(0xFFC62828);
const _cinzaLight = PdfColor.fromInt(0xFFF5F5F5);
const _cinzaBorda = PdfColor.fromInt(0xFFE0E0E0);
const _cinzaMedia = PdfColor.fromInt(0xFF9E9E9E);
const _cinzaTexto = PdfColor.fromInt(0xFF616161);
const _textoEscuro = PdfColor.fromInt(0xFF212121);
const _textoBranco = PdfColors.white;

const _labelTipo = {
  'vazamento': 'Vazamento',
  'esgoto_ceu_aberto': 'Esgoto a céu aberto',
  'falta_dagua': "Falta d'água",
  'agua_contaminada': 'Água contaminada',
  'baixa_pressao': 'Baixa pressão',
  'outros': 'Outros',
};

const _labelStatus = {
  'pendente': 'Pendente',
  'em_analise': 'Em análise',
  'resolvida': 'Resolvida',
  'arquivada': 'Arquivada',
};

const _meses = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

final _fmt = DateFormat('dd/MM/yy HH:mm');

({PdfColor bg, PdfColor fg}) _coresStatus(String status) {
  switch (status) {
    case 'resolvida':
      return (bg: _verdeLight, fg: _verde);
    case 'em_analise':
      return (bg: _azulLight, fg: _azulAcento);
    case 'arquivada':
      return (bg: _cinzaLight, fg: _cinzaTexto);
    default:
      return (bg: _laranjaLight, fg: _laranja);
  }
}

// ─── Entry point ──────────────────────────────────────────────────────────

Future<Uint8List> gerarRelatorioPdf({
  required DashboardStats stats,
  required String municipioNome,
}) async {
  final fontReg = await PdfGoogleFonts.notoSansRegular();
  final fontBold = await PdfGoogleFonts.notoSansBold();
  final fontItalic = await PdfGoogleFonts.notoSansItalic();

  final theme = pw.ThemeData.withFont(base: fontReg, bold: fontBold, italic: fontItalic);
  final doc = pw.Document(theme: theme);
  final now = DateTime.now();
  final dataStr = DateFormat('dd/MM/yyyy HH:mm').format(now);
  final mesLabel = _meses[now.month - 1];

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 40),
      theme: theme,
      header: (ctx) => _header(ctx, municipioNome, dataStr),
      footer: (ctx) => _footer(ctx, dataStr),
      build: (ctx) => [
        pw.SizedBox(height: 20),
        _kpiGrid(stats, mesLabel),
        pw.SizedBox(height: 22),
        if (stats.serie.isNotEmpty) ...[_tabelaTendencia(stats.serie), pw.SizedBox(height: 22)],
        _statusPanel(contagens: stats.porStatus),
        pw.SizedBox(height: 22),
        if (stats.porTipo.isNotEmpty) ...[_graficoTipo(stats.porTipo), pw.SizedBox(height: 22)],
        if (stats.ultimasOcorrencias.isNotEmpty) _tabelaOcorrencias(stats.ultimasOcorrencias),
      ],
    ),
  );

  return doc.save();
}

// ─── Header / Footer ──────────────────────────────────────────────────────

pw.Widget _header(pw.Context ctx, String municipioNome, String dataStr) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const pw.BoxDecoration(color: _azulAcento),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('SISAN', style: pw.TextStyle(color: _textoBranco, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  pw.Text('Sistema Integrado de Saneamento', style: const pw.TextStyle(color: _textoBranco, fontSize: 7.5)),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  municipioNome.isNotEmpty ? municipioNome : 'Município',
                  style: pw.TextStyle(color: _textoBranco, fontSize: 10, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 2),
                pw.Text('Relatório gerado em $dataStr', style: const pw.TextStyle(color: _textoBranco, fontSize: 7.5)),
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 4),
    ],
  );
}

pw.Widget _footer(pw.Context ctx, String dataStr) {
  return pw.Column(
    children: [
      pw.Divider(color: _cinzaBorda, height: 1),
      pw.SizedBox(height: 4),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('SISAN  •  Relatório Administrativo  •  $dataStr', style: const pw.TextStyle(color: _cinzaMedia, fontSize: 7.5)),
          pw.Text('Página ${ctx.pageNumber} de ${ctx.pagesCount}', style: const pw.TextStyle(color: _cinzaMedia, fontSize: 7.5)),
        ],
      ),
    ],
  );
}

// ─── KPI Grid ─────────────────────────────────────────────────────────────

pw.Widget _kpiGrid(DashboardStats stats, String mesLabel) {
  final kpis = [
    (label: 'Ocorrências em $mesLabel', valor: stats.mesAtual.ocorrencias.toString(), cor: _azulAcento),
    (label: 'Resolvidas em $mesLabel', valor: stats.mesAtual.resolvidas.toString(), cor: _verde),
    (label: 'Tempo médio de resolução', valor: '${stats.mesAtual.tempoMedioHoras.toStringAsFixed(1)}h', cor: _laranja),
    (label: 'Alertas sanitários ativos', valor: stats.alertasAtivos.toString(), cor: _vermelho),
  ];

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _tituloSecao('Resumo do Mês', _azulAcento),
      pw.SizedBox(height: 12),
      pw.Row(
        children: kpis.map((k) {
          return pw.Expanded(
            child: pw.Container(
              margin: const pw.EdgeInsets.only(right: 8),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border(
                  top: pw.BorderSide(color: k.cor, width: 3),
                  left: const pw.BorderSide(color: _cinzaBorda, width: 0.5),
                  right: const pw.BorderSide(color: _cinzaBorda, width: 0.5),
                  bottom: const pw.BorderSide(color: _cinzaBorda, width: 0.5),
                ),
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(k.valor, style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: k.cor)),
                  pw.SizedBox(height: 3),
                  pw.Text(k.label, style: const pw.TextStyle(fontSize: 7.5, color: _cinzaTexto)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

// ─── Status Panel ─────────────────────────────────────────────────────────

pw.Widget _statusPanel({required Map<String, int> contagens}) {
  if (contagens.isEmpty) return pw.SizedBox();

  final ordem = _labelStatus.keys.toList();
  final itens = [
    ...ordem.where((k) => contagens.containsKey(k)).map((k) => (chave: k, label: _labelStatus[k]!, valor: contagens[k]!)),
    ...contagens.keys.where((k) => !ordem.contains(k)).map((k) => (chave: k, label: _labelStatus[k] ?? k, valor: contagens[k]!)),
  ];
  final total = contagens.values.fold(0, (a, b) => a + b);

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _tituloSecao('Ocorrências por Status (mês)', _azulAcento),
      pw.SizedBox(height: 10),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: pw.BoxDecoration(color: _cinzaLight, border: pw.Border.all(color: _cinzaBorda, width: 0.5)),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(
              width: 64,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(total.toString(), style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: _textoEscuro)),
                  pw.Text('total', style: const pw.TextStyle(fontSize: 8, color: _cinzaTexto)),
                ],
              ),
            ),
            pw.Container(width: 0.5, height: 40, color: _cinzaBorda),
            pw.SizedBox(width: 12),
            pw.Expanded(
              child: pw.Wrap(
                spacing: 8,
                runSpacing: 6,
                children: itens.map((item) {
                  final cores = _coresStatus(item.chave);
                  return pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: cores.bg,
                      border: pw.Border.all(color: cores.fg, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(3),
                    ),
                    child: pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(item.valor.toString(), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: cores.fg)),
                        pw.SizedBox(width: 4),
                        pw.Text(item.label, style: pw.TextStyle(fontSize: 7.5, color: cores.fg)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ─── Tabela de ocorrências recentes ───────────────────────────────────────

pw.Widget _tabelaOcorrencias(List<Ocorrencia> ocorrencias) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _tituloSecao('Últimas ${ocorrencias.length} Ocorrências', _azulAcento),
      pw.SizedBox(height: 10),
      pw.Table(
        border: pw.TableBorder(
          horizontalInside: const pw.BorderSide(color: _cinzaBorda, width: 0.5),
          bottom: const pw.BorderSide(color: _cinzaBorda, width: 0.5),
          left: const pw.BorderSide(color: _cinzaBorda, width: 0.5),
          right: const pw.BorderSide(color: _cinzaBorda, width: 0.5),
        ),
        columnWidths: const {
          0: pw.FixedColumnWidth(58),
          1: pw.FlexColumnWidth(1.3),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(1.6),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: _azulAcento),
            children: ['Protocolo', 'Tipo', 'Status', 'Criado em'].map(_thCell).toList(),
          ),
          for (var i = 0; i < ocorrencias.length; i++)
            pw.TableRow(
              decoration: pw.BoxDecoration(color: i.isEven ? _cinzaLight : PdfColors.white),
              children: [
                _tdCell(ocorrencias[i].protocolo ?? '—'),
                _tdCell(_labelTipo[ocorrencias[i].tipo.dbValue] ?? '—'),
                _statusCell(ocorrencias[i].status.dbValue),
                _tdCell(_fmt.format(ocorrencias[i].criadoEm)),
              ],
            ),
        ],
      ),
    ],
  );
}

// ─── Gráfico de barras por tipo ───────────────────────────────────────────

pw.Widget _graficoTipo(Map<String, int> contagem) {
  final total = contagem.values.fold(0, (a, b) => a + b);
  if (total == 0) return pw.SizedBox();

  final barras = contagem.entries.map((e) => (label: _labelTipo[e.key] ?? e.key, valor: e.value)).toList()
    ..sort((a, b) => b.valor.compareTo(a.valor));

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _tituloSecao('Ocorrências por Tipo (mês)', _cinzaTexto),
      pw.SizedBox(height: 10),
      pw.Container(
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(color: _cinzaLight, border: pw.Border.all(color: _cinzaBorda, width: 0.5)),
        child: pw.Column(
          children: barras.map((b) {
            final pct = total > 0 ? (b.valor * 100 ~/ total) : 0;
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 5),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(
                    width: 90,
                    child: pw.Text(b.label, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textoEscuro)),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Expanded(
                    child: pw.LayoutBuilder(builder: (ctx, constraints) {
                      final maxW = constraints?.maxWidth ?? 200.0;
                      final fillW = total > 0 ? (b.valor / total) * maxW : 0.0;
                      return pw.Stack(
                        children: [
                          pw.Container(width: maxW, height: 16, color: _cinzaBorda),
                          pw.Container(width: fillW, height: 16, color: _azulAcento),
                        ],
                      );
                    }),
                  ),
                  pw.SizedBox(width: 8),
                  pw.SizedBox(
                    width: 56,
                    child: pw.Text('${b.valor}  ($pct%)', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _azulAcento)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

// ─── Helpers de célula ────────────────────────────────────────────────────

pw.Widget _thCell(String text) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: pw.Text(text, style: pw.TextStyle(color: _textoBranco, fontSize: 8, fontWeight: pw.FontWeight.bold)),
    );

pw.Widget _tdCell(String text) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 8, color: _textoEscuro)),
    );

pw.Widget _statusCell(String status) {
  final label = _labelStatus[status] ?? status;
  final cores = _coresStatus(status);
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: pw.BoxDecoration(color: cores.bg, border: pw.Border.all(color: cores.fg, width: 0.5), borderRadius: pw.BorderRadius.circular(2)),
      child: pw.Text(label, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: cores.fg)),
    ),
  );
}

pw.Widget _tituloSecao(String titulo, PdfColor cor) => pw.Row(
      children: [
        pw.Container(width: 3, height: 14, color: cor),
        pw.SizedBox(width: 8),
        pw.Text(titulo, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: _textoEscuro)),
      ],
    );

// ─── Tabela de tendência (6 meses) ────────────────────────────────────────

const _mesesAbrevPdf = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];

String _mesLabelIso(String mesIso) {
  final partes = mesIso.split('-');
  if (partes.length != 2) return mesIso;
  final ano = partes[0];
  final m = int.tryParse(partes[1]) ?? 1;
  final abrev = _mesesAbrevPdf[(m - 1).clamp(0, 11)];
  final anoCurto = ano.length >= 2 ? ano.substring(ano.length - 2) : ano;
  return '$abrev/$anoCurto';
}

pw.Widget _tabelaTendencia(List<PontoTendencia> serie) {
  pw.Widget cel(String txt, {bool header = false, PdfColor? cor}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: pw.Text(
          txt,
          style: pw.TextStyle(fontSize: 8.5, fontWeight: header ? pw.FontWeight.bold : pw.FontWeight.normal, color: cor ?? _textoEscuro),
        ),
      );

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _tituloSecao('Evolução (últimos 6 meses)', _azulAcento),
      pw.SizedBox(height: 12),
      pw.Table(
        border: pw.TableBorder.all(color: _cinzaBorda, width: 0.5),
        columnWidths: const {0: pw.FlexColumnWidth(1.4), 1: pw.FlexColumnWidth(1), 2: pw.FlexColumnWidth(1)},
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: _cinzaLight),
            children: [cel('Mês', header: true), cel('Ocorrências', header: true, cor: _azulAcento), cel('Resolvidas', header: true, cor: _verde)],
          ),
          ...serie.map((p) => pw.TableRow(children: [cel(_mesLabelIso(p.mesIso)), cel('${p.ocorrencias}'), cel('${p.resolvidas}')])),
        ],
      ),
    ],
  );
}
