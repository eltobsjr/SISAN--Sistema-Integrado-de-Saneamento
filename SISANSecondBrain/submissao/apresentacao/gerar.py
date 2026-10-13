"""Gera os slides do pitch do SISAN (formato do tipo Slides) em project/slides/."""
import json
import pathlib

RAIZ = pathlib.Path(__file__).parent / 'project'
(RAIZ / 'slides').mkdir(parents=True, exist_ok=True)

# ─── Paleta e tipografia ───────────────────────────────────────────────────
INK, INK2, INKLINE = '#0B2235', '#12324C', '#24496A'
ON_INK, ON_INK2, AQUA = '#EEF3F6', '#A9BFCF', '#4CC3F0'
PAPER, CARD, LINE = '#F4F2EC', '#FFFDF8', '#E2DCCF'
TXT, TXT2, BLUE = '#14212C', '#4B5966', '#0A6AA8'
AMBER, AMBER_TXT = '#F3A43F', '#A04E00'
DISPLAY = "'Bricolage Grotesque', 'DM Sans', sans-serif"
BODY = "'DM Sans', sans-serif"

IMG = {
    'login': '/_blob/a840a02134003fc8c60709a1ed46d9cc',
    'cadastro': '/_blob/facc762ffc39f232d1eb4e46a1e3b387',
    'cid_home': '/_blob/c7ab189acd0d249d0d8959aeccd787d3',
    'cid_tipo': '/_blob/e1194619cbb88e4fc8faedf1c6d01136',
    'cid_local': '/_blob/123d907584a6e4fa5a1b27dcc2933382',
    'cid_proximas': '/_blob/9691cacd554e353c714e175d212d4db6',
    'cid_avaliacao': '/_blob/609c5d6f65a6c36fc38fd470d2d03323',
    'cid_mapa': '/_blob/ba3b0798dce2016d7655644b73d82968',
    'tec_home': '/_blob/bc1d777b2c4c7137a3813ebdc2efcf83',
    'tec_ordens': '/_blob/e5aac6549597cacde0796305719a0ce6',
    'tec_os': '/_blob/5c1db7c87983f6fee78439f4c7713820',
    'tec_os_prioridade': '/_blob/3b32fb28a94f3cef26018abdfbff3477',
    'ges_home': '/_blob/90b68919dcb50e54a816c7f6bfa95bb0',
    'ges_painel': '/_blob/3f3722f46942bf937bdeee0f7f8bfff5',
    'ges_classificacao': '/_blob/3b3aac2a8b2e05064bfa4f8c7540779a',
    'ges_corrigir': '/_blob/4b3f763f6d21491899b33ad84b09860e',
    'ges_alertas': '/_blob/e59f003c4a93a2bf5e5bc6d205c9579d',
}

# Telas a 412×892 (2x): altura = largura × 892/412.
def alt(w):
    return round(w * 892 / 412)


def fone(nome, alt_txt, w=340, extra='', sombra='rgba(5,15,24,0.35)', id_=''):
    idattr = f' id="{id_}"' if id_ else ''
    return (f'<img{idattr} src="{IMG[nome]}" alt="{alt_txt}" style="{extra}width:{w}px;height:{alt(w)}px;'
            f'object-fit:cover;border-radius:{round(w * 0.13)}px;border:10px solid #050F18;'
            f'box-shadow:0 32px 64px {sombra}">')


def sobrancelha(texto, cor, barra=AMBER):
    return (f'<div style="display:flex;flex-direction:row;align-items:center;gap:16px">'
            f'<div style="width:48px;height:4px;background:{barra};border-radius:2px"></div>'
            f'<p style="font-size:24px;font-weight:700;letter-spacing:4px;color:{cor};text-transform:uppercase">{texto}</p>'
            f'</div>')


def titulo(texto, cor, largura=1400, tam=72):
    return (f'<h2 style="font-family:{DISPLAY};font-size:{tam}px;font-weight:700;line-height:1.08;'
            f'letter-spacing:-1px;color:{cor};width:{largura}px">{texto}</h2>')


def secao(id_, fundo, cor, corpo, notas, extra='', hidden=False, trans='push', pad='128px'):
    h = ' hidden' if hidden else ''
    return (f'<section id="{id_}"{h} data-transition="{trans}" style="background:{fundo};color:{cor};'
            f'font-family:{BODY};padding:{pad};{extra}">\n{corpo}\n<aside>{notas}</aside>\n</section>\n')


def lista(itens, cor):
    lis = ''.join(f'<li>{i}</li>' for i in itens)
    return f'<ul style="font-size:30px;line-height:1.55;color:{cor}">{lis}</ul>'


S = {}

# ─── PITCH ────────────────────────────────────────────────────────────────

S['cover'] = secao('cover', INK, ON_INK, f'''
{fone('ges_painel', 'Painel do gestor com as prioridades de hoje', 330, 'position:absolute;left:1150px;top:150px;transform:rotate(-4deg);')}
{fone('cid_home', 'Início do app no perfil cidadão', 330, 'position:absolute;left:1430px;top:206px;transform:rotate(3deg);')}
<div style="display:flex;flex-direction:column;gap:36px;width:940px">
{sobrancelha('Hackathon O Piauí que Queremos · Finalista', AMBER)}
<h1 style="font-family:{DISPLAY};font-size:184px;font-weight:800;line-height:0.95;letter-spacing:-4px">SISAN</h1>
<p style="font-family:{DISPLAY};font-size:52px;font-weight:600;line-height:1.15">Sistema Integrado de Saneamento</p>
<p style="font-size:32px;line-height:1.45;color:{ON_INK2};width:860px">Denúncia cidadã, ordens de serviço e prioridade por risco sanitário, num único aplicativo.</p>
</div>''',
    'ROTEIRO DE 2 MINUTOS (8 slides, de 10 a 20 segundos cada).\n'
    "1 Capa (10s): Somos o SISAN, o app que liga quem sofre com falta d'água e esgoto a quem resolve.\n"
    '2 Cenário (18s): Em Teresina, cerca de 4 em cada 10 moradores ainda não têm esgoto atendido, e quase 20% da água se perde na distribuição. '
    'O cidadão não tem como avisar, e o gestor não vê onde agir primeiro.\n'
    '3 Solução (15s): O cidadão registra com foto e GPS, mesmo sem internet. O técnico atende pela fila de prioridade e só conclui com checklist e foto. '
    'O gestor decide onde agir. E o ciclo fecha com quem relatou.\n'
    '4 App (12s): Um só aplicativo para os três perfis. Estas são telas reais.\n'
    '5 Prioridade (20s): A fila não é por ordem de chegada. Cada caso ganha uma pontuação: a urgência e o nível de risco à saúde, que a IA classifica a partir do relato, '
    'quantos moradores confirmaram e há quantos dias está aberto. Se a IA errar, o gestor corrige e a fila reordena na hora.\n'
    '6 Mapa (17s): Cada relato aparece no mapa, colorido por urgência. Quem vê o mesmo problema a até 80 metros é convidado a confirmar, em vez de abrir outro chamado. '
    'Os pontos vêm da nossa base de testes interna.\n'
    '7 Abordagem (13s): Uma base única e segura, multiplataforma e rápida de entregar com equipe pequena.\n'
    '8 Fim (15s): Próximo passo: pedir às autoridades, pela Lei de Acesso à Informação, as reclamações reais por bairro. Obrigado.\n'
    'Os slides escondidos (apêndice) ficam para as perguntas.',
    extra='display:flex;flex-direction:column;justify-content:center', trans='fade')


def stat(numero, rotulo, cor):
    return (f'<div style="flex:1;display:flex;flex-direction:column;gap:16px;border-top:3px solid {cor};padding:32px 0px 0px 0px">'
            f'<p style="font-family:{DISPLAY};font-size:104px;font-weight:700;line-height:1;letter-spacing:-2px;color:{cor}">{numero}</p>'
            f'<p style="font-size:28px;line-height:1.35;color:{TXT2}">{rotulo}</p></div>')


S['oficial'] = secao('oficial', PAPER, TXT, f'''
<div style="display:flex;flex-direction:column;gap:24px">
{sobrancelha('Dados oficiais', BLUE)}
{titulo('O cenário de Teresina em números', TXT)}
</div>
<div style="display:flex;flex-direction:row;gap:48px">
{stat('94,8%', 'da população atendida com abastecimento de água', TXT)}
{stat('55,5%', 'da população atendida com esgotamento sanitário', AMBER_TXT)}
{stat('19,6%', 'de perdas na distribuição de água', AMBER_TXT)}
{stat('3', 'estações de tratamento de esgoto ativas: Leste, Pirajá e Alegria', TXT)}
</div>
<p style="font-family:{DISPLAY};font-size:40px;font-weight:600;line-height:1.3;width:1400px">Cerca de 4 em cada 10 moradores ainda não têm esgotamento atendido. É aí que o relato do cidadão aponta onde agir primeiro.</p>
<p style="position:absolute;left:128px;bottom:64px;width:1664px;font-size:24px;color:{TXT2}">Fontes: Instituto Água e Saneamento (exportação de 09/10/2026) e ANA, Atlas Esgotos (levantamento de 2020). Os anos-base variam por indicador.</p>''',
    'Cuidado ao citar: os indicadores vêm de fontes com anos-base diferentes, e a própria concessionária divulga cobertura de esgoto acima de 59%, '
    'número diferente dos 55,5% do Instituto Água e Saneamento. Cite sempre a fonte. Os 55,5% significam população atendida com esgotamento; '
    'o complemento, cerca de 44,5%, é a base da frase de 4 em cada 10. As três estações de tratamento vêm do levantamento da ANA de 2020. '
    'O município declara ter ouvidoria, mas não achamos dados públicos de reclamações, o que reforça o papel do SISAN.',
    extra='display:flex;flex-direction:column;justify-content:space-between', pad='128px 128px 160px')


def passo(num, papel, titulo_, texto, icone):
    return (f'<div style="flex:1;display:flex;flex-direction:column;gap:20px;background:{CARD};padding:44px;border:1px solid {LINE};border-radius:28px">'
            f'<div style="display:flex;flex-direction:row;align-items:center;justify-content:space-between">'
            f'<p style="font-size:24px;font-weight:700;letter-spacing:3px;color:{BLUE}">{num} · {papel}</p>'
            f'<x-icon name="{icone}" style="color:{BLUE};width:40px;height:40px"></x-icon></div>'
            f'<h3 style="font-family:{DISPLAY};font-size:44px;font-weight:700;line-height:1.1">{titulo_}</h3>'
            f'<p style="font-size:30px;line-height:1.45;color:{TXT2}">{texto}</p></div>')


SETA = f'<x-shape kind="arrow-right" style="width:56px;height:32px;background:{AMBER}"></x-shape>'

S['fluxo'] = secao('fluxo', PAPER, TXT, f'''
<div style="display:flex;flex-direction:column;gap:24px">
{sobrancelha('A solução', BLUE)}
{titulo('Do relato à resolução, num único fluxo', TXT)}
</div>
<div style="display:flex;flex-direction:row;align-items:center;gap:20px">
{passo('01', 'CIDADÃO', 'Registra o problema', 'Tipo, foto e GPS, mesmo sem internet. Se alguém já relatou perto, confirma.', 'Users')}
{SETA}
{passo('02', 'TÉCNICO', 'Atende pela prioridade', 'Fila ordenada por risco, checklist e foto antes de concluir.', 'Wrench')}
{SETA}
{passo('03', 'GESTOR', 'Decide onde agir', 'Prioridades do dia, mapa vivo e resumo do mês por IA.', 'Chart')}
</div>
<div style="display:flex;flex-direction:row;align-items:center;gap:24px;background:{INK};padding:28px 40px;border-radius:24px">
<x-icon name="CheckCircle" style="color:{AMBER};width:44px;height:44px"></x-icon>
<p style="font-size:30px;line-height:1.4;color:{ON_INK}">O ciclo fecha com quem relatou: o cidadão vê o reparo e confirma se resolveu. Se não, a ordem volta para a fila.</p>
</div>''',
    'O fluxo completo: o cidadão denuncia, a ocorrência aparece no mapa e vira uma ordem de serviço. O técnico atende pela prioridade, '
    'o gestor enxerga o conjunto. No fim, o próprio cidadão confirma se o problema foi resolvido; se disser que não, a ordem volta para a fila dos técnicos.',
    extra='display:flex;flex-direction:column;justify-content:space-between')


def fone_rotulado(nome, alt_txt, rotulo, w=300):
    return (f'<div style="display:flex;flex-direction:column;gap:28px;align-items:center">{fone(nome, alt_txt, w)}'
            f'<p style="font-size:28px;font-weight:700;letter-spacing:2px;color:{AQUA};text-transform:uppercase">{rotulo}</p></div>')


S['telas'] = secao('telas', INK, ON_INK, f'''
<div style="flex:1;display:flex;flex-direction:column;gap:32px">
{sobrancelha('O app', AQUA)}
{titulo('Um app, três perfis', ON_INK, 560)}
<p style="font-size:30px;line-height:1.45;color:{ON_INK2};width:540px">O mesmo aplicativo, no celular e na web. Telas reais, com a base de testes interna.</p>
</div>
<div style="display:flex;flex-direction:row;gap:40px">
{fone_rotulado('cid_home', 'Início do cidadão com os registros em andamento', 'Cidadão')}
{fone_rotulado('tec_home', 'Início do técnico com a fila por prioridade', 'Técnico')}
{fone_rotulado('ges_home', 'Início do gestor com o resumo do mês por IA', 'Gestor')}
</div>''',
    'Um único aplicativo atende os três perfis. O cidadão acompanha os registros, o técnico vê a fila por prioridade e o gestor vê o que exige atenção, '
    'com um resumo do mês gerado por IA. Telas reais, com a base de testes interna.',
    extra='display:flex;flex-direction:row;align-items:center;gap:64px')


def linha_pontos(rotulo, pontos, cor, detalhe):
    w = pontos * 9  # 50 pontos = 450px
    return (f'<div style="display:flex;flex-direction:row;align-items:center;gap:28px">'
            f'<div style="width:330px;display:flex;flex-direction:column;gap:4px">'
            f'<p style="font-size:30px;font-weight:700;line-height:1.2">{rotulo}</p>'
            f'<p style="font-size:24px;line-height:1.3;color:{TXT2}">{detalhe}</p></div>'
            f'<div style="width:{w}px;height:40px;background:{cor};border-radius:8px"></div>'
            f'<p style="font-family:{DISPLAY};font-size:36px;font-weight:700">até {pontos}</p></div>')


S['prioridade'] = secao('prioridade', AMBER, INK, f'''
{fone('ges_painel', 'Painel do gestor com as prioridades de hoje e a pontuação de cada caso', 380, 'position:absolute;left:1392px;top:118px;', 'rgba(70,35,0,0.35)')}
<div style="display:flex;flex-direction:column;gap:24px;width:1150px">
{sobrancelha('Prioridade por risco sanitário', INK, INK)}
{titulo('A fila se ordena pelo risco, não pela ordem de chegada', INK, 1150)}
</div>
<div style="display:flex;flex-direction:column;gap:28px;width:1150px;background:{CARD};padding:44px 48px;border-radius:28px">
{linha_pontos('Urgência', 50, INK, 'classificada pela IA')}
{linha_pontos('Nível de risco', 20, BLUE, 'à saúde, também pela IA')}
{linha_pontos('Confirmações', 30, '#2E8FC4', '3 pontos por morador')}
{linha_pontos('Dias em aberto', 20, AMBER, '2 pontos por dia')}
</div>
<p style="font-size:30px;line-height:1.4;font-weight:500;width:1150px">Se a IA errar, o gestor corrige a classificação e a fila reordena na hora.</p>''',
    'A pontuação vai de 0 a 120 e é calculada no banco, a mesma para o painel do gestor e a fila do técnico. Urgência vale até 50 pontos, '
    'o nível de risco à saúde até 20, cada morador que confirma soma 3 (até 30) e cada dia em aberto soma 2 (até 20). '
    'A urgência e o nível de risco vêm da IA, que lê o tipo e o relato; o gestor pode corrigir, e a IA não sobrescreve a correção. '
    'A tela à direita é o painel real: o caso de água contaminada aparece com prioridade 80.',
    extra='display:flex;flex-direction:column;justify-content:space-between')


S['mapa'] = secao('mapa', INK, ON_INK, f'''
<div style="display:flex;flex-direction:row;gap:32px">
{fone('cid_mapa', 'Mapa de Teresina com as ocorrências coloridas por urgência', 340)}
{fone('cid_proximas', 'Aviso de relato parecido a 21 metros, com o botão Confirmar', 340)}
</div>
<div style="flex:1;display:flex;flex-direction:column;gap:36px">
{sobrancelha('Mapa vivo', AQUA)}
{titulo('Cada relato no mapa, e os vizinhos confirmam', ON_INK, 820, 64)}
<p style="font-size:30px;line-height:1.45;color:{ON_INK2}">Cor por urgência: o vermelho é risco à saúde. Ao registrar, o app procura relatos do mesmo tipo a até 80 metros. Quem vê o mesmo problema confirma em vez de duplicar, e a prioridade sobe.</p>
<div style="display:flex;flex-direction:row;gap:28px;align-items:center;border-top:1px solid {INKLINE};padding:32px 0px 0px 0px">
<p style="font-family:{DISPLAY};font-size:104px;font-weight:700;line-height:1;color:{AQUA}">46</p>
<p style="font-size:28px;line-height:1.35;color:{ON_INK2};width:440px">ocorrências no mapa de Teresina (base de testes interna)</p>
</div>
</div>''',
    'Mapa real do app, feito com OpenStreetMap, sem custo de licença. À direita, o aviso que aparece quando já existe um relato do mesmo tipo perto: '
    'aqui, a 21 metros. Confirmar soma pontos de prioridade e evita ordens de serviço duplicadas. '
    'Os pontos vêm da base de testes interna da equipe, não de registros reais de moradores.',
    extra='display:flex;flex-direction:row;align-items:center;gap:96px')


def pilar(icone, titulo_, texto):
    return (f'<div style="flex:1;display:flex;flex-direction:column;gap:20px;background:{CARD};padding:48px;border:1px solid {LINE};border-radius:28px">'
            f'<x-icon name="{icone}" style="color:{BLUE};width:56px;height:56px"></x-icon>'
            f'<h3 style="font-family:{DISPLAY};font-size:44px;font-weight:700;line-height:1.1">{titulo_}</h3>'
            f'<p style="font-size:30px;line-height:1.45;color:{TXT2}">{texto}</p></div>')


S['tecnologia'] = secao('tecnologia', PAPER, TXT, f'''
<div style="display:flex;flex-direction:column;gap:24px">
{sobrancelha('Nossa abordagem', BLUE)}
{titulo('Uma base única, segura e rápida de evoluir', TXT)}
</div>
<div style="display:flex;flex-direction:row;gap:32px">
{pilar('Lock', 'Monolito seguro', 'Um só sistema, com as regras de acesso por perfil num único lugar.')}
{pilar('Globe', 'Multiplataforma', 'O mesmo app no celular e na web, para cidadão, técnico e gestor.')}
{pilar('Lightning', 'Rápido de entregar', 'Uma equipe pequena evolui tudo de uma vez, sem integrar vários sistemas.')}
</div>''',
    'Sem entrar em nome de tecnologia: a escolha por uma base única e segura, que funciona em várias plataformas, nos permite entregar rápido '
    'e manter o controle de acesso em um só lugar. Se perguntarem: Flutter no app, Supabase no servidor, com regras de acesso por linha no banco.',
    extra='display:flex;flex-direction:column;justify-content:space-between')


S['fim'] = secao('fim', INK, ON_INK, f'''
{fone('cid_avaliacao', 'Tela em que o cidadão confirma se o problema foi resolvido', 360, 'position:absolute;left:1360px;top:150px;transform:rotate(3deg);')}
<div style="display:flex;flex-direction:column;gap:40px;width:1080px">
{sobrancelha('Hackathon O Piauí que Queremos', AMBER)}
<h2 style="font-family:{DISPLAY};font-size:144px;font-weight:800;line-height:1;letter-spacing:-3px">Obrigado</h2>
<p style="font-family:{DISPLAY};font-size:44px;font-weight:600;line-height:1.25">SISAN: água e esgoto com a voz do cidadão e prioridade por risco à saúde.</p>
<p style="font-size:30px;line-height:1.45;color:{ON_INK2}">Próximo passo: pedir às autoridades, pela Lei de Acesso à Informação, as reclamações reais por bairro.</p>
<div style="display:flex;flex-direction:column;gap:8px;border-top:1px solid {INKLINE};padding:32px 0px 0px 0px">
<p style="font-size:30px;font-weight:700">Elto · Évillyn · Prof. Jorge Luis da Rocha Lima</p>
<p style="font-size:26px;color:{ON_INK2}">Análise e Desenvolvimento de Sistemas · IFPI Picos</p>
</div>
</div>''',
    'Encerramento. A tela à direita é o fim do ciclo: o cidadão vê que o reparo foi concluído e confirma se resolveu. '
    'Fechar com o próximo passo (Lei de Acesso à Informação) e agradecer.',
    extra='display:flex;flex-direction:column;justify-content:center', trans='fade')

# ─── APÊNDICE ─────────────────────────────────────────────────────────────


def apendice_perfil(id_, fundo, escuro, telas, eyebrow, titulo_, itens, notas, texto_antes=True):
    cor = ON_INK if escuro else TXT
    cor2 = ON_INK2 if escuro else TXT2
    ac = AQUA if escuro else BLUE
    fones = ''.join(fone(n, a, 340) for n, a in telas)
    bloco_fones = f'<div style="display:flex;flex-direction:row;gap:32px">{fones}</div>'
    bloco_txt = (f'<div style="flex:1;display:flex;flex-direction:column;gap:32px">{sobrancelha(eyebrow, ac)}'
                 f'{titulo(titulo_, cor, 820, 64)}{lista(itens, cor2)}</div>')
    corpo = bloco_txt + bloco_fones if texto_antes else bloco_fones + bloco_txt
    return secao(id_, fundo, cor, corpo, notas, hidden=True,
                 extra='display:flex;flex-direction:row;align-items:center;gap:96px')


S['perfis'] = apendice_perfil('perfis', INK, True,
    [('login', 'Tela de login'), ('cadastro', 'Tela de criar conta, com escolha entre cidadão e concessionária')],
    'Acesso', 'Cada perfil entra pelo mesmo app',
    ['Cidadão cria a conta em um minuto', 'Técnico e gestor precisam do código de ativação do município', 'As regras de acesso ficam no banco, por perfil'],
    'Login e cadastro. No cadastro o usuário escolhe entre Cidadão e Concessionária; para a concessionária, o perfil técnico ou gestor só é liberado com o código de ativação.')

S['cidadao'] = apendice_perfil('cidadao', PAPER, False,
    [('cid_tipo', 'Escolha do tipo de problema'), ('cid_local', 'Marcação do local no mapa')],
    'Perfil cidadão', 'Registrar leva quatro passos',
    ['Escolha o tipo do problema', 'Confirme o local (o GPS já marca)', 'Descreva e, se quiser, tire uma foto', 'Envie, mesmo sem internet'],
    'Telas reais do perfil cidadão (conta de demonstração). Uma pergunta por tela, com barra de progresso. Sem internet, o registro fica na fila e é enviado quando o sinal voltar.',
    texto_antes=False)

S['tecnico'] = apendice_perfil('tecnico', PAPER, False,
    [('tec_ordens', 'Lista de ordens de serviço por prioridade de risco'), ('tec_os_prioridade', 'Ordem de serviço com a classificação e a prioridade')],
    'Perfil técnico', 'Fila priorizada para o campo',
    ['Ordens pela pontuação de risco', 'Classificação da IA visível na ordem', 'Chegada registrada com GPS', 'Checklist e foto antes de concluir'],
    'Telas reais do perfil técnico. A ordem mostra de onde vem a prioridade. Ao concluir, o técnico precisa cumprir o checklist e anexar a foto do reparo.',
    texto_antes=False)

S['gestor'] = apendice_perfil('gestor', INK, True,
    [('ges_home', 'Início do gestor com o resumo do mês por IA'), ('ges_alertas', 'Alertas sanitários ativos do município')],
    'Perfil gestor', 'O que exige atenção primeiro',
    ['Resumo do mês gerado por IA', 'Ordens sem técnico há mais de 48 horas', 'Prioridades de hoje no painel', 'Alertas sanitários por região'],
    'Telas reais do perfil gestor com dados de demonstração. O gestor vê primeiro o que está parado e o que oferece risco à saúde, em vez de uma lista cronológica.')

S['corrigir'] = apendice_perfil('corrigir', PAPER, False,
    [('ges_classificacao', 'Classificação da IA no detalhe da ocorrência, com o botão Corrigir'), ('ges_corrigir', 'Painel para corrigir urgência e nível de risco')],
    'Pergunta frequente', 'E se a IA errar?',
    ['Cada caso mostra se foi classificado pela IA ou pelo gestor', 'O gestor corrige urgência e nível de risco', 'A fila reordena na hora', 'A IA nunca sobrescreve a correção'],
    'Resposta para a pergunta mais provável da banca. A IA só recebe o tipo e o texto do relato, nada que identifique o cidadão. '
    'Se a IA falhar ou demorar, a ocorrência segue para o técnico com urgência normal; a classificação nunca bloqueia o atendimento.',
    texto_antes=False)

PASSOS = ['Registro', 'Confirmação', 'Triagem', 'Campo', 'Painel', 'Avaliação']
JORNADA = [
    ('cid_local', 'Marcação do local da ocorrência no mapa', 'Maria marca o local',
     'Ela escolhe o tipo, e o GPS já posiciona o ponto no mapa. Funciona mesmo sem internet.'),
    ('cid_proximas', 'Aviso de relato parecido por perto', 'O app evita a duplicata',
     'Se alguém já relatou o mesmo problema perto dali, Maria confirma o relato existente, e a prioridade sobe.'),
    ('ges_classificacao', 'Classificação automática por IA com a prioridade', 'A IA classifica o risco',
     'Urgência e nível de risco à saúde saem do relato. A pontuação define o lugar na fila.'),
    ('tec_os', 'Ordem de serviço do técnico com mapa e etapas', 'O técnico vai a campo',
     'A ordem mostra o local, a prioridade e as etapas: aceita, a caminho e concluída com foto.'),
    ('ges_painel', 'Painel do gestor com as prioridades de hoje', 'O gestor vê o conjunto',
     'As prioridades de hoje reúnem os casos abertos de maior risco no município inteiro.'),
    ('cid_avaliacao', 'Pergunta ao cidadão se o problema foi resolvido', 'Maria confirma a solução',
     'Ela vê que o reparo foi concluído e responde se resolveu. Se não, a ordem volta para a fila.'),
]

for i, (img, alt_txt, tit, texto) in enumerate(JORNADA, start=1):
    pills = ''.join(
        f'<p style="font-size:24px;font-weight:{700 if k == i else 500};padding:12px 20px;border-radius:999px;'
        f'background:{AQUA if k == i else INK2};color:{INK if k == i else ON_INK2}">{p}</p>'
        for k, p in enumerate(PASSOS, start=1))
    S[f'j{i}'] = secao(f'j{i}', INK, ON_INK, f'''
{fone(img, alt_txt, 380, 'position:absolute;left:200px;top:118px;', id_='fone')}
<p style="position:absolute;left:760px;top:150px;width:1000px;font-size:24px;font-weight:700;letter-spacing:4px;color:{AQUA};text-transform:uppercase" data-build-in="fade">Jornada de uma ocorrência · passo {i} de {len(JORNADA)}</p>
<h2 id="titulo" style="position:absolute;left:760px;top:220px;width:1000px;font-family:{DISPLAY};font-size:88px;font-weight:700;line-height:1.05;letter-spacing:-2px" data-build-in="rise">{tit}</h2>
<p id="texto" style="position:absolute;left:760px;top:460px;width:960px;font-size:36px;line-height:1.45;color:{ON_INK2}" data-build-in="rise">{texto}</p>
<div id="passos" style="position:absolute;left:760px;top:800px;width:1032px;display:flex;flex-direction:row;gap:10px">{pills}</div>''',
        'Jornada com telas reais do app e a conta de demonstração da Maria. Cada passo usa a tela do perfil envolvido.',
        hidden=True, trans='fade' if i == len(JORNADA) else 'magic')


def barra_tipo(rotulo, n):
    return (f'<div style="display:flex;flex-direction:row;align-items:center;gap:16px"><p style="width:340px;font-size:28px">{rotulo}</p>'
            f'<div style="width:{n * 22}px;height:36px;background:{BLUE};border-radius:8px"></div>'
            f'<p style="font-size:28px;font-weight:700">{n}</p></div>')


def card_num(numero, rotulo, cor):
    return (f'<div style="display:flex;flex-direction:column;gap:8px;background:{CARD};padding:32px;border:1px solid {LINE};border-radius:24px">'
            f'<p style="font-family:{DISPLAY};font-size:88px;font-weight:700;line-height:1;color:{cor}">{numero}</p>'
            f'<p style="font-size:28px;line-height:1.3;color:{TXT2}">{rotulo}</p></div>')


S['dados'] = secao('dados', PAPER, TXT, f'''
<div style="display:flex;flex-direction:column;gap:24px">
{sobrancelha('Base de testes interna', BLUE)}
{titulo('Os números do banco do SISAN', TXT)}
</div>
<div style="display:flex;flex-direction:row;gap:96px;align-items:flex-start">
<div style="display:grid;grid-template-columns:320px 320px;gap:20px">
{card_num('74', 'ocorrências registradas', BLUE)}
{card_num('37', 'resolvidas (50%)', '#2E7D32')}
{card_num('22', 'com risco à saúde (30%)', '#C62828')}
{card_num('8', 'casos de fonte pública', BLUE)}
</div>
<div style="display:flex;flex-direction:column;gap:20px">
<h3 style="font-family:{DISPLAY};font-size:44px;font-weight:700;line-height:1.15">Ocorrências por tipo</h3>
{barra_tipo("Falta d'água", 21)}
{barra_tipo('Vazamento', 16)}
{barra_tipo('Esgoto a céu aberto', 15)}
{barra_tipo('Outros', 9)}
{barra_tipo('Água contaminada', 7)}
{barra_tipo('Baixa pressão', 6)}
</div>
</div>
<p style="position:absolute;left:128px;bottom:64px;width:1664px;font-size:24px;color:{TXT2}">66 registros da base de testes interna (simulados pela equipe) e 8 casos de fonte pública. Fonte: banco do SISAN, consulta em 09/10/2026.</p>''',
    "Atenção: 66 dos 74 registros são da nossa base de testes interna, simulados pela equipe; 8 são casos documentados em reportagens, descritos no próximo slide. "
    "Falta d'água lidera por causa dos 5 casos de outubro de 2024 (problema na estação de tratamento sul).",
    hidden=True, extra='display:flex;flex-direction:column;gap:48px', pad='128px 128px 160px')


def card_fonte(rot, tit, texto):
    return (f'<div style="flex:1;display:flex;flex-direction:column;gap:16px;background:{INK2};padding:40px;border:1px solid {INKLINE};border-radius:28px">'
            f'<p style="font-size:24px;font-weight:700;letter-spacing:2px;color:{AQUA}">{rot}</p>'
            f'<h3 style="font-family:{DISPLAY};font-size:44px;font-weight:700;line-height:1.15">{tit}</h3>'
            f'<p style="font-size:28px;line-height:1.4;color:{ON_INK2}">{texto}</p></div>')


S['fontes'] = secao('fontes', INK, ON_INK, f'''
<div style="display:flex;flex-direction:column;gap:24px">
{sobrancelha('De onde vêm os dados', AQUA)}
{titulo('Simulação, casos documentados e contexto oficial', ON_INK)}
</div>
<div style="display:flex;flex-direction:row;gap:32px">
{card_fonte('BASE DE TESTES INTERNA', '66 registros', 'Relatos simulados pela equipe para validar o app, nos bairros reais de Teresina.')}
{card_fonte('DOCUMENTADO', '8 casos', "Vazamento na Av. Joaquim Nelson (GP1, 2026), esgoto no Parque Progresso (O Dia, 2022) e falta d'água na ETA Sul (Correio da Manhã, 2024).")}
{card_fonte('OFICIAL', 'Contexto', '866.300 habitantes (IBGE, Censo 2022). Doenças de transmissão hídrica e alimentar: 75.351 casos em 2024 e 65.671 em 2025, queda de cerca de 13% (Fundação Municipal de Saúde).')}
</div>
<p style="position:absolute;left:128px;bottom:64px;width:1664px;font-size:24px;color:{ON_INK2}">Fontes: IBGE (API SIDRA), Fundação Municipal de Saúde via Águas de Teresina (07/04/2026), Instituto Água e Saneamento, ANA, GP1, Portal O Dia, Correio da Manhã.</p>''',
    'Transparência sobre os dados: não existe base pública com ocorrências individuais de Teresina, então misturamos três camadas e rotulamos cada uma. '
    'Os 8 casos documentados citam a fonte e a data na descrição, e os de 2022 e 2024 ficam arquivados, porque o SISAN não atendeu esses casos. '
    'O dado oficial entra como contexto, não como ocorrência. O número de doenças vem da Fundação Municipal de Saúde, divulgado no site da concessionária.',
    hidden=True, trans='fade', extra='display:flex;flex-direction:column;gap:48px', pad='128px 128px 160px')


def card_proximo(num, rot, tit, texto):
    return (f'<div style="flex:1;display:flex;flex-direction:column;gap:16px;background:{CARD};padding:44px;border:1px solid {LINE};border-radius:28px">'
            f'<p style="font-size:24px;font-weight:700;letter-spacing:3px;color:{BLUE}">{num} · {rot}</p>'
            f'<h3 style="font-family:{DISPLAY};font-size:44px;font-weight:700;line-height:1.15">{tit}</h3>'
            f'<p style="font-size:30px;line-height:1.4;color:{TXT2}">{texto}</p></div>')


S['proximo'] = secao('proximo', PAPER, TXT, f'''
<div style="display:flex;flex-direction:column;gap:24px">
{sobrancelha('Próximo passo', BLUE)}
{titulo('Do teste para o dado real, por bairro', TXT)}
</div>
<div style="display:flex;flex-direction:row;gap:32px">
{card_proximo('01', 'PEDIDO', 'Acesso à informação', 'Pedido pela Lei 12.527/2011 à ARSETE e à Prefeitura: reclamações de água e esgoto por bairro, tipo e data, em formato aberto.')}
{card_proximo('02', 'IMPORTAÇÃO', 'Cada caso com fonte', 'Os registros entram no SISAN com a origem e a data, sem dados pessoais.')}
{card_proximo('03', 'PAINEL', 'Prioridade com histórico', 'O gestor decide com o histórico oficial, e o cidadão continua alimentando o mapa em tempo real.')}
</div>
<p style="position:absolute;left:128px;bottom:64px;width:1664px;font-size:24px;color:{TXT2}">Prazo legal de resposta: 20 dias, prorrogáveis por mais 10 (Lei 12.527/2011, art. 11).</p>''',
    'Só afirme que o pedido foi protocolado depois de protocolar de fato, e cite a data. Até lá, este slide descreve um próximo passo. '
    'O texto do pedido está em SISANSecondBrain/referencia/pedido-lai-dados-ocorrencias.md.',
    hidden=True, trans='fade', extra='display:flex;flex-direction:column;justify-content:space-between', pad='128px 128px 160px')

# ─── Escrita ──────────────────────────────────────────────────────────────
ORDEM = ['cover', 'oficial', 'fluxo', 'telas', 'prioridade', 'mapa', 'tecnologia', 'fim',
         'perfis', 'cidadao', 'tecnico', 'gestor', 'corrigir', 'j1', 'j2', 'j3', 'j4', 'j5', 'j6',
         'dados', 'fontes', 'proximo']
assert set(ORDEM) == set(S), set(ORDEM) ^ set(S)
for id_, html in S.items():
    (RAIZ / 'slides' / f'{id_}.html').write_text(html, encoding='utf-8')

deck = json.loads((RAIZ / 'deck.json').read_text(encoding='utf-8'))
deck['order'] = ORDEM
deck['sections'] = {
    'pitch': {'description': 'Pitch de 2 minutos: cenário, solução, app, prioridade, mapa e abordagem.', 'start': 'cover'},
    'apendice': {'description': 'Apêndice escondido, para perguntas: perfis, IA, jornada, dados e fontes.', 'start': 'perfis'},
}
deck['faces'] = {
    'dm-sans': {'family': 'DM Sans', 'href': 'https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;700&display=swap'},
    'bricolage-grotesque': {'family': 'Bricolage Grotesque',
                            'href': 'https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,400..800&display=swap'},
}
(RAIZ / 'deck.json').write_text(json.dumps(deck, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('ok', len(S), 'slides')
