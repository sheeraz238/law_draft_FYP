import 'package:flutter/material.dart';
import '../core/app_info.dart';
import '../core/app_theme.dart';
import '../screens/about_screen.dart';
import '../screens/ask_ai_screen.dart';
import '../screens/case_law_screen.dart';
import '../screens/draft_library_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/guides_screen.dart';
import '../screens/history_screen.dart';
import '../screens/inheritance_screen.dart';
import '../screens/placeholder_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/property_tax_screen.dart';
import '../services/auth_service.dart';

class NavItem {
  final String section;
  final String title;
  final IconData icon;
  const NavItem(this.section, this.title, this.icon);
}

const navItems = [
  NavItem('DRAFTING', 'Draft Library', Icons.menu_book_outlined),
  NavItem('DRAFTING', 'Legal Guides', Icons.route_outlined),
  NavItem('DRAFTING', 'My Drafts', Icons.history),
  NavItem('RESEARCH', 'Case Laws', Icons.gavel_outlined),
  NavItem('RESEARCH', 'Favorites', Icons.star_border),
  NavItem('TOOLS', 'Property Tax Calc', Icons.apartment_outlined),
  NavItem('TOOLS', 'Inheritance Calc', Icons.calculate_outlined),
  NavItem('ACCOUNT', 'Profile', Icons.person_outline),
  NavItem('ACCOUNT', 'About', Icons.balance_outlined),
];

class AppShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const AppShell({super.key, required this.onToggleTheme});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  // jo pages pehli baar khul chuke hain (zinda rakhe jayenge)
  final Set<int> _visited = {0};
  bool _chatOpen = false;
  bool _chatCreated = false;

  // in pages ko har baar taaza data chahiye
  bool _isFresh(int i) =>
      const {'My Drafts', 'Favorites', 'Profile'}.contains(navItems[i].title);

  Widget _screenFor(int i) {
    switch (navItems[i].title) {
      case 'Draft Library':
        return const DraftLibraryScreen();
      case 'Legal Guides':
        return const GuidesScreen();
      case 'My Drafts':
        return const HistoryScreen();
      case 'Case Laws':
        return const CaseLawScreen();
      case 'Favorites':
        return const FavoritesScreen();
      case 'Property Tax Calc':
        return const PropertyTaxScreen();
      case 'Inheritance Calc':
        return const InheritanceScreen();
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

  void _toggleChat() {
    if (_chatOpen) FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _chatOpen = !_chatOpen;
      _chatCreated = true;
    });
  }

  Widget _sidebar({required bool inDrawer, double? width}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tiles = <Widget>[];
    String? last;
    for (var i = 0; i < navItems.length; i++) {
      final n = navItems[i];
      if (n.section != last) {
        last = n.section;
        tiles.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
            child: Text(
              n.section,
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: Color(0x8AFFFFFF),
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
            if (inDrawer) Navigator.pop(context);
          },
        ),
      );
    }

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: isDark ? AppColors.navyDeep : AppColors.navy,
        border: const Border(right: BorderSide(color: Color(0x1FFFFFFF))),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.balance, color: AppColors.navy),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppInfo.appName,
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          AppInfo.tagline,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0x8AFFFFFF),
                          ),
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
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'General information only. Not legal advice.',
                style: TextStyle(fontSize: 11, color: Color(0x73FFFFFF)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatPanel(bool wide, BoxConstraints box) {
    final scheme = Theme.of(context).colorScheme;
    final panel = Visibility(
      visible: _chatOpen,
      maintainState: true,
      child: Material(
        elevation: 12,
        color: scheme.surface,
        borderRadius: BorderRadius.circular(wide ? 18 : 0),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              color: AppColors.navy,
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.gold,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ask AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Legal guides assistant',
                          style: TextStyle(
                            color: Color(0x8AFFFFFF),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _toggleChat,
                  ),
                ],
              ),
            ),
            const Expanded(child: AskAiScreen()),
          ],
        ),
      ),
    );

    if (!wide) return Positioned.fill(child: panel);
    final w = box.maxWidth - 48 < 420 ? box.maxWidth - 48 : 420.0;
    final h = box.maxHeight - 110 < 620 ? box.maxHeight - 110 : 620.0;
    return Positioned(right: 24, bottom: 92, width: w, height: h, child: panel);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final appBar = AppBar(
      automaticallyImplyLeading: !wide,
      title: wide ? null : Text(navItems[_index].title),
      actions: [
        IconButton(
          tooltip: 'Toggle theme',
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
          onPressed: widget.onToggleTheme,
        ),
        IconButton(
          tooltip: 'Log out',
          icon: const Icon(Icons.logout),
          onPressed: () {
            AskAiScreen.clearChat();
            AuthService().signOut();
          },
        ),
        const SizedBox(width: 8),
      ],
    );

    final fab = (_chatOpen && !wide)
        ? null
        : FloatingActionButton(
            onPressed: _toggleChat,
            tooltip: 'Ask AI',
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.navy,
            shape: const CircleBorder(),
            child: Icon(_chatOpen ? Icons.close : Icons.auto_awesome),
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
            _sidebar(inDrawer: false, width: 270),
            Expanded(child: stack),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      floatingActionButton: fab,
      drawer: Drawer(
        width: 290,
        shape: const RoundedRectangleBorder(),
        child: _sidebar(inDrawer: true),
      ),
      body: stack,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? const Color(0x1FFFFFFF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.gold : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  item.icon,
                  size: 20,
                  color: selected ? AppColors.gold : const Color(0xB3FFFFFF),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? Colors.white : const Color(0xB3FFFFFF),
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
