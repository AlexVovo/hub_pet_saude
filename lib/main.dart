import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const driveRoot =
    'https://drive.google.com/drive/folders/1f5g51F-XQrpLIUj7WFDQE8n7WguwCzgb';

void main() => runApp(const PetSaudeApp());

class PetSaudeApp extends StatelessWidget {
  const PetSaudeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet-Saúde | Conecta Onco',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF6F8FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B7773),
          brightness: Brightness.light,
        ),
        fontFamily: 'Arial',
        cardTheme: const CardThemeData(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
      ),
      home: const HubHomePage(),
    );
  }
}

class HubFolder {
  const HubFolder({
    required this.name,
    required this.description,
    required this.url,
    required this.icon,
    required this.color,
    required this.category,
  });

  final String name;
  final String description;
  final String url;
  final IconData icon;
  final Color color;
  final String category;
}

const folders = [
  HubFolder(
    name: 'Apresentações',
    description: 'Materiais de apresentação do programa.',
    url: 'https://drive.google.com/drive/folders/1lr00nVo_IFndUT_m6Uo96Njw6yb5xGFL',
    icon: Icons.slideshow_outlined,
    color: Color(0xFF0B7773),
    category: 'Institucional',
  ),
  HubFolder(
    name: 'Artigos',
    description: 'Artigos e referências para consulta.',
    url: 'https://drive.google.com/drive/folders/1CZ9GN6sNSu_f9yhupuLEtK-zhkkOwMI0',
    icon: Icons.article_outlined,
    color: Color(0xFFB65C31),
    category: 'Pesquisa',
  ),
  HubFolder(
    name: 'CA de colo / gestão',
    description: 'Materiais de gestão do câncer de colo.',
    url: 'https://drive.google.com/drive/folders/1Ttg-SykdjJG0S1tDe5iX35OlRDGNTPnO',
    icon: Icons.business_center_outlined,
    color: Color(0xFF9C6B28),
    category: 'Gestao',
  ),
  HubFolder(
    name: 'Oncologia pediátrica',
    description: 'Conteúdos sobre cuidado oncológico infantil.',
    url: 'https://drive.google.com/drive/folders/1f69xtuFI8X0LoIzWzvishPDOG02ha93S',
    icon: Icons.child_care_outlined,
    color: Color(0xFFB24A5D),
    category: 'Assistencia',
  ),
  HubFolder(
    name: 'Atas de reunião',
    description: 'Memórias, decisões e encaminhamentos.',
    url: 'https://drive.google.com/drive/folders/1IOcamS9LcYrmLXIb4KPwZ3hqHjGowxgO',
    icon: Icons.groups_outlined,
    color: Color(0xFF287A8A),
    category: 'Gestao',
  ),
  HubFolder(
    name: 'CEP',
    description: 'Documentos do comitê de ética em pesquisa.',
    url: 'https://drive.google.com/drive/folders/1P3ls6E2IFKnPNBJcKVaPpS9Q5_3Zbx_W',
    icon: Icons.verified_user_outlined,
    color: Color(0xFF4D669B),
    category: 'Institucional',
  ),
  HubFolder(
    name: 'Certificados',
    description: 'Certificados e comprovantes de participação.',
    url: 'https://drive.google.com/drive/folders/1QEbbrZFzoEvCa6GImybSXkw0-_mhZVSK',
    icon: Icons.workspace_premium_outlined,
    color: Color(0xFFB65C31),
    category: 'Institucional',
  ),
  HubFolder(
    name: 'Dados',
    description: 'Bases e arquivos gerais de dados.',
    url: 'https://drive.google.com/drive/folders/1DtnrkpaJvOwDVZXTdrO4K35xm30RT7Wb',
    icon: Icons.storage_outlined,
    color: Color(0xFF4D669B),
    category: 'Dados',
  ),
  HubFolder(
    name: 'ARQ_SIM_DATASUS',
    description: 'Arquivos de simulação e dados do DATASUS.',
    url: 'https://drive.google.com/drive/folders/1ug7ZEsawzwIAnt0LbXXkgiX0_Cm2lxUA',
    icon: Icons.storage_outlined,
    color: Color(0xFF3D7B66),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Base DATASUS',
    description: 'Bases públicas para análise em saúde.',
    url: 'https://drive.google.com/drive/folders/1KknbyyGZCQsZiFbVZ6PbUKYwlXDudVfV',
    icon: Icons.dataset_outlined,
    color: Color(0xFF287A8A),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Estados',
    description: 'Recortes e dados organizados por estado.',
    url: 'https://drive.google.com/drive/folders/1XRytQqHV6YdKC7vhjP7oZDwvuGf3pK7Q',
    icon: Icons.map_outlined,
    color: Color(0xFF7C5A9E),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Geral',
    description: 'Materiais gerais da base de dados.',
    url: 'https://drive.google.com/drive/folders/19UGNiYRclxgjCEmXhM5FKHOykrb10k7I',
    icon: Icons.folder_copy_outlined,
    color: Color(0xFF9C6B28),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Colo do utero',
    description: 'Dados e materiais sobre câncer do colo.',
    url: 'https://drive.google.com/drive/folders/1vEgU9oBEVPz8tCUbqFiu_EDFKiUNJNJb',
    icon: Icons.analytics_outlined,
    color: Color(0xFFB24A5D),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Informações sobre óbitos',
    description: 'Informações de mortalidade e óbitos.',
    url: 'https://drive.google.com/drive/folders/1HR9wsNhWx__4AohR9e6G0MYac19cs0je',
    icon: Icons.monitor_heart_outlined,
    color: Color(0xFF0B7773),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Óbitos por faixa etária',
    description: 'Análises de óbitos por faixa etária.',
    url: 'https://drive.google.com/drive/folders/1VvsTnzwt-OTqINgF1HSXRVaiAwJklF0D',
    icon: Icons.bar_chart_outlined,
    color: Color(0xFF4D669B),
    category: 'Dados',
  ),
  HubFolder(
    name: 'População feminina por região',
    description: 'Indicadores da população feminina regional.',
    url: 'https://drive.google.com/drive/folders/1-XQtex6BeajJhWrvvgk9u61qFW-2wvQh',
    icon: Icons.groups_2_outlined,
    color: Color(0xFFB65C31),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Rastreamento',
    description: 'Materiais e dados de rastreamento.',
    url: 'https://drive.google.com/drive/folders/1nVuJbF08c2gJZFL16zI0EJ1XYbUxtXOW',
    icon: Icons.search_outlined,
    color: Color(0xFF3D7B66),
    category: 'Assistencia',
  ),
  HubFolder(
    name: 'Infanto juvenil',
    description: 'Dados e materiais sobre público infantojuvenil.',
    url: 'https://drive.google.com/drive/folders/1RLiUUYHEqs8pZJqJK5WUJmgfQhXj8Ke8',
    icon: Icons.child_friendly_outlined,
    color: Color(0xFF7C5A9E),
    category: 'Assistencia',
  ),
  HubFolder(
    name: 'Documentos',
    description: 'Arquivos institucionais e referências.',
    url: 'https://drive.google.com/drive/folders/1xu8_itEVmMuTcj8tM2wtCuSNGoG-7DZo',
    icon: Icons.folder_copy_outlined,
    color: Color(0xFF9C6B28),
    category: 'Institucional',
  ),
  HubFolder(
    name: 'Saúde mental',
    description: 'Conteúdos e ações de cuidado da equipe.',
    url: 'https://drive.google.com/drive/folders/13C7ZeyI5Ic_IgJL_g3jA_hVokq4TLQhV',
    icon: Icons.self_improvement_outlined,
    color: Color(0xFF3D7B66),
    category: 'Cuidado',
  ),
  HubFolder(
    name: 'Fotos e vídeos',
    description: 'Registros das atividades e encontros.',
    url: 'https://drive.google.com/drive/folders/134PvOIba9GwnAGcpvRbsiUWe1XGECkeS',
    icon: Icons.perm_media_outlined,
    color: Color(0xFFB24A5D),
    category: 'Memoria',
  ),
  HubFolder(
    name: 'Frequência de atividades',
    description: 'Registros de participação e acompanhamento.',
    url: 'https://drive.google.com/drive/folders/16-KqY5FYDKWXxJlmSEZ0nQf-iPUngNMI',
    icon: Icons.fact_check_outlined,
    color: Color(0xFF7C5A9E),
    category: 'Gestao',
  ),
  HubFolder(
    name: 'Plataforma Pet-Conecta Onco',
    description: 'Ambiente e materiais da plataforma do programa.',
    url: 'https://drive.google.com/drive/folders/1QMNisoCQoJ-y-xj6T9dBymyZUL8f_2a5',
    icon: Icons.hub_outlined,
    color: Color(0xFF0B7773),
    category: 'Institucional',
  ),
  HubFolder(
    name: 'Dashboards',
    description: 'Painéis e painéis para acompanhamento.',
    url: 'https://drive.google.com/drive/folders/1csQ3_dQI7gorK1p5PFCSyvl2ZLK2w_Dz',
    icon: Icons.dashboard_outlined,
    color: Color(0xFF4D669B),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Sistema de recomendação',
    description: 'Materiais do sistema de apoio à decisão.',
    url: 'https://drive.google.com/drive/folders/1hUSoRINVp-rfr--P46ufUIlPFT5hO9Ej',
    icon: Icons.auto_awesome_outlined,
    color: Color(0xFFB65C31),
    category: 'Pesquisa',
  ),
  HubFolder(
    name: 'Produções',
    description: 'Artigos, trabalhos e resultados do programa.',
    url: 'https://drive.google.com/drive/folders/1yh9YuCYc92a4DZlX7EkZ4O0t9xuvcTnE',
    icon: Icons.article_outlined,
    color: Color(0xFFB65C31),
    category: 'Pesquisa',
  ),
  HubFolder(
    name: 'Resumos - Congresso Brasileiro de Saúde Única',
    description: 'Resumos apresentados no congresso nacional.',
    url: 'https://drive.google.com/drive/folders/1Fqtlewo-xyLyLQiSIScIoh2StsEkmRAt',
    icon: Icons.menu_book_outlined,
    color: Color(0xFF287A8A),
    category: 'Pesquisa',
  ),
  HubFolder(
    name: 'Resumos - Congresso Gaúcho de Pediatria 2026',
    description: 'Resumos do Congresso Gaúcho de Pediatria.',
    url: 'https://drive.google.com/drive/folders/17nAhtSO7yhxRkrPQHInKckNbYHPhxCKe',
    icon: Icons.menu_book_outlined,
    color: Color(0xFF7C5A9E),
    category: 'Pesquisa',
  ),
  HubFolder(
    name: 'Protocolos clínicos',
    description: 'Materiais e protocolos de cuidado oncológico.',
    url: 'https://drive.google.com/drive/folders/13FbGlmrqucczmqlvQzA0kgXUo6TxYe39',
    icon: Icons.medical_services_outlined,
    color: Color(0xFF0B7773),
    category: 'Assistencia',
  ),
  HubFolder(
    name: 'Câncer do colo uterino',
    description: 'Protocolos e materiais sobre câncer do colo.',
    url: 'https://drive.google.com/drive/folders/1xbg4RKWTMCzSP5OIRs8jQdfWrkrZyQ6w',
    icon: Icons.health_and_safety_outlined,
    color: Color(0xFFB24A5D),
    category: 'Assistencia',
  ),
  HubFolder(
    name: 'Oncologia pediátrica',
    description: 'Protocolos para oncologia pediátrica.',
    url: 'https://drive.google.com/drive/folders/1QAbxnXNZmuQeClHRkcyDLS7JLcacvQ9d',
    icon: Icons.child_care_outlined,
    color: Color(0xFF287A8A),
    category: 'Assistencia',
  ),
  HubFolder(
    name: 'Apoio para família e paciente',
    description: 'Materiais de acolhimento e orientação.',
    url: 'https://drive.google.com/drive/folders/1IgxD9d3xsarLeLygYSkVin7wThFkMmQ7',
    icon: Icons.volunteer_activism_outlined,
    color: Color(0xFF3D7B66),
    category: 'Cuidado',
  ),
  HubFolder(
    name: 'Saúde mental',
    description: 'Conteúdos de cuidado emocional e suporte.',
    url: 'https://drive.google.com/drive/folders/1o7oGPurPOd-_hxPX3OiHlUw-_argpMUu',
    icon: Icons.self_improvement_outlined,
    color: Color(0xFF7C5A9E),
    category: 'Cuidado',
  ),
  HubFolder(
    name: 'Vida após o tratamento',
    description: 'Materiais para o período após o tratamento.',
    url: 'https://drive.google.com/drive/folders/1W4t5j6Eq6SQuvEvbxgrZwSW8eBbiEe3B',
    icon: Icons.wb_sunny_outlined,
    color: Color(0xFFB65C31),
    category: 'Cuidado',
  ),
  HubFolder(
    name: 'Evidências',
    description: 'Evidências científicas e referências.',
    url: 'https://drive.google.com/drive/folders/1S2fCkexCUiGESn9JlKg6jsnCn-exG_fw',
    icon: Icons.fact_check_outlined,
    color: Color(0xFF4D669B),
    category: 'Pesquisa',
  ),
  HubFolder(
    name: 'Guidelines',
    description: 'Diretrizes e guias clínicos.',
    url: 'https://drive.google.com/drive/folders/1osaC6DkX2PPbDgRh2hbRybbe9mfBTxyF',
    icon: Icons.menu_book_outlined,
    color: Color(0xFF0B7773),
    category: 'Assistencia',
  ),
  HubFolder(
    name: 'Protocolos de suporte',
    description: 'Protocolos complementares de cuidado.',
    url: 'https://drive.google.com/drive/folders/1YyrD3JmNdnFAzzx8tuIqNFSBr1Gx1qIv',
    icon: Icons.support_outlined,
    color: Color(0xFF287A8A),
    category: 'Assistencia',
  ),
  HubFolder(
    name: 'Relatórios',
    description: 'Relatórios e documentos de acompanhamento.',
    url: 'https://drive.google.com/drive/folders/1Xo_nJuXm4Owtef47EBEywB08Hb8Wg8x_',
    icon: Icons.description_outlined,
    color: Color(0xFF9C6B28),
    category: 'Gestao',
  ),
  HubFolder(
    name: 'Escalas',
    description: 'Escalas e instrumentos de avaliação.',
    url: 'https://drive.google.com/drive/folders/1Km7KDfRFkWLT-K1QDMB4qcpkZ3CTZ95Y',
    icon: Icons.rule_folder_outlined,
    color: Color(0xFF7C5A9E),
    category: 'Assistencia',
  ),
  HubFolder(
    name: 'Tabela',
    description: 'Tabelas de apoio e referência.',
    url: 'https://drive.google.com/drive/folders/15G7OTjeTtfOo_-6MC33DfLXuV4tnW-2T',
    icon: Icons.table_chart_outlined,
    color: Color(0xFF4D669B),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Visualização de dados',
    description: 'Painéis, bases e leituras para apoiar decisões.',
    url: 'https://drive.google.com/drive/folders/1aOcUHxT9pjv67QjEBv24o7pd3AF7DVtn',
    icon: Icons.insights_outlined,
    color: Color(0xFF4D669B),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Colo do útero',
    description: 'Materiais específicos sobre o colo do útero.',
    url: 'https://drive.google.com/drive/folders/15Mj8KqeQ2NpDmRqWsgPyfVGBeuS2eIvs',
    icon: Icons.analytics_outlined,
    color: Color(0xFFB24A5D),
    category: 'Assistencia',
  ),
  HubFolder(
    name: 'Infanto juvenil',
    description: 'Materiais específicos para público jovem.',
    url: 'https://drive.google.com/drive/folders/1zeLRCySQoZ2s5o1B9VVAuZ6tG0Qkl9rb',
    icon: Icons.child_friendly_outlined,
    color: Color(0xFF287A8A),
    category: 'Assistencia',
  ),
  HubFolder(
    name: 'Material introdutório Power BI e Power Query',
    description: 'Conteúdos iniciais para análise de dados.',
    url: 'https://drive.google.com/drive/folders/14NfYbBrYPuaX1-bxj4WZco4eGt2dZz8m',
    icon: Icons.school_outlined,
    color: Color(0xFFB65C31),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Introdução ao Power BI',
    description: 'Primeiros passos no Power BI.',
    url: 'https://drive.google.com/drive/folders/1jAVat7x8BJeEs-duIDLlFMgEBDFMjLV_',
    icon: Icons.bar_chart_outlined,
    color: Color(0xFF4D669B),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Prática de Power BI',
    description: 'Exercícios práticos de Power BI.',
    url: 'https://drive.google.com/drive/folders/1V7240fi7I-7qV7A0QNYwu81vX8DaZogf',
    icon: Icons.insights_outlined,
    color: Color(0xFF0B7773),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Práticas 1-4',
    description: 'Sequência de práticas de análise.',
    url: 'https://drive.google.com/drive/folders/1QdKRf3d-NlW_nP73d6EO1PMUOUccdXfr',
    icon: Icons.format_list_numbered_outlined,
    color: Color(0xFF7C5A9E),
    category: 'Dados',
  ),
  HubFolder(
    name: 'Práticas Power Query',
    description: 'Exercícios de tratamento de dados.',
    url: 'https://drive.google.com/drive/folders/1CRW4WMVsAW9CD2eCTDh7brcL4Mld1XAe',
    icon: Icons.transform_outlined,
    color: Color(0xFF3D7B66),
    category: 'Dados',
  ),
];

class HubHomePage extends StatefulWidget {
  const HubHomePage({super.key});

  @override
  State<HubHomePage> createState() => _HubHomePageState();
}

class _HubHomePageState extends State<HubHomePage> {
  String selectedCategory = 'Todos';
  String searchText = '';

  List<HubFolder> get visibleFolders {
    return folders.where((folder) {
      final matchesCategory =
          selectedCategory == 'Todos' || folder.category == selectedCategory;
      final matchesSearch = folder.name.toLowerCase().contains(
        searchText.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> openDrive(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o Google Drive.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isWide) const _SideNavigation(),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _Header(
                        onOpenDrive: () => openDrive(driveRoot),
                        isWide: isWide,
                      ),
                    ),
                    SliverToBoxAdapter(child: _WelcomeSection(isWide: isWide)),
                    SliverToBoxAdapter(
                      child: _Toolbar(
                        selectedCategory: selectedCategory,
                        onCategoryChanged: (value) =>
                            setState(() => selectedCategory = value),
                        onSearchChanged: (value) =>
                            setState(() => searchText = value),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        isWide ? 42 : 20,
                        10,
                        isWide ? 42 : 20,
                        42,
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _FolderCard(
                            folder: visibleFolders[index],
                            onTap: () => openDrive(visibleFolders[index].url),
                          ),
                          childCount: visibleFolders.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 310,
                              mainAxisExtent: 194,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 238,
      padding: const EdgeInsets.fromLTRB(24, 28, 18, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE5EAF0))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandMark(),
          const SizedBox(height: 52),
          const Text(
            'NAVEGAÇÃO',
            style: TextStyle(
              color: Color(0xFF8A96A6),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          const _NavItem(
            icon: Icons.grid_view_rounded,
            label: 'Visão geral',
            active: true,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: Color(0xFF0B7773),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Conteúdo sincronizado com a pasta compartilhada.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Color(0xFF31615D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Color(0xFF0B7773),
          child: Icon(Icons.favorite_rounded, color: Colors.white, size: 21),
        ),
        SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PET-SAÚDE',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17323B),
              ),
            ),
            Text(
              'Conecta Onco',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF0B7773),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE8F4F1) : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: active ? const Color(0xFF0B7773) : const Color(0xFF7B8794),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? const Color(0xFF0B7773) : const Color(0xFF536170),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onOpenDrive, required this.isWide});
  final VoidCallback onOpenDrive;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 42 : 20, 25, isWide ? 42 : 20, 14),
      child: Row(
        children: [
          if (!isWide) const _BrandMark(),
          if (!isWide) const Spacer(),
          IconButton(
            tooltip: 'Abrir pasta no Google Drive',
            onPressed: onOpenDrive,
            icon: const Icon(Icons.open_in_new_rounded, size: 20),
            style: IconButton.styleFrom(
              foregroundColor: const Color(0xFF0B7773),
            ),
          ),
          const SizedBox(width: 4),
          const CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFFD9EBE7),
            child: Text(
              'PS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B7773),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  const _WelcomeSection({required this.isWide});
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 42 : 20, 12, isWide ? 42 : 20, 22),
      child: Container(
        padding: EdgeInsets.all(isWide ? 30 : 23),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF0E7772), Color(0xFF155B67)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CENTRO DE CONEXÕES',
                    style: TextStyle(
                      color: Color(0xFFB8E0D8),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Tudo do Conecta Onco\nem um só lugar.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWide ? 27 : 23,
                      fontWeight: FontWeight.w700,
                      height: 1.14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Acesse rapidamente os materiais, registros e produções do Pet-Saúde.',
                    style: TextStyle(
                      color: Color(0xFFD5EFEB),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isWide)
              const Padding(
                padding: EdgeInsets.only(left: 20, right: 22),
                child: Icon(
                  Icons.hub_rounded,
                  size: 76,
                  color: Color(0x389DE0D8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSearchChanged,
  });
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    const categories = {
      'Todos': 'Todos',
      'Assistência': 'Assistencia',
      'Pesquisa': 'Pesquisa',
      'Gestão': 'Gestao',
      'Institucional': 'Institucional',
      'Dados': 'Dados',
      'Cuidado': 'Cuidado',
      'Memória': 'Memoria',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 430;
              final search = SizedBox(
                width: isCompact ? constraints.maxWidth : 220,
                height: 40,
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar área',
                    prefixIcon: const Icon(Icons.search_rounded, size: 19),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              );
              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Áreas do hub',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17323B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    search,
                  ],
                );
              }
              return Row(
                children: [
                  const Text(
                    'Áreas do hub',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF17323B),
                    ),
                  ),
                  const Spacer(),
                  search,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, index) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final label = categories.keys.elementAt(index);
                final category = categories[label]!;
                final active = category == selectedCategory;
                return ChoiceChip(
                  label: Text(label),
                  selected: active,
                  onSelected: (_) => onCategoryChanged(category),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white : const Color(0xFF536170),
                  ),
                  selectedColor: const Color(0xFF0B7773),
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  showCheckmark: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({required this.folder, required this.onTap});
  final HubFolder folder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: folder.color.withAlpha(24),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(folder.icon, color: folder.color, size: 22),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: folder.color,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                folder.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF17323B),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                folder.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: Color(0xFF718091),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
