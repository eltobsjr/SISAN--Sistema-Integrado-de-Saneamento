import 'package:sisan/core/constants/ocorrencia_tipo.dart';

/// Checklist obrigatório por tipo de ocorrência pra encerrar uma Ordem de
/// Serviço (decisions/005) — concluir só é permitido com todos os itens
/// marcados e pelo menos 1 foto do depois.
class ChecklistEncerramento {
  ChecklistEncerramento._();

  static const Map<OcorrenciaTipo, List<String>> _itens = {
    OcorrenciaTipo.vazamento: [
      'Vazamento estancado',
      'Via/calçada recomposta',
    ],
    OcorrenciaTipo.esgotoCeuAberto: [
      'Fluxo de esgoto interrompido',
      'Área higienizada',
    ],
    OcorrenciaTipo.faltaDagua: [
      'Abastecimento normalizado',
      'Rede verificada',
    ],
    OcorrenciaTipo.aguaContaminada: [
      'Fonte de contaminação identificada',
      'Qualidade da água verificada',
    ],
    OcorrenciaTipo.baixaPressao: [
      'Pressão normalizada',
      'Rede verificada',
    ],
    OcorrenciaTipo.outros: [
      'Problema resolvido',
    ],
  };

  static List<String> itensPara(OcorrenciaTipo tipo) => _itens[tipo] ?? const [];
}
