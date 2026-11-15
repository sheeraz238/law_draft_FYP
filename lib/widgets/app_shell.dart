import 'package:flutter/material.dart';
import '../core/app_info.dart';
import '../core/app_theme.dart';
import '../models/user_profile.dart';
import '../screens/about_screen.dart';
import '../screens/ask_ai_screen.dart';
import '../screens/calculators_screen.dart';
import '../screens/case_law_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/draft_library_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/guides_screen.dart';
import '../screens/history_screen.dart';
import '../screens/placeholder_screen.dart';
import '../screens/profile_screen.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../screens/translator_screen.dart';

class NavItem {
  final String section;
  final String title;
  final IconData icon;
  const NavItem(this.section, this.title, this.icon);
}

const navItems = [
  NavItem('HOME', 'Dashboard', Icons.dashboard_outlined),
  NavItem('DRAFTING', 'Draft Library', Icons.folder_open_outlined),
  NavItem('DRAFTING', 'My Drafts', Icons.edit_note_outlined),
  NavItem('LEARN', 'Legal Guides', Icons.menu_book_outlined),
  NavItem('RESEARCH', 'Case Laws', Icons.gavel_outlined),
  NavItem('RESEARCH', 'Favorites', Icons.bookmark_border),
  NavItem('TOOLS', 'Calculators', Icons.calculate_outlined),
    NavItem('TOOLS', 'Translator', Icons.translate),
  NavItem('ACCOUNT', 'Profile', Icons.badge_outlined),
  NavItem('ACCOUNT', 'About', Icons.info_outline),
];

class AppShell extends StatefulWidget {
  // ab dark theme hi hai, ye sirf purane code ke saath chalne ke liye rakha hai
  final VoidCallback? onToggleTheme;
  const AppShell({super.key, this.onToggleTheme});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;
  int _calcTab = 0;
  // jo pages pehli baar khul chuke hain (zinda rakhe jayenge)
  final Set<int> _visited = {0};
  bool _chatOpen = false;
  bool _chatCreated = false;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await ProfileService().fetch();
      if (!mounted) return;
      setState(() => _profile = p);
    } catch (_) {
      // naam nahi aayega, baqi app chalti rahegi
    }
  }

  // in pages ko har baar taaza data chahiye
  bool _isFresh(int i) => const {
    'Dashboard',
    'My Drafts',
    'Favorites',
    'Profile',
  }.contains(navItems[i].title);

  Widget _screenFor(int i) {
    switch (navItems[i].title) {
      case 'Dashboard':
        return DashboardScreen(
          name: (_profile?.fullName ?? '').trim().split(' ').first,
          onGo: (t) => _goTo(t),
          onAskAi: _toggleChat,
        );
      case 'Draft Library':
        return const DraftLibraryScreen();
      case 'My Drafts':
        return const HistoryScreen();
      case 'Legal Guides':
        return const GuidesScreen();
      case 'Case Laws':
        return const CaseLawScreen();
      case 'Favorites':
        return const FavoritesScreen();
      case 'Calculators':
        return CalculatorsScreen(
          tab: _calcTab,
          onChanged: (t) => setState(() => _calcTab = t),
        );
              case 'Translator':
        return const TranslatorScreen();
      case 'Profile':
        return const ProfileScreen();
      case 'About':
        return const AboutScreen();
      default:
        return PlaceholderScreen(title: navItems[i].title);
    }
  }

  void _select(int i) => setState(() {
    _index = i;
    _visited.add(i);
  });

  void _goTo(String title, {int? calcTab}) {
    final i = navItems.indexWhere((n) => n.title == title);
    if (i < 0) return;
    if (calcTab != null) _calcTab = calcTab;
    _select(i);
  }

  void _toggleChat() {
    if (_chatOpen) FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _chatOpen = !_chatOpen;
      _chatCreated = true;
    });
  }

  Widget _sidebar({required bool inDrawer, double? width}) {
    final tiles = <Widget>[];
    String? last;
    void close() {
      if (inDrawer) Navigator.pop(context);
    }

    for (var i = 0; i < navItems.length; i++) {
      final n = navItems[i];
      if (n.section != last) {
        last = n.section;
        tiles.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
            child: Text(
              n.section,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: AppColors.faint,
              ),
            ),
          ),
        );
      }
      tiles.add(
        _NavTile(
          item: n,
          selected: i == _index,
          onTap: () {
            _select(i);
            close();
          },
        ),
      );
      if (n.title == 'Calculators') {
        for (final s in const [(0, 'Property tax'), (1, 'Inheritance share')]) {
          tiles.add(
            _SubTile(
              label: s.$2,
              selected: i == _index && _calcTab == s.$1,
              onTap: () {
                _goTo('Calculators', calcTab: s.$1);
                close();
              },
            ),
          );
        }
      }
    }

    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.sidebar,
        border: Border(right: BorderSide(color: AppColors.hairline)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0x4DE5A93C)),
                    ),
                    child: const Icon(
                      Icons.balance,
                      size: 20,
                      color: AppColors.amber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppInfo.appName,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          AppInfo.tagline.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.mono(size: 9, color: AppColors.amber),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 12),
                children: tiles,
              ),
            ),
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'General information only. Not legal advice.',
                      style: AppTheme.mono(size: 10, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userChip(bool showText) {
    final name = (_profile?.fullName ?? '').trim();
    final firm = (_profile?.lawFirm ?? '').trim();
    final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: const Color(0xFF3A2D12),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.amber,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          if (showText && name.isNotEmpty) ...[
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                if (firm.isNotEmpty)
                  Text(
                    firm,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                      height: 1.2,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chatPanel(bool wide, BoxConstraints box) {
    final w = wide ? (box.maxWidth < 460 ? box.maxWidth : 460.0) : box.maxWidth;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      top: 0,
      bottom: 0,
      width: w,
      right: _chatOpen ? 0 : -(w + 8),
      child: IgnorePointer(
        ignoring: !_chatOpen,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.sidebar,
            border: Border(left: BorderSide(color: AppColors.line)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.hairline)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A2D12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x4DE5A93C)),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 20,
                        color: AppColors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ask AI',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'LEGAL GUIDES ASSISTANT',
                            style: AppTheme.mono(
                              size: 10,
                              color: AppColors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close, color: AppColors.muted),
                      onPressed: _toggleChat,
                    ),
                  ],
                ),
              ),
              const Expanded(child: AskAiScreen()),
            ],
          ),
        ),
      ),
    );
  }

  int _bottomIndex() {
    switch (navItems[_index].title) {
      case 'Dashboard':
        return 0;
      case 'Draft Library':
        return 1;
      case 'Legal Guides':
        return 2;
      case 'Calculators':
        return 3;
      default:
        return 4;
    }
  }

  void _bottomTap(int i) {
    if (i == 0) {
      _goTo('Dashboard');
    } else if (i == 1) {
      _goTo('Draft Library');
    } else if (i == 2) {
      _goTo('Legal Guides');
    } else if (i == 3) {
      _goTo('Calculators');
    } else {
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _index == 0 && !_chatOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_chatOpen) {
          _toggleChat();
        } else if (_index != 0) {
          _select(0);
        }
      },
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 800;
    final pageTitle = navItems[_index].title;

    final appBar = AppBar(
      toolbarHeight: 64,
      automaticallyImplyLeading: !wide,
      titleSpacing: wide ? 24 : null,
      title: wide
          ? Row(
              children: [
                Text(
                  'LAW DRAFT',
                  style: AppTheme.mono(size: 11, color: AppColors.faint),
                ),
                const SizedBox(width: 8),
                const Text('/', style: TextStyle(color: AppColors.faint)),
                const SizedBox(width: 8),
                Text(
                  pageTitle,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          : Text(pageTitle),
      actions: [
        _userChip(wide),
        const SizedBox(width: 4),
        IconButton(
          tooltip: 'Log out',
          icon: const Icon(Icons.logout, color: AppColors.muted),
          onPressed: () {
            AskAiScreen.clearChat();
            AuthService().signOut();
          },
        ),
        const SizedBox(width: 8),
      ],
    );

    final fab = _chatOpen
        ? null
        : FloatingActionButton(
            onPressed: _toggleChat,
            tooltip: 'Ask AI',
            child: const Icon(Icons.auto_awesome),
          );

    final content = IndexedStack(
      index: _index,
      children: [
        for (var i = 0; i < navItems.length; i++)
          if (_isFresh(i))
            (i == _index ? _screenFor(i) : const SizedBox.shrink())
          else
            (_visited.contains(i) ? _screenFor(i) : const SizedBox.shrink()),
      ],
    );

    final stack = LayoutBuilder(
      builder: (context, box) => Stack(
        children: [
          Positioned.fill(child: content),
          if (_chatOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleChat,
                child: const ColoredBox(color: Color(0x99000000)),
              ),
            ),
          if (_chatCreated) _chatPanel(wide, box),
        ],
      ),
    );

    if (wide) {
      return Scaffold(
        appBar: appBar,
        floatingActionButton: fab,
        body: Row(
          children: [
            _sidebar(inDrawer: false, width: 260),
            Expanded(child: stack),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: appBar,
      floatingActionButton: fab,
      drawer: Drawer(
        width: 280,
        shape: const RoundedRectangleBorder(),
        child: _sidebar(inDrawer: true),
      ),
      body: stack,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomIndex(),
        onDestinationSelected: _bottomTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            label: 'Drafts',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Guides',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            label: 'Tools',
          ),
          NavigationDestination(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final NavItem item;
  final bool selected;
  final VoidCallback onTap;
  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.canvas : AppColors.muted;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? AppColors.amber : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: const Color(0x0DFFFFFF),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: fg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppColors.canvas : AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SubTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(44, 8, 12, 8),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: selected ? AppColors.amber : AppColors.faint,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.amber : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
